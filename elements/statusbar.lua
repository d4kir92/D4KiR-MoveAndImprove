
local stabar = StatusTrackingBarManager
if StatusTrackingBarManager == nil then
	stabar = MainMenuExpBar
end

function MAIIsXPBarVisible()
	return UnitLevel("PLAYER") ~= MAIGetMaxLevel()
end

function MAIIsREPBarVisible()
	local name, reaction, minBar, maxBar, value, factionID = GetWatchedFactionInfo()
	return name ~= nil
end

function MAIIsPetBarVisible()
	return UnitExists("PET") and UnitLevel("PET") ~= UnitLevel("PLAYER")
end

local oldrepindex = -1
function MAISetWatchedFactionIndex( index )
	oldrepindex = -1
	MAISV( "repindex", index )
end

function MAIGetFactionIndex(faction)
	for i = 1, GetNumFactions() do
		local infoFaction = GetFactionInfo(i)
		if infoFaction == faction then
			if IsFactionInactive(i) then
				break
			end
			return i
		end
	end
end

function MAISetWatchedFaction(faction)
	local index = MAIGetFactionIndex(faction)
	if index and index > 0 then
		MAISetWatchedFactionIndex(index)
	end
end


function MAITryGetFaction(message, factionString)
	local pattern = string.gsub(factionString, "[%^%$%(%)%.%[%]%*%+%-%?]", "%%%0")
	pattern = string.gsub(pattern, "%%d", "(%%d+)")
	pattern = string.gsub(pattern, "%%s", "(.+)")
	return strmatch(message, pattern)
end

MAIStatusBar = CreateFrame( "FRAME", "MAIStatusBar", UIParent)
MAIStatusBar:SetPoint("TOP", UIParent, "TOP")
MAIStatusBar:SetSize(800, 20)

function MAIStatusBar:GetBarCount()
	local count = 0
	if MAIIsXPBarVisible() then
		count = count + 1
	end
	if MAIIsREPBarVisible() then
		count = count + 1
	end
	if MAIIsPetBarVisible() then
		count = count + 1
	end
	return 3 --count
end

function MAISetupStatusBar()
	if MAIGV( "repindex" ) == nil then
		MAISV( "repindex", 0 ) -- 0: off, 1+: factionid
	end
	if MAIGV( "MAIStatusBar" .. "autoselectfaction" ) == nil then
		MAISV( "MAIStatusBar" .. "autoselectfaction", true )
	end

	if MAIGV( "MAIStatusBar" .. "width" ) == nil then
		MAISV( "MAIStatusBar" .. "width", 800 )
	end
	MAISV( "MAIStatusBar" .. "height", MAIGV( "MAIStatusBar" .. "height" ) or 30 )
	if MAIGV( "MAIStatusBar" .. "height" ) == 20 and MAIGV( "MAIStatusBar" .. "fixed" ) == nil then
		MAISV( "MAIStatusBar" .. "fixed", true )
		MAISV( "MAIStatusBar" .. "height", 40 )
	end
	MAIStatusBar:SetWidth( MAIGV( "MAIStatusBar" .. "width" ) )
	MAIStatusBar:SetHeight( MAIGV( "MAIStatusBar" .. "height" ) )
	
	MAIStatusBar:SetMovable(true)
	--MAIStatusBar:SetUserPlaced(true)
		
	stabar:UnregisterAllEvents()
	stabar.Show = stabar.Hide
	stabar:Hide()

	for i = 0, 90, 10 do
		MAIRegisterUIColor(MAIStatusBar.XPBar["overlaygrid" .. i])
	end
	for i = 0, 90, 10 do
		MAIRegisterUIColor(MAIStatusBar.REPBar["overlaygrid" .. i])
	end
	for i = 0, 90, 10 do
		MAIRegisterUIColor(MAIStatusBar.XPBarPet["overlaygrid" .. i])
	end

	if ReputationWatchBar then
		ReputationWatchBar:SetParent(MAIHIDDEN)
	end

	MAIStatusBar.XPBar.oldper = 0
	MAIStatusBar.XPBar.oldperex = 0
	function MAIStatusBar.XPBar.Think()
		local self = MAIStatusBar.XPBar

		local maxlevel = MAIGetMaxLevel()
		
		if not MAIIsXPBarVisible() then
			self.texture:SetAlpha(0)
			self.textureFill:SetAlpha(0)
			self.textureFill2:SetAlpha(0)
			self.text:SetAlpha(0)
			self:EnableMouse(false)
			C_Timer.After(0.1, MAIStatusBar.XPBar.Think)
		else
			self.texture:SetAlpha(0.4)
			self.textureFill:SetAlpha(1)
			self.text:SetAlpha(1)
			self:EnableMouse(true)

			local currXP = UnitXP("PLAYER")
			local maxBar = UnitXPMax("PLAYER")
		
			if (GameLimitedMode_IsActive()) then
				local rLevel = GetRestrictedAccountData()
				if (UnitLevel("player") >= rLevel) then
					currXP = UnitTrialXP("player")
				end
			end
			
			if maxBar > 0 then
				local per = currXP / maxBar
				local percent = per * 100
				--			  "|cAARRGGBB"
				local textc = "|cFF00FF00" -- Colored
				local textw = "|r" -- "WHITE"
				local text = LEVEL .. ": " .. textc .. UnitLevel("PLAYER") .. textw .. "/" .. textc .. maxlevel .. "    " .. textw
				text = text .. XP .. ": " .. textc .. MAIDottedNumber(currXP) .. textw .. "/" .. textc .. MAIDottedNumber(maxBar) .. " " .. textw .. "(" .. textc .. format("%.2f", percent) .. "%" .. textw .. ")"
				if not MAIGV( "nochanges" ) and MAIGV( "MAIStatusBar" .. "missingxp", true ) then
					text = text .. "    " .. textw .. MAIGT( "missingxp" ) .. ": " .. textc .. MAIDottedNumber(maxBar - currXP)
				end
				if GetXPExhaustion() and GetXPExhaustion() >= 0 then
					self.textureFill2:SetAlpha(0.5)
					local eper = GetXPExhaustion() / maxBar
					local epercent = eper * 100
					text = text .. "    " .. textw .. TUTORIAL_TITLE26 .. ": " .. textc .. MAIDottedNumber(GetXPExhaustion()) .. " " .. textw .. "(" .. textc .. format("%.2f", epercent) .. "%" .. textw .. ")"
					
					self.oldperex = MAILerp( self.oldperex, eper, 0.04 )
					local ew = self.oldperex * self:GetWidth()
					if ew > (self:GetWidth() - per * self:GetWidth()) then
						ew = self:GetWidth() - per * self:GetWidth()
					end
					self.textureFill2:SetWidth( ew )
				else
					self.textureFill2:SetAlpha(0)
				end
				self.text:SetText(text)
				if per == 0 then
					per = 0.001
				end
				
				self.oldper = MAILerp( self.oldper, per, 0.04 )
				self.textureFill:SetWidth( self.oldper * self:GetWidth() )
			end

			C_Timer.After(0.01, MAIStatusBar.XPBar.Think)
		end
	end
	MAIStatusBar.XPBar.Think()

	MAIStatusBar.REPBar.oldper = 0
	function MAIStatusBar.REPBar.Think()
		local self = MAIStatusBar.REPBar

		if self.visible ~= MAIIsREPBarVisible() then
			self.visible = MAIIsREPBarVisible()
			MAIStatusBar:SetHeight(MAIStatusBar:GetHeight())
		end

		local fname, _, _, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo( MAIGV( "repindex" ) )
		local currentindex = MAIGetFactionIndex(fname)
		if currentindex then
			if not MAIGV( "nochanges" ) and MAIGV( "MAIStatusBar" .. "autoselectfaction" ) and MAIGV( "repindex" ) > 0 and currentindex > 0 and currentindex ~= oldrepindex then
				oldrepindex = MAIGV( "repindex" )
				SetWatchedFactionIndex( MAIGV( "repindex" ) )
			end
		end
		local name, reaction, minBar, maxBar, value, factionID = GetWatchedFactionInfo()

		local colorIndex = reaction
		local isCapped
		if GetFriendshipReputation then
			local friendshipID = GetFriendshipReputation(factionID)
			
			if ( self.factionID ~= factionID ) then
				self.factionID = factionID
				self.friendshipID = GetFriendshipReputation(factionID)
			end
			
			-- do something different for friendships
			local level
			
			if ( friendshipID ) then
				local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
				level = GetFriendshipReputationRanks(factionID)
				if ( nextFriendThreshold ) then
					minBar, maxBar, value = friendThreshold, nextFriendThreshold, friendRep
				else
					-- max rank, make it look like a full bar
					minBar, maxBar, value = 0, 1, 1
					isCapped = true
				end
				colorIndex = 5		-- always color friendships green
			elseif ( C_Reputation.IsFactionParagon(factionID) ) then
				local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
				minBar, maxBar  = 0, threshold
				value = currentValue % threshold
				if ( hasRewardPending ) then 
					value = value + threshold
				end
			else
				level = reaction
				if ( reaction == MAX_REPUTATION_REACTION ) then
					isCapped = true
				end
			end
		end
		
		-- Normalize values
		maxBar = maxBar - minBar
		value = value - minBar
		if ( isCapped and maxBar == 0 ) then
			maxBar = 1
			value = 1
		end
		minBar = 0

		--			  "|cAARRGGBB"
		local textc = "|cFF00FF00" -- Colored
		local textw = "|r" -- WHITE
		local text = ""
		
		if name ~= nil and MAIIsREPBarVisible() then
			self.rep = value
	
			self.texture:SetAlpha(0.4)
			self.textureFill:SetAlpha(1)
			self.text:SetAlpha(1)
			
			local per = (value - minBar) / (maxBar-minBar)
			local percent = per * 100
			if maxBar-minBar > 0 then
				text = name .. ": " .. textc .. MAIDottedNumber((value - minBar)) .. textw .. "/" .. textc .. MAIDottedNumber((maxBar-minBar)) .. " " .. textw .. "(" .. textc .. format("%.2f", percent) .. "%" .. textw .. ")"

				self.text:SetText(text) 
			end

			local color = FACTION_BAR_COLORS[colorIndex]
			self.textureFill:SetVertexColor(color.r, color.g, color.b, 1)

			if per == 0 then
				per = 0.001
			end

			self.oldper = MAILerp( self.oldper, per, 0.04 )
			self.textureFill:SetWidth( self.oldper * self:GetWidth() )

			C_Timer.After(0.01, MAIStatusBar.REPBar.Think)
		else
			self.rep = value
	
			self.texture:SetAlpha(0)
			self.textureFill:SetAlpha(0)
			self.text:SetAlpha(0)

			C_Timer.After(0.1, MAIStatusBar.REPBar.Think)
		end
	end
	MAIStatusBar.REPBar.Think()

	function MAIStatusBar.XPBarPet.Think()
		local self = MAIStatusBar.XPBarPet

		local currXP, maxBar = GetPetExperience()

		if self.visible ~= MAIIsPetBarVisible() then
			self.visible = MAIIsPetBarVisible()
			MAIStatusBar:SetHeight(MAIStatusBar:GetHeight())
		end

		if self.xp ~= currXP then
			self.xp = currXP
	
			if not MAIIsPetBarVisible() then
				self.texture:SetAlpha(0)
				self.textureFill:SetAlpha(0)
				self.text:SetAlpha(0)
				for i = 0, 90, 10 do
					self["overlaygrid" .. i]:SetAlpha(0)
				end
				self:EnableMouse(false)
			else
				self.texture:SetAlpha(0.4)
				self.textureFill:SetAlpha(1)
				self.text:SetAlpha(1)
				for i = 0, 90, 10 do
					self["overlaygrid" .. i]:SetAlpha(1)
				end
				self:EnableMouse(true)

				if maxBar == 0 then
					maxBar = 1
				end

				local per = currXP / maxBar
				local percent = per * 100
				--			  "|cAARRGGBB"
				local textc = "|cFF00FF00" -- Colored
				local textw = "|r" -- WHITE
				local text = PET .. " - " .. LEVEL .. ": " .. textc .. UnitLevel("PET") .. "    " .. textw
				if maxBar > 1 then
					text = text .. XP .. ": " .. textc .. MAIDottedNumber(currXP) .. textw .. "/" .. textc .. MAIDottedNumber(maxBar) .. " " .. textw .. "(" .. textc .. format("%.2f", percent) .. "%" .. textw .. ")"
				end
				if per == 0 then
					per = 0.001
				end
				self.text:SetText(text)
				self.textureFill:SetWidth(per * self:GetWidth())
			end
		end
		C_Timer.After(1, MAIStatusBar.XPBarPet.Think)
	end
	MAIStatusBar.XPBarPet.Think()
end



MAIStatusBar.XPBar = CreateFrame( "FRAME", "XPBar", MAIStatusBar)
MAIStatusBar.XPBar:SetSize(MAIStatusBar:GetWidth(), 10)
hooksecurefunc(MAIStatusBar, "SetWidth", function(self, sw, sh)
	if MAIGV( "MAIStatusBar" .. "width" ) and MAIGV( "MAIStatusBar" .. "width" ) > 1600 then
		MAISV( "MAIStatusBar" .. "width", 1600 )
	end
	if MAIStatusBarMover then
		MAIStatusBarMover:SetWidth(self:GetWidth())
	end
	MAIStatusBar.XPBar:SetWidth(self:GetWidth())

	for i = 0, 90, 10 do
		local w = 0.1 * MAIStatusBar.XPBar:GetWidth()
		MAIStatusBar.XPBar["overlaygrid" .. i]:SetWidth(w * 1.03)
		if MAIGV( "MAIStatusBar" .. "hideartwork" ) then
			MAIStatusBar.XPBar["overlaygrid" .. i]:Hide()
		else
			MAIStatusBar.XPBar["overlaygrid" .. i]:Show()
			MAIStatusBar.XPBar["overlaygrid" .. i]:SetPoint("LEFT", MAIStatusBar.XPBar, "LEFT", i / 100 * MAIStatusBar.XPBar:GetWidth() - 2, 0)
		end
	end
end)
hooksecurefunc(MAIStatusBar, "SetHeight", function(self, sw, sh)
	MAIStatusBarMover:SetHeight(self:GetHeight())
	local h = self:GetHeight() / self:GetBarCount()
	MAIStatusBar.XPBar:SetHeight(h)
	MAIStatusBar.XPBar.textureFill:SetHeight(h)
	MAIStatusBar.XPBar.textureFill2:SetHeight(h)

	local ts = math.floor(h) - 2
	MAIStatusBar.XPBar.text:SetFont(STANDARD_TEXT_FONT, ts, "THINOUTLINE")
	if MAIGV( "MAIStatusBar" .. "showonlywhenhovered" ) then
		MAIStatusBar.XPBar.text:Hide()
	end

	for i = 0, 90, 10 do
		MAIStatusBar.XPBar["overlaygrid" .. i]:SetHeight(h * 1.6)
	end
end)

MAIStatusBar.XPBar.texture = MAIStatusBar.XPBar:CreateTexture(nil, "BACKGROUND")
MAIStatusBar.XPBar.texture:SetDrawLayer("BACKGROUND", 1)
MAIStatusBar.XPBar.texture:SetAllPoints(MAIStatusBar.XPBar)
MAIStatusBar.XPBar.texture:SetColorTexture(0, 0, 0)

MAIStatusBar.XPBar.textureFill = MAIStatusBar.XPBar:CreateTexture(nil, "BACKGROUND")
MAIStatusBar.XPBar.textureFill:SetDrawLayer("BACKGROUND", 5)
MAIStatusBar.XPBar.textureFill:SetSize(100, 10)
MAIStatusBar.XPBar.textureFill:SetPoint("TOPLEFT", MAIStatusBar.XPBar, "TOPLEFT", 0, 0)
MAIStatusBar.XPBar.textureFill:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
MAIStatusBar.XPBar.textureFill:SetVertexColor(0.25, 0.5, 1.0)

MAIStatusBar.XPBar.textureFill2 = MAIStatusBar.XPBar:CreateTexture(nil, "BACKGROUND")
MAIStatusBar.XPBar.textureFill2:SetDrawLayer("BACKGROUND", 6)
MAIStatusBar.XPBar.textureFill2:SetSize(100, 10)
MAIStatusBar.XPBar.textureFill2:SetPoint("LEFT", MAIStatusBar.XPBar.textureFill, "RIGHT", 0, 0)
MAIStatusBar.XPBar.textureFill2:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
MAIStatusBar.XPBar.textureFill2:SetVertexColor(0.0, 0.39, 0.88, 0.5)

for i = 0, 90, 10 do
	MAIStatusBar.XPBar["overlaygrid" .. i] = MAIStatusBar.XPBar:CreateTexture(nil, "BACKGROUND")
	MAIStatusBar.XPBar["overlaygrid" .. i]:SetDrawLayer("BACKGROUND", 7)
	MAIStatusBar.XPBar["overlaygrid" .. i]:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")--"Interface\\TargetingFrame\\UI-StatusBar")--ColorTexture(1, 1, 0, 1)
end

MAIStatusBar.XPBar.text = MAIStatusBar.XPBar:CreateFontString(nil, "ARTWORK")
MAIStatusBar.XPBar.text:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
MAIStatusBar.XPBar.text:SetPoint("CENTER", MAIStatusBar.XPBar, "CENTER", 0, 0)
MAIStatusBar.XPBar.text:SetText("")

MAIStatusBar.XPBar:SetScript('OnEnter', function()
	if MAIGV( "MAIStatusBar" .. "showonlywhenhovered" ) then
		MAIStatusBar.XPBar.text:Show()
	else
		MAIStatusBar.XPBar.text:Hide()
	end
end)
MAIStatusBar.XPBar:SetScript('OnLeave', function()
	if MAIGV( "MAIStatusBar" .. "showonlywhenhovered" ) then
		MAIStatusBar.XPBar.text:Hide()
	else
		MAIStatusBar.XPBar.text:Show()
	end
end)



MAIStatusBar.REPBar = CreateFrame( "FRAME", "REPBar", MAIStatusBar)
MAIStatusBar.REPBar:SetSize(MAIStatusBar:GetWidth(), 10)
hooksecurefunc(MAIStatusBar, "SetWidth", function(self, sw, sh)
	if MAIGV( "MAIStatusBar" .. "width" ) and MAIGV( "MAIStatusBar" .. "width" ) > 1600 then
		MAISV( "MAIStatusBar" .. "width", 1600 )
	end
	MAIStatusBar.REPBar:SetWidth(self:GetWidth())

	for i = 0, 90, 10 do
		local w = 0.1 * MAIStatusBar.REPBar:GetWidth()
		MAIStatusBar.REPBar["overlaygrid" .. i]:SetWidth(w * 1.03)
		if MAIGV( "MAIStatusBar" .. "hideartwork" ) then
			MAIStatusBar.REPBar["overlaygrid" .. i]:Hide()
		else
			MAIStatusBar.REPBar["overlaygrid" .. i]:Show()
			MAIStatusBar.REPBar["overlaygrid" .. i]:SetPoint("LEFT", MAIStatusBar.REPBar, "LEFT", i / 100 * MAIStatusBar.REPBar:GetWidth() - 2, 0)
		end
	end
end)
local function MAIThinkRepBarBorders()
	for i = 0, 90, 10 do
		local bord = MAIStatusBar.REPBar["overlaygrid" .. i]
		if bord then
			if MAIGV( "MAIStatusBar" .. "hideartwork" ) or not MAIIsREPBarVisible() then
				bord:Hide()
			else
				bord:Show()
			end
		end
	end
	C_Timer.After( 0.1, MAIThinkRepBarBorders )
end
MAIThinkRepBarBorders()

hooksecurefunc(MAIStatusBar, "SetHeight", function(self, sw, sh)
	local h = self:GetHeight() / self:GetBarCount()
	MAIStatusBar.REPBar:SetHeight(h)
	MAIStatusBar.REPBar.textureFill:SetHeight(h)

	local ts = math.floor(h) - 2
	MAIStatusBar.REPBar.text:SetFont(STANDARD_TEXT_FONT, ts, "THINOUTLINE")
	if MAIGV( "MAIStatusBar" .. "showonlywhenhovered" ) then
		MAIStatusBar.REPBar.text:Hide()
	end

	for i = 0, 90, 10 do
		MAIStatusBar.REPBar["overlaygrid" .. i]:SetHeight(h * 1.6)
	end
end)

MAIStatusBar.REPBar.texture = MAIStatusBar.REPBar:CreateTexture(nil, "BACKGROUND")
MAIStatusBar.REPBar.texture:SetDrawLayer("BACKGROUND", 1)
MAIStatusBar.REPBar.texture:SetAllPoints(MAIStatusBar.REPBar)
MAIStatusBar.REPBar.texture:SetColorTexture(0, 0, 0)

MAIStatusBar.REPBar.textureFill = MAIStatusBar.REPBar:CreateTexture(nil, "BACKGROUND")
MAIStatusBar.REPBar.textureFill:SetDrawLayer("BACKGROUND", 6)
MAIStatusBar.REPBar.textureFill:SetSize(100, 10)
MAIStatusBar.REPBar.textureFill:SetPoint("TOPLEFT", MAIStatusBar.REPBar, "TOPLEFT", 0, 0)
MAIStatusBar.REPBar.textureFill:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])

for i = 0, 90, 10 do
	MAIStatusBar.REPBar["overlaygrid" .. i] = MAIStatusBar.REPBar:CreateTexture(nil, "BACKGROUND")
	MAIStatusBar.REPBar["overlaygrid" .. i]:SetDrawLayer("BACKGROUND", 7)
	MAIStatusBar.REPBar["overlaygrid" .. i]:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
end

MAIStatusBar.REPBar.text = MAIStatusBar.REPBar:CreateFontString(nil, "ARTWORK")
MAIStatusBar.REPBar.text:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
MAIStatusBar.REPBar.text:SetPoint("CENTER", MAIStatusBar.REPBar, "CENTER", 0, 0)
MAIStatusBar.REPBar.text:SetText("")

MAIStatusBar.REPBar:HookScript('OnEnter', function()
	if MAIGV( "MAIStatusBar" .. "showonlywhenhovered" ) then
		MAIStatusBar.REPBar.text:Show()
	else
		MAIStatusBar.REPBar.text:Hide()
	end
end)
MAIStatusBar.REPBar:SetScript('OnLeave', function()
	if MAIGV( "MAIStatusBar" .. "showonlywhenhovered" ) then
		MAIStatusBar.REPBar.text:Hide()
	else
		MAIStatusBar.REPBar.text:Show()
	end
end)



MAIStatusBar.XPBarPet = CreateFrame( "FRAME", "XPBarPet", MAIStatusBar)
MAIStatusBar.XPBarPet:SetSize(MAIStatusBar:GetWidth(), 10)
hooksecurefunc(MAIStatusBar, "SetWidth", function(self, sw, sh)
	if MAIGV( "MAIStatusBar" .. "width" ) and MAIGV( "MAIStatusBar" .. "width" ) > 1600 then
		MAISV( "MAIStatusBar" .. "width", 1600 )
	end
	MAIStatusBarMover:SetWidth(self:GetWidth())
	MAIStatusBar.XPBarPet:SetWidth(self:GetWidth())

	for i = 0, 90, 10 do
		local w = 0.1 * MAIStatusBar.XPBarPet:GetWidth()
		MAIStatusBar.XPBarPet["overlaygrid" .. i]:SetWidth(w * 1.03)
		if MAIGV( "MAIStatusBar" .. "hideartwork" ) then
			MAIStatusBar.XPBarPet["overlaygrid" .. i]:Hide()
		else
			MAIStatusBar.XPBarPet["overlaygrid" .. i]:Show()
			MAIStatusBar.XPBarPet["overlaygrid" .. i]:SetPoint("LEFT", MAIStatusBar.XPBarPet, "LEFT", i / 100 * MAIStatusBar.XPBarPet:GetWidth() - 2, 0)
		end
	end
end)
hooksecurefunc(MAIStatusBar, "SetHeight", function(self, sw, sh)
	local h = self:GetHeight() / self:GetBarCount()
	MAIStatusBar.XPBarPet:SetHeight(h)
	MAIStatusBar.XPBarPet.textureFill:SetHeight(h)

	local ts = math.floor(h) - 2
	MAIStatusBar.XPBarPet.text:SetFont(STANDARD_TEXT_FONT, ts, "THINOUTLINE")
	if MAIGV( "MAIStatusBar" .. "showonlywhenhovered" ) then
		MAIStatusBar.XPBarPet.text:Hide()
	end

	for i = 0, 90, 10 do
		MAIStatusBar.XPBarPet["overlaygrid" .. i]:SetHeight(h * 1.6)
	end
end)

MAIStatusBar.XPBarPet.texture = MAIStatusBar.XPBarPet:CreateTexture(nil, "BACKGROUND")
MAIStatusBar.XPBarPet.texture:SetDrawLayer("BACKGROUND", 1)
MAIStatusBar.XPBarPet.texture:SetAllPoints(MAIStatusBar.XPBarPet)
MAIStatusBar.XPBarPet.texture:SetColorTexture(0, 0, 0)

MAIStatusBar.XPBarPet.textureFill = MAIStatusBar.XPBarPet:CreateTexture(nil, "BACKGROUND")
MAIStatusBar.XPBarPet.textureFill:SetDrawLayer("BACKGROUND", 6)
MAIStatusBar.XPBarPet.textureFill:SetSize(100, 10)
MAIStatusBar.XPBarPet.textureFill:SetPoint("TOPLEFT", MAIStatusBar.XPBarPet, "TOPLEFT", 0, 0)
MAIStatusBar.XPBarPet.textureFill:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
MAIStatusBar.XPBarPet.textureFill:SetVertexColor(0.25, 0.5, 1.0)

for i = 0, 90, 10 do
	MAIStatusBar.XPBarPet["overlaygrid" .. i] = MAIStatusBar.XPBarPet:CreateTexture(nil, "BACKGROUND")
	MAIStatusBar.XPBarPet["overlaygrid" .. i]:SetDrawLayer("BACKGROUND", 7)
	MAIStatusBar.XPBarPet["overlaygrid" .. i]:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
end

MAIStatusBar.XPBarPet.text = MAIStatusBar.XPBarPet:CreateFontString(nil, "ARTWORK")
MAIStatusBar.XPBarPet.text:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
MAIStatusBar.XPBarPet.text:SetPoint("CENTER", MAIStatusBar.XPBarPet, "CENTER", 0, 0)
MAIStatusBar.XPBarPet.text:SetText("")

MAIStatusBar.XPBarPet:SetScript('OnEnter', function()
	if MAIGV( "MAIStatusBar" .. "showonlywhenhovered" ) then
		MAIStatusBar.XPBarPet.text:Show()
	else
		MAIStatusBar.XPBarPet.text:Hide()
	end
end)
MAIStatusBar.XPBarPet:SetScript('OnLeave', function()
	if MAIGV( "MAIStatusBar" .. "showonlywhenhovered" ) then
		MAIStatusBar.XPBarPet.text:Hide()
	else
		MAIStatusBar.XPBarPet.text:Show()
	end
end)



local rwf = CreateFrame( "FRAME", "rwf", UIParent )
rwf:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
rwf:SetScript("OnEvent", function( self, event, ... )
	if event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
		local message = ...

		local faction, amount = MAITryGetFaction(message, FACTION_STANDING_INCREASED)

		if not faction then
			faction, amount = MAITryGetFaction(message, FACTION_STANDING_INCREASED_BONUS)
		end

		if faction and amount and tonumber(amount) > 0 then
			MAISetWatchedFaction(faction)
		end
	end
end)

local constH = 0.00000001

local function MAIStatusBarThink()
	if MAIStatusBarMover and MAIStatusBar.XPBar  and MAIStatusBar.REPBar  and MAIStatusBar.XPBarPet then
		local orient = 0 -- 0: down, 1: up
		local point, parent, relpoint, ofsx, ofsy = MAIStatusBarMover:GetPoint()
		if point == "BOTTOM" or point == "BOTTOMLEFT" or point == "BOTTOMRIGHT" then
			orient = 1
		elseif point == "CENTER" or point == "LEFT" or point == "RIGHT" then
			if ofsy < 0 then
				orient = 1
			end
		end

		local h = MAIStatusBar:GetHeight() / MAIStatusBar:GetBarCount()
		if MAIIsXPBarVisible() then
			MAIStatusBar.XPBar:SetHeight(h)
			MAIStatusBar.XPBar:Show()
		else
			MAIStatusBar.XPBar:SetHeight(constH)
			MAIStatusBar.XPBar:Hide()
		end
		if MAIIsREPBarVisible() then
			MAIStatusBar.REPBar:SetHeight(h)
			MAIStatusBar.REPBar:Show()
		else
			MAIStatusBar.REPBar:SetHeight(constH)
			MAIStatusBar.REPBar:Hide()
		end
		if MAIIsPetBarVisible() then
			MAIStatusBar.XPBarPet:SetHeight(h)
			MAIStatusBar.XPBarPet:Show()
		else
			MAIStatusBar.XPBarPet:SetHeight(constH)
			MAIStatusBar.XPBarPet:Hide()
		end

		if orient == 0 then -- down
			MAIStatusBar.XPBar:ClearAllPoints()
			MAIStatusBar.XPBar:SetPoint("TOPLEFT", MAIStatusBar, "TOPLEFT", 0, 0)

			MAIStatusBar.REPBar:ClearAllPoints()
			MAIStatusBar.REPBar:SetPoint("TOPLEFT", MAIStatusBar.XPBar, "BOTTOMLEFT", 0, 0)

			MAIStatusBar.XPBarPet:ClearAllPoints()
			MAIStatusBar.XPBarPet:SetPoint("TOPLEFT", MAIStatusBar.REPBar, "BOTTOMLEFT", 0, 0)
		else -- up
			MAIStatusBar.XPBar:ClearAllPoints()
			MAIStatusBar.XPBar:SetPoint("BOTTOMLEFT", MAIStatusBar, "BOTTOMLEFT", 0, 0)

			MAIStatusBar.REPBar:ClearAllPoints()
			MAIStatusBar.REPBar:SetPoint("BOTTOMLEFT", MAIStatusBar.XPBar, "TOPLEFT", 0, 0)

			MAIStatusBar.XPBarPet:ClearAllPoints()
			MAIStatusBar.XPBarPet:SetPoint("BOTTOMLEFT", MAIStatusBar.REPBar, "TOPLEFT", 0, 0)
		end
	end

	C_Timer.After( 0.1, MAIStatusBarThink )
end
MAIStatusBarThink()
