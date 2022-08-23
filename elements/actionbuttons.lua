
MAIMAXBAR = 10
MAIMINBAR = 7

local BINDBARS = {}
BINDBARS[1] = "ActionButton"
BINDBARS[2] = "ActionBar2Button"
BINDBARS[3] = "MultiBarRightButton"
BINDBARS[4] = "MultiBarLeftButton"
BINDBARS[5] = "MultiBarBottomRightButton"
BINDBARS[6] = "MultiBarBottomLeftButton"
--BINDBARS[10] = "OverrideActionBarButton"

local RELINK = {}
RELINK["MainMenuBarArtFrame"] = "ActionBar1"
RELINK["MultiBarRight"] = "ActionBar3"
RELINK["MultiBarLeft"] = "ActionBar4"
RELINK["MultiBarBottomRight"] = "ActionBar5"
RELINK["MultiBarBottomLeft"] = "ActionBar6"
RELINK["PetActionBarFrame"] = "PetBar"
RELINK["StanceBarFrame"] = "StanceBar"
--RELINK["OverrideAction"] = "ActionBar10"

local MAIAB = {}
for i = 1, MAIMAXBAR do
	for j = 1, 12 do
		local btnname = "ActionBar" .. i .. "Button" .. j
		if i <= 6 then
			btnname = BINDBARS[i] .. j
		end

		tinsert(MAIAB, btnname)
	end
end
for i = 1, MAIMAXBAR do
	tinsert(MAIAB, "PetActionButton" .. i)
end
for i = 1, MAIMAXBAR do
	tinsert(MAIAB, "StanceButton" .. i)
end
ACTIONBORDER = 0.056

local mmb = false
local rmb = false
local mbp = false
local emb = false
local ebars = {}
function MAIUpdateActionButton()
	local someenabled = false
	for i = 1, MAIMAXBAR do
		ebars[i] = MAIGV( "ActionBar" .. i .. "Enabled" )
		if ebars[i] then
			someenabled = true
		end
	end

	if MAILoaded and (MAIGV( "ActionBar" .. 1 .. "Enabled" ) or MAIGV( "ActionBar" .. 5 .. "Enabled" ) or MAIGV( "ActionBar" .. 6 .. "Enabled" ) ) and mmb == false then -- MainMenu Handle
		mmb = true

		if MainMenuBarArtFrame then
			MainMenuBarArtFrame:EnableMouse(false)
		end
		--MainMenuBar:EnableMouse(false)
		if MainMenuBarArtFrameBackground ~= nil then
			MainMenuBarArtFrameBackground:EnableMouse(false)
			MainMenuBarArtFrameBackground.BackgroundLarge:SetTexture(nil)
			MainMenuBarArtFrameBackground.BackgroundSmall:SetTexture(nil)
			MainMenuBarArtFrame.LeftEndCap:SetTexture(nil)
			MainMenuBarArtFrame.RightEndCap:SetTexture(nil)
		end
		if MainMenuBarLeftEndCap then
			MainMenuBarLeftEndCap:SetTexture(nil)
			MainMenuBarRightEndCap:SetTexture(nil)
			for i = 0, 3 do
				if _G["MainMenuBarTexture" .. i].hooked == nil then
					_G["MainMenuBarTexture" .. i].hooked = true
					hooksecurefunc(_G["MainMenuBarTexture" .. i], "SetTexture", function(self)
						if self.settexture then return end
						self.settexture = true
						self:SetTexture(nil)
						self.settexture = false
					end)
				end
				_G["MainMenuBarTexture" .. i]:SetTexture(nil)

				if _G["MainMenuMaxLevelBar" .. i].hooked == nil then
					_G["MainMenuMaxLevelBar" .. i].hooked = true
					hooksecurefunc(_G["MainMenuMaxLevelBar" .. i], "SetTexture", function(self)
						if self.settexture then return end
						self.settexture = true
						self:SetTexture(nil)
						self.settexture = false
					end)
				end
				_G["MainMenuMaxLevelBar" .. i]:SetTexture(nil)
			end
		end
	else--if someenabled then
		if MainMenuBarLeftEndCap then
			MAIRegisterUIColor(MainMenuBarLeftEndCap)
			MAIRegisterUIColor(MainMenuBarRightEndCap)

			for i = 0, 3 do
				MAIRegisterUIColor(_G["MainMenuBarTexture" .. i])
				MAIRegisterUIColor(_G["MainMenuMaxLevelBar" .. i])
				MAIRegisterUIColor(_G["MainMenuXPBarTexture" .. i])
				MAIRegisterUIColor(ReputationWatchBar.StatusBar["WatchBarTexture" .. i])
			end
			
		end
		if MainMenuBarArtFrameBackground ~= nil then
			MAIRegisterUIColor(MainMenuBarArtFrameBackground.BackgroundLarge)
			MAIRegisterUIColor(MainMenuBarArtFrameBackground.BackgroundSmall)
			MAIRegisterUIColor(MainMenuBarArtFrame.LeftEndCap)
			MAIRegisterUIColor(MainMenuBarArtFrame.RightEndCap)
		end
	end
	if MAILoaded and (MAIGV( "ActionBar" .. 3 .. "Enabled" ) or MAIGV( "ActionBar" .. 4 .. "Enabled"  ) ) and rmb == false then -- Right ActionButtons
		rmb = true
	end

	if MAILoaded and (MAIGV( "ActionBar" .. 2 .. "Enabled" ) ) and mbp == false then -- Arrows from main bar
		mbp = true

		ActionBarUpButton:SetParent(MAIHIDDEN)

		ActionBarDownButton:SetParent(MAIHIDDEN)

		if MainMenuBarArtFrame.PageNumber then
			MainMenuBarArtFrame.PageNumber:SetParent(MAIHIDDEN)
		elseif MainMenuBarPageNumber then
			MainMenuBarPageNumber:SetParent(MAIHIDDEN)
		end
	elseif emb == false then
		if ActionBar1 ~= nil and ActionBar1.btns then
			emb = true

			if MainMenuBarArtFrame.PageNumber then
				tinsert(ActionBar1.btns, MainMenuBarArtFrame.PageNumber)
			elseif MainMenuBarPageNumber then
				tinsert(ActionBar1.btns, MainMenuBarPageNumber)
			end
			tinsert(ActionBar1.btns, ActionBarUpButton)
			tinsert(ActionBar1.btns, ActionBarDownButton)
		end
	end

	if MAIActionbarsCheckDefault then
		MAIActionbarsCheckDefault()
	end

	for i, btnname in pairs(MAIAB) do
		if _G[btnname] ~= nil then
			local btn = _G[btnname]
			
			btn:SetMovable(true)
			--btn:SetUserPlaced(true)

			local pname = ""
			if _G[btnname]:GetParent() then
				pname = _G[btnname]:GetParent():GetName()
				if RELINK[_G[btnname]:GetParent():GetName()] then
					pname = RELINK[_G[btnname]:GetParent():GetName()]
				end
			end

			if pname ~= nil and MAILoaded then
				if not MAIGV( "nochanges" ) then
					-- Icon Zoom
					_G[btnname .. "Icon"]:SetTexCoord(ACTIONBORDER, 1 - ACTIONBORDER, ACTIONBORDER, 1 - ACTIONBORDER)
					--_G[btnname .. "Icon"]:SetDrawLayer("BORDER", -6)

					if _G[btnname .. "HotKey"] ~= nil then
						if _G[btnname .. "HotKey"].hooked == nil then
							_G[btnname .. "HotKey"].hooked = true
							hooksecurefunc(_G[btnname .. "HotKey"], "Show", function()
								if MAIGV( pname .. "hidehk" ) then
									_G[btnname .. "HotKey"]:Hide()
								end
							end)
						end
						if MAIGV( pname .. "hidehk" ) then
							_G[btnname .. "HotKey"]:Show()
						end
					end

					if _G[btnname .. "Name"] ~= nil then
						if _G[btnname .. "Name"].hooked == nil then
							_G[btnname .. "Name"].hooked = true
							hooksecurefunc(_G[btnname .. "Name"], "Show", function()
								if MAIGV( pname .. "hidena" ) then
									_G[btnname .. "Name"]:Hide()
								end
							end)
						end
						if MAIGV( pname .. "hidena" ) then
							_G[btnname .. "Name"]:Show()
						end
					end

					-- Overlay Border
					local nr = ""
					if _G[btnname .. "NormalTexture2"] ~= nil then
						nr = 2
					end
					if _G[btnname].hooked == nil then
						_G[btnname].hooked = true

						if _G[btnname .. "FloatingBG"] == nil then
							_G[btnname .. "FloatingBG"] = _G[btnname]:CreateTexture(btnname .. "FloatingBG", "BACKGROUND")
							_G[btnname .. "FloatingBG"]:SetParent( _G[btnname] )
							_G[btnname .. "FloatingBG"]:SetPoint( "TOPLEFT", -15, 15 ) --_G[btnname])
							_G[btnname .. "FloatingBG"]:SetPoint( "BOTTOMRIGHT", 15, -15 ) --_G[btnname])
							_G[btnname .. "FloatingBG"]:SetTexture("Interface/Buttons/UI-Quickslot")
							_G[btnname .. "FloatingBG"]:SetVertexColor( 1, 1, 0, 0.4 )
							_G[btnname .. "FloatingBG"]:SetDrawLayer( "BACKGROUND", -1 )
						end

						if MAIGV( pname .. "improvements" ) and _G[btnname .. "FloatingBG"] ~= nil and not MAIGV( "nochanges" ) then
							MAIRegisterUIColor(_G[btnname .. "FloatingBG"])
							_G[btnname .. "FloatingBG"].SetVertexColor = function() end
						end

						if MAIGV( pname .. "improvements" ) and not MAIGV( "nochanges" ) then
							if _G[btnname .. "NormalTexture" .. nr].hooked == nil then
								_G[btnname .. "NormalTexture" .. nr].hooked = true
								hooksecurefunc(_G[btnname .. "NormalTexture" .. nr], "SetVertexColor", function(self, ...)
									if self.setvertexcolor then return end
									self.setvertexcolor = true
									if MAIGV( "UIColorEnabled", true ) then
										self:SetVertexColor(MAIGetUIColor())
									end
									self.setvertexcolor = false
								end)
							end
							MAIRegisterUIColor(_G[btnname .. "NormalTexture" .. nr])
						end
					end
				end
			end
		end
	end

	local count = 0
	local c = 0
	local spacing = 0
	local w = 0
	local h = 0
	local rows = 0

	if StanceBar then
		local cou = 0
		if GetNumShapeshiftForms() > 0 then
			cou = GetNumShapeshiftForms()
		else
			cou = NUM_STANCE_SLOTS
		end
		MAISV( "StanceBar" .. "count", cou )
		
		count = MAIGV( "StanceBar" .. "count" )
		if type(MAIGV( "StanceBar" .. "rows" )) and MAIGV( "StanceBar" .. "rows" ) == "max" then
			rows = cou
		else
			rows = MAIGV( "StanceBar" .. "rows" )
		end
		c = count / rows

		spacing = MAIGV( "StanceBar" .. "spacing" )
		w = MAIMathR(_G["StanceButton1"]:GetWidth()) * c + spacing * (c - 1)
		h = MAIMathR(_G["StanceButton1"]:GetHeight()) * (count / c) + spacing * (count / c - 1)

		if StanceBar.SetSize and not InCombatLockdown() then
			StanceBar:SetSize(w, h)
		end
	end
	for x = 1, MAIMAXBAR do
		if _G["ActionBar" .. x] then
			count = MAIGV( "ActionBar" .. x .. "count" )
			if type(MAIGV( "ActionBar" .. x .. "rows" )) and MAIGV( "ActionBar" .. x .. "rows" ) == "max" then
				rows = MAIGV( "ActionBar" .. x .. "count" )
			else
				rows = MAIGV( "ActionBar" .. x .. "rows" )
			end
			c = MAIGV( "ActionBar" .. x .. "count" ) / rows
			spacing = MAIGV( "ActionBar" .. x .. "spacing" )
			w = MAIMathR(36) * c + spacing * (c - 1)
			h = MAIMathR(36) * (count / c) + spacing * (count / c - 1)
			_G["ActionBar" .. x]:SetSize(w, h)
		end
	end
	if PetBar then
		count = MAIGV( "PetBar" .. "count" )
		if type(MAIGV( "PetBar" .. "rows" )) and MAIGV( "PetBar" .. "rows" ) == "max" then
			rows = count
		else
			rows = MAIGV( "PetBar" .. "rows" )
		end
		c = count / rows
		spacing = MAIGV( "PetBar" .. "spacing" )
		w = MAIMathR(_G["PetActionButton1"]:GetWidth()) * c + spacing * (c - 1)
		h = MAIMathR(_G["PetActionButton1"]:GetHeight()) * (count / c) + spacing * (count / c - 1)
		if not InCombatLockdown() then
			PetBar:SetSize(w, h)
		end
	end

	MAISV( "StanceBar" .. "row", 0 )
	for x = 1, MAIMAXBAR do
		MAISV( "ActionBar" .. x .. "row", 0 )
	end

	for x = 1, MAIMAXBAR do
		if not MAIGV( "ActionBar" .. x .. "Enabled" ) and _G["ActionBar" .. x] and _G["ActionBar" .. x].hooked == nil then
			_G["ActionBar" .. x].hooked = true
			_G["ActionBar" .. x]:SetParent(MAIHIDDEN)
		end
	end

	MAISV( "PetBar" .. "row", 0 )
	for i = 1, 12 do
		if i > 1 and MAIGV( "StanceBar" .. "Enabled" ) and MAIGV( "StanceBar" .. "move" ) then
			if _G["StanceButton" .. i] ~= nil then
				local cou = 0
				if GetNumShapeshiftForms() > 0 then
					cou = GetNumShapeshiftForms()
				else
					cou = NUM_STANCE_SLOTS
				end
				count = MAIGV( "StanceBar" .. "count" )			
				if type(MAIGV( "StanceBar" .. "rows" )) and MAIGV( "StanceBar" .. "rows" ) == "max" then
					rows = cou
				else
					rows = MAIGV( "StanceBar" .. "rows" )
				end

				local dir = GetFlyOutDirection(rows, MAIGV( "StanceBar" .. "point" ))
				if _G["StanceButton" .. i].hidehooked == nil then
					_G["StanceButton" .. i].hidehooked = true
					_G["StanceButton" .. i]._mai_i = i
					if _G["StanceButton" .. i].hooked == nil then
						_G["StanceButton" .. i].hooked = true
						hooksecurefunc(_G["StanceButton" .. i], "Show", function(self, ...)
							if self._mai_i > MAIGV( "StanceBar" .. "count" ) then
								if self:IsShown() and not InCombatLockdown() then
									self:Hide()
								else
									self:SetAlpha( 0 )
								end
							end
						end)
					end
				end
				if i > MAIGV( "StanceBar" .. "count" ) then
					if _G["StanceButton" .. i]:IsShown() and not InCombatLockdown() then
						_G["StanceButton" .. i]:Hide()
					end
				else
					if not _G["StanceButton" .. i]:IsShown() and not InCombatLockdown() then
						_G["StanceButton" .. i]:Show()
					end
					local cou = 0
					if GetNumShapeshiftForms() > 0 then
						cou = GetNumShapeshiftForms()
					else
						cou = NUM_STANCE_SLOTS
					end			
					
					if i > 1 then
						if (i-1) % (MAIGV( "StanceBar" .. "count" ) / rows) == 0 then
							MAISV( "StanceBar" .. "row", MAIGV( "StanceBar" .. "row" ) + 1 )
							_G["StanceButton" .. i]:ClearAllPoints()
							_G["StanceButton" .. i]:SetPoint("LEFT", _G["StanceButton" .. 1], "RIGHT", -_G["StanceButton" .. 1]:GetWidth(), -(MAIGV( "StanceBar" .. "row" ) * _G["StanceButton" .. 1]:GetHeight() + (MAIGV( "StanceBar" .. "row" )) * MAIGV( "StanceBar" .. "spacing" )))
						else
							_G["StanceButton" .. i]:ClearAllPoints()
							_G["StanceButton" .. i]:SetPoint("LEFT", _G["StanceButton" .. i - 1], "RIGHT", MAIGV( "StanceBar" .. "spacing" ), 0)
						end
					end
					_G["StanceButton" .. 1]:SetAttribute("flyoutDirection", dir)
					_G["StanceButton" .. i]:SetAttribute("flyoutDirection", dir)
				end
			end
		end

		if _G["PetBar"] ~= nil and MAIGV( "PetBar" .. "Enabled" ) and MAIGV( "PetBar" .. "move" ) and i <= 10 then
			if _G["PetActionButton" .. i].hidehooked == nil then
				_G["PetActionButton" .. i].hidehooked = true
				_G["PetActionButton" .. i]._mai_i = i
				if _G["PetActionButton" .. i].hooked == nil then
					_G["PetActionButton" .. i].hooked = true
					hooksecurefunc(_G["PetActionButton" .. i], "Show", function(self, ...)
						if MAIGV( "PetBar" .. "count" ) and self._mai_i > MAIGV( "PetBar" .. "count" ) then
							if self:IsShown() and not InCombatLockdown() then
								self:Hide()
							else
								self:SetAlpha( 0 )
							end
						end
					end)
				end
			end
			if i > MAIGV( "PetBar" .. "count" ) then
				if _G["PetActionButton" .. i]:IsShown() and not InCombatLockdown() then
					_G["PetActionButton" .. i]:Hide()
				end
			else
				if not _G["PetActionButton" .. i]:IsShown() and not InCombatLockdown() then
					_G["PetActionButton" .. i]:Show()
				end
				if type(MAIGV( "PetBar" .. "rows" )) and MAIGV( "PetBar" .. "rows" ) == "max" then
					rows = MAIGV( "PetBar" .. "count" )
				else
					rows = MAIGV( "PetBar" .. "rows" )
				end
				if i > 1 then
					if (i-1) % (MAIGV( "PetBar" .. "count" ) / rows) == 0 then
						MAISV( "PetBar" .. "row", MAIGV( "PetBar" .. "row" ) + 1 )
						_G["PetActionButton" .. i]:ClearAllPoints()
						_G["PetActionButton" .. i]:SetPoint("LEFT", _G["PetActionButton" .. 1], "RIGHT", -_G["PetActionButton" .. 1]:GetWidth(), -(MAIGV( "PetBar" .. "row" ) * _G["PetActionButton" .. 1]:GetHeight() + (MAIGV( "PetBar" .. "row" )) * MAIGV( "PetBar" .. "spacing" )))
					else
						_G["PetActionButton" .. i]:ClearAllPoints()
						_G["PetActionButton" .. i]:SetPoint("LEFT", _G["PetActionButton" .. i - 1], "RIGHT", MAIGV( "PetBar" .. "spacing" ), 0)
					end
				end
			end
		end

		for x = 1, MAIMAXBAR do
			local btnname = "ActionBar" .. x .. "Button"
			if x <= 6 then
				btnname = BINDBARS[x]
			end
			if _G[btnname .. i] ~= nil and MAIGV( "ActionBar" .. x .. "Enabled" ) then

				if MAIGV( "ActionBar" .. x .. "hide" ) and _G[btnname .. i .. "Cooldown"] then
					_G[btnname .. i .. "Cooldown"]:SetDrawBling(false)
				end
				if type(MAIGV( "ActionBar" .. x .. "rows" )) and MAIGV( "ActionBar" .. x .. "rows" ) == "max" then
					rows = MAIGV( "ActionBar" .. x .. "count" )
				else
					rows = MAIGV( "ActionBar" .. x .. "rows" )
				end
				local dir = GetFlyOutDirection(rows, MAIGV( "ActionBar" .. x .. "point" ))
				if _G[btnname .. i].hidehooked == nil then
					_G[btnname .. i].hidehooked = true
					_G[btnname .. i]._mai_i = i
					hooksecurefunc(_G[btnname .. i], "Show", function(self, ...)
						if self._mai_i > MAIGV( "ActionBar" .. x .. "count" ) then
							if self:IsShown() and not InCombatLockdown() then
								self:Hide()
							else
								self:SetAlpha( 0 )
							end
						end
					end)
				end

				if i > MAIGV( "ActionBar" .. x .. "count" ) then
					if _G[btnname .. i]:IsShown() and not InCombatLockdown() then
						_G[btnname .. i]:Hide()
					end
				else
					if not _G[btnname .. i]:IsShown() and not InCombatLockdown() then
						_G[btnname .. i]:Show()
					end
					if i > 1 then
						if (i-1) % (MAIGV( "ActionBar" .. x .. "count" ) / rows) == 0 then
							MAISV( "ActionBar" .. x .. "row", MAIGV( "ActionBar" .. x .. "row" ) + 1 )
							_G[btnname .. i]:ClearAllPoints()
							_G[btnname .. i]:SetPoint("LEFT", _G[btnname .. 1], "RIGHT", -_G[btnname .. 1]:GetWidth(), -(MAIGV( "ActionBar" .. x .. "row" ) * _G[btnname .. 1]:GetHeight() + (MAIGV( "ActionBar" .. x .. "row" )) * MAIGV( "ActionBar" .. x .. "spacing" )))
						else
							_G[btnname .. i]:ClearAllPoints()
							_G[btnname .. i]:SetPoint("LEFT", _G[btnname .. i - 1], "RIGHT", MAIGV( "ActionBar" .. x .. "spacing" ), 0)
						end
					end

					_G[btnname .. 1]:SetAttribute("flyoutDirection", dir)
					_G[btnname .. i]:SetAttribute("flyoutDirection", dir)
				end
			end
		end
	end
end

local ABPositions = {}
function MAIAddActionbarPosition(index, point, parent, relativePoint, x, y)
	ABPositions[index] = {}
	ABPositions[index]["point"] = point
	ABPositions[index]["parent"] = parent
	ABPositions[index]["relativePoint"] = relativePoint
	ABPositions[index]["x"] = x
	ABPositions[index]["y"] = y
end

MAIAddActionbarPosition(1, "BOTTOM", UIParent, "BOTTOM", -(6.5 * (36 + 4) + 4), 8)
MAIAddActionbarPosition(6, "BOTTOM", UIParent, "BOTTOM", -(6.5 * (36 + 4) + 4), 8 + 36 + 8)
MAIAddActionbarPosition(5, "BOTTOM", UIParent, "BOTTOM", 3.3 * (36 + 4) + 4, 8)

MAIAddActionbarPosition(3, "RIGHT", UIParent, "RIGHT", -(8), 0)
MAIAddActionbarPosition(4, "RIGHT", UIParent, "RIGHT", -(8 + 36 + 8), 0)

MAIAddActionbarPosition(2, "BOTTOM", UIParent, "BOTTOM", -(6.5 * (36 + 4) + 4), 8 + 36 + 8 + 36 + 8)

MAIAddActionbarPosition(7, "BOTTOM", UIParent, "BOTTOM", -(6.5 * (36 + 4) + 4), 8 + 36 + 8 + 36 + 8 + 36 + 8)
MAIAddActionbarPosition(8, "BOTTOM", UIParent, "BOTTOM", -(6.5 * (36 + 4) + 4), 8 + 36 + 8 + 36 + 8 + 36 + 8 + 36 + 8)
MAIAddActionbarPosition(9, "BOTTOM", UIParent, "BOTTOM", -(6.5 * (36 + 4) + 4), 8 + 36 + 8 + 36 + 8 + 36 + 8 + 36 + 8 + 36 + 8)

MAIAddActionbarPosition(10, "BOTTOM", UIParent, "BOTTOM", -(6.5 * (36 + 4) + 4), 8 + 36 + 8 + 36 + 8 + 36 + 8 + 36 + 8 + 36 + 8 + 36 + 8)

function MAIActionbarsCheckDefault()
	for i = 1, MAIMAXBAR do
		if MAIGV( "ActionBar" .. i .. "spacing" ) == nil then
			MAISV( "ActionBar" .. i .. "spacing", 8 )
		end

		if (i == 3 or i == 4) and MAIGV( "ActionBar" .. i .. "rows" ) == nil then
			MAISV( "ActionBar" .. i .. "rows", 12 )
		end
		if (i == 5) and MAIGV( "ActionBar" .. i .. "rows" ) == nil then
			MAISV( "ActionBar" .. i .. "rows", 2 )
		end

		if MAIGV( "ActionBar" .. i .. "hidena" ) == nil then
			MAISV( "ActionBar" .. i .. "hidena", false )
		end

		if MAIGV( "ActionBar" .. i .. "hidehk" ) == nil then
			MAISV( "ActionBar" .. i .. "hidehk", false )
		end
	end

	if MAIGV( "StanceBar" .. "rows" ) == nil then
		MAISV( "StanceBar" .. "rows", 1 )
	end
	if MAIGV( "StanceBar" .. "hidena" ) == nil then
		MAISV( "StanceBar" .. "hidena", false )
	end
	if MAIGV( "StanceBar" .. "hidehk" ) == nil then
		MAISV( "StanceBar" .. "hidehk", false )
	end
	for x = 1, MAIMAXBAR do
		if MAIGV( "ActionBar" .. x .. "rows" ) == nil then
			MAISV( "ActionBar" .. x .. "rows", 1 )
		end
	end
	if MAIGV( "PetBar" .. "rows" ) == nil then
		MAISV( "PetBar" .. "rows", 1 )
	end
	if MAIGV( "PetBar" .. "hidena" ) == nil then
		MAISV( "PetBar" .. "hidena", false )
	end
	if MAIGV( "PetBar" .. "hidehk" ) == nil then
		MAISV( "PetBar" .. "hidehk", false )
	end
	if MAIGV( "StanceBar" .. "spacing" ) == nil then
		MAISV( "StanceBar" .. "spacing", 4 )
	end
	for x = 1, MAIMAXBAR do
		if MAIGV( "ActionBar" .. x .. "spacing" ) == nil then
			MAISV( "ActionBar" .. x .. "spacing", 4 )
		end
	end
	if MAIGV( "PetBar" .. "spacing" ) == nil then
		MAISV( "PetBar" .. "spacing", 4 )
	end

	if MAIGV( "StanceBar" .. "count" ) == nil then
		MAISV( "StanceBar" .. "count", 1 )
	end
	for x = 1, MAIMAXBAR do
		if MAIGV( "ActionBar" .. x .. "count" ) == nil then
			MAISV( "ActionBar" .. x .. "count", 12 )
		end
	end
	if MAIGV( "PetBar" .. "count" ) == nil then
		MAISV( "PetBar" .. "count", 10 )
	end
end

local oldcvar = -1
function MAIThinkActionButtons()
	local cvar = tonumber( GetCVar( "alwaysShowActionBars" ) )
	if cvar ~= oldcvar then
		oldcvar = cvar
		for i = 1, MAIMAXBAR do
			local ab = _G[ "ActionBar" .. i ]
			if ab and ab.btns then
				for id, abtn in pairs( ab.btns ) do
					local btnname = abtn:GetName()
					if btnname and _G[btnname .. "FloatingBG"] then
						_G[btnname .. "FloatingBG"]:Show()
					end
					if btnname and _G[btnname .. "NormalTexture"] then
						_G[btnname .. "NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 0.5)
						
						if cvar == 1 then
							_G[btnname]:SetAttribute( "showgrid", 1 )
							_G[btnname .. "NormalTexture"]:Show()
							_G[btnname]:Show()
						elseif cvar == 0 then
							_G[btnname]:SetAttribute( "showgrid", 0 )
							_G[btnname .. "NormalTexture"]:Hide()
						end
					end
				end
			end
		end
	end
	C_Timer.After( 0.1, MAIThinkActionButtons )
end

function MAISetupGryphonLeft()
	GryphonLeft:Show()

	MAIRegisterUIColor(GryphonLeft.texture)
end

function MAISetupGryphonRight()
	GryphonRight:Show()

	MAIRegisterUIColor(GryphonRight.texture)
end

function MAICreateBars()
	MAIActionbarsCheckDefault()

	local ab1 = _G["ActionButton1"]
	if ab1 then
		local size = ab1:GetWidth() * 2.4

		GryphonLeft = CreateFrame( "FRAME", "GryphonLeft", UIParent )
		GryphonLeft:SetSize( size, size )
		GryphonLeft:SetPoint( "CENTER", UIParent, "CENTER" )
		GryphonLeft:SetFrameStrata( "MEDIUM" )
		GryphonLeft:SetFrameLevel( 499 )

		GryphonLeft.texture = GryphonLeft:CreateTexture(nil, "ARTWORK")
		if GryphonLeft.texture then
			GryphonLeft.texture:SetDrawLayer("ARTWORK", 7)
			GryphonLeft.texture:SetAllPoints( GryphonLeft )
			GryphonLeft.texture:SetTexture( 136408 )
		end
		


		GryphonRight = CreateFrame( "FRAME", "GryphonRight", UIParent )
		GryphonRight:SetSize( size, size )
		GryphonRight:SetPoint( "CENTER", UIParent, "CENTER" )
		GryphonRight:SetFrameStrata( "MEDIUM" )
		GryphonRight:SetFrameLevel( 499 )

		GryphonRight.texture = GryphonRight:CreateTexture(nil, "ARTWORK")
		if GryphonRight.texture then
			GryphonRight.texture:SetDrawLayer("ARTWORK", 7)
			GryphonRight.texture:SetAllPoints( GryphonRight )
			GryphonRight.texture:SetTexture( 136408 )
			GryphonRight.texture:SetTexCoord( 1, 0, 0, 1 )
		end



		GryphonLeft:Hide()
		GryphonRight:Hide()
	end

	local id = 1
	for i = 1, MAIMAXBAR do
		local ActionBar = CreateFrame( "FRAME", "ActionBar" .. i, UIParent) --, "SecureHandlerStateTemplate")^
		ActionBar.btns = {}
	
		-- Flyout
		if i == 1 then
			ActionBar.flyoutname = "MainMenuBarArtFrame"
		elseif i == 3 then
			ActionBar.flyoutname = "MultiBarRight"
		elseif i == 4 then
			ActionBar.flyoutname = "MultiBarLeft"
		elseif i == 5 then
			ActionBar.flyoutname = "MultiBarBottomRight"
		elseif i == 6 then
			ActionBar.flyoutname = "MultiBarBottomLeft"
		else
			ActionBar.flyoutname = "ActionBar" .. i
		end

		if MAILoaded and MAIGV( "ActionBar" .. i .. "Enabled" ) then

			if MAIBUILD == "RETAIL" then
				if i == 5 then
					MultiBarBottomRight:Hide()
				elseif i == 6 then
					MultiBarBottomLeft:Hide()
				end
			end
			
			ActionBar:SetMovable(true)
			--ActionBar:SetUserPlaced(true)
			local point = MAIGV( "ActionBar" .. i .. "point" )
			local parent = nil
			local relativePoint = MAIGV( "ActionBar" .. i .. "relativePoint" )
			local ofsx = MAIGV( "ActionBar" .. i .. "ofsx" )
			local ofsy = MAIGV( "ActionBar" .. i .. "ofsy" )
			if point then
				ActionBar:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
			else
				--ActionBar:SetPoint("CENTER", UIParent, "CENTER", -36 * 6, (i - 1) * 40)
				if ABPositions[i] ~= nil then
					point = ABPositions[i]["point"]
					parent = ABPositions[i]["parent"]
					relativePoint = ABPositions[i]["relativePoint"]
					ofsx = ABPositions[i]["x"]
					ofsy = ABPositions[i]["y"]
					ActionBar:SetPoint(point, parent, relativePoint, ofsx, ofsy)
				else
					ActionBar:SetPoint("CENTER", UIParent, "CENTER", -36 * 6, (i - 1) * 40)
				end
			end
			ActionBar:SetSize(12*(36+4), 36)
			
			for j = 1, 12 do
				local btnname = "ActionBar" .. i .. "Button" .. j
				if i <= 6 and i ~= 2 then
					if BINDBARS[i] then
						btnname = BINDBARS[i] .. j
					end

					if _G[btnname].scalehooked == nil then
						_G[btnname].scalehooked = true
						hooksecurefunc(ActionBar, "SetScale", function(s, scale)
							_G[btnname]:SetScale(scale)
						end)
					end
				else
					_G[btnname] = CreateFrame("CheckButton", btnname, ActionBar, "MultiBarButtonTemplate")
					
					_G[btnname]:SetAttribute("action", id)
					_G[btnname]:SetAttribute("useparent-actionpage", true)

					_G[btnname].commandName = "CLICK " .. btnname .. ":LeftButton"
					_G["BINDING_NAME_" .. "CLICK " .. btnname .. ":LeftButton"] = btnname

					--_G[btnname]:SetID(id) -- breaks
					--_G[btnname]:SetAttribute("type", "action")
				end
				if _G[btnname] then
					_G[btnname]:ClearAllPoints()
					if btnname == "ActionButton1" then
						local ab1 = _G["ActionButton1"]
						if ab1.hooked == nil then
							ab1.hooked = true
							hooksecurefunc(ab1, "SetPoint", function(self, ...)
								if self.setpoint then return end
								if self.force then
									self.force = false
									self.setpoint = true
									self:SetMovable(true)
									--self:SetUserPlaced(true)
									self:ClearAllPoints()
									self:SetPoint("TOPLEFT", _G["ActionBar1Mover"], "TOPLEFT", 0, 0)
									self.setpoint = false
								end
							end)
						end
					else
						_G[btnname]:SetPoint("TOPLEFT", ActionBar, "TOPLEFT", (j-1) * (36 + MAIGV( "ActionBar" .. i .. "spacing" )), 0)
					end
					_G[btnname]:SetPoint("TOPLEFT", ActionBar, "TOPLEFT", (j-1) * (36 + MAIGV( "ActionBar" .. i .. "spacing" )), 0)

					_G[btnname]:SetSize(36, 36)
					
					tinsert(ActionBar.btns, _G[btnname])
				else
					MAIERR( btnname .. " not found" )
				end

				id = id + 1
			end
		else
			for j = 1, 12 do
				id = id + 1
			end
		end
	end

	MAIUpdateActionButton()

	MAIThinkActionButtons()
end

function GetFlyOutDirection(rows, point)
	if rows == nil then return end

	if type(rows) == "string" and rows == "max" then -- High |
		if point == "TOPRIGHT" or point == "RIGHT" or point == "BOTTOMRIGHT" then
			return "LEFT"
		end
		return "RIGHT"
	elseif rows < 6 then -- Long _
		if point == "TOPLEFT" or point == "TOP" or point == "TOPRIGHT" then
			return "DOWN"
		end
		return "UP"
	else -- High |
		if point == "TOPRIGHT" or point == "RIGHT" or point == "BOTTOMRIGHT" then
			return "LEFT"
		end
		return "RIGHT"
	end
	return "UP"
end

local once = false
function MAISetupActionButtons()
	function MAIIsExtraBarsEnabled()
		return MAIGV( "ActionBar6" .. "hide" ) or MAIGV( "ActionBar7" .. "hide" ) or MAIGV( "ActionBar8" .. "hide" ) or MAIGV( "ActionBar9" .. "hide" ) or MAIGV( "ActionBar10" .. "hide" )
	end

	if MAIGV( "ActionBar" .. 1 .. "Enabled" ) then
		if ActionBarUpButton and ActionBarDownButton then
			if ActionBarUpButton.hooked == nil then
				ActionBarUpButton.hooked = true
				hooksecurefunc(ActionBarUpButton, "SetPoint", function(self, ...)
					if self.setpoint then return end
					self.setpoint = true
					self:SetMovable(true)
					--self:SetUserPlaced(true)
					if MAIIsExtraBarsEnabled() then
						if self:IsShown() and not InCombatLockdown() then
							self:Hide()
						end
					else
						if not self:IsShown() and not InCombatLockdown() then
							self:Show()
						end
						self:ClearAllPoints()
						if MAIBUILD == "RETAIL" then
							self:SetPoint("TOPLEFT", ActionButton12, "TOPRIGHT", 0, 0)
						else
							self:SetPoint("TOPLEFT", ActionButton12, "TOPRIGHT", 0, 8)
						end
					end
					self:SetMovable(false)
					self.setpoint = false
				end)
			end
			ActionBarUpButton:SetPoint("CENTER", 0, 0)

			if ActionBarDownButton.hooked == nil then
				ActionBarDownButton.hooked = true
				hooksecurefunc(ActionBarDownButton, "SetPoint", function(self, ...)
					if self.setpoint then return end
					self.setpoint = true
					self:SetMovable(true)
					--self:SetUserPlaced(true)
					if MAIIsExtraBarsEnabled() then
						if self:IsShown() and not InCombatLockdown() then
							self:Hide()
						end
					else
						if not self:IsShown() and not InCombatLockdown() then
							self:Show()
						end
						self:ClearAllPoints()
						if MAIBUILD == "RETAIL" then
							self:SetPoint("BOTTOMLEFT", ActionButton12, "BOTTOMRIGHT", 0, 0)
						else
							self:SetPoint("BOTTOMLEFT", ActionButton12, "BOTTOMRIGHT", 0, -8)
						end
					end
					self:SetMovable(false)
					self.setpoint = false
				end)
			end
			ActionBarDownButton:SetPoint("CENTER", 0, 0)
		end

		if MainMenuBarArtFrame.PageNumber then
			if MainMenuBarArtFrame.PageNumber.hooked == nil then
				MainMenuBarArtFrame.PageNumber.hooked = true
				hooksecurefunc(MainMenuBarArtFrame.PageNumber, "SetPoint", function(self, ...)
					if self.setpoint then return end
					self.setpoint = true
					if MAIIsExtraBarsEnabled() then
						if self:IsShown() and not InCombatLockdown() then
							self:Hide()
						end
						if ActionBarUpButton:IsShown() and not InCombatLockdown() then
							ActionBarUpButton:Hide()
						end
						if ActionBarDownButton:IsShown() and not InCombatLockdown() then
							ActionBarDownButton:Hide()
						end
					else
						if not self:IsShown() and not InCombatLockdown() then
							self:Show()
						end
						if not ActionBarUpButton:IsShown() and not InCombatLockdown() then
							ActionBarUpButton:Show()
						end
						if not ActionBarDownButton:IsShown() and not InCombatLockdown() then
							ActionBarDownButton:Show()
						end
						self:ClearAllPoints()
						self:SetPoint("LEFT", ActionButton12, "RIGHT", 26, 0)
					end
					self.setpoint = false
				end)
			end
			MainMenuBarArtFrame.PageNumber:SetPoint("CENTER", 0, 0)
		elseif MainMenuBarPageNumber then
			if MainMenuBarPageNumber.hooked == nil then
				MainMenuBarPageNumber.hooked = true
				hooksecurefunc(MainMenuBarPageNumber, "SetPoint", function(self, ...)
					if self.setpoint then return end
					self.setpoint = true
					if MAIIsExtraBarsEnabled() then
						if self:IsShown() and not InCombatLockdown() then
							self:Hide()
						end
					else
						if not self:IsShown() and not InCombatLockdown() then
							self:Show()
						end
						self:ClearAllPoints()
						self:SetPoint("LEFT", ActionButton12, "RIGHT", 30, 0)
					end
					self.setpoint = false
				end)
			end
			MainMenuBarPageNumber:SetPoint("CENTER", 0, 0)
		end
	end

	MAIUpdateActionButton()

	-- Masque
	if once == false then
		once = true
		local MSQ = LibStub("Masque", true)

		if MSQ then
			MSQ:Register("MAI Blizzard Action Bars", function() end, {})

			local MAIMasqueGroups = {}
			MAIMasqueGroups.Groups = {}

			for i, v in pairs(MAIAB) do
				local btn = _G[v]
				if btn then
					if _G[v .. "FloatingBG" ] then
						_G[v .. "FloatingBG"]:SetParent(MAIHIDDEN)
					end
					local parent = btn:GetParent():GetName()
					local group = nil
					if MAIMasqueGroups.Groups["MAI " .. parent] == nil then
						MAIMasqueGroups.Groups["MAI " .. parent] = MSQ:Group("MAI Blizzard Action Bars", "MAI " .. parent)
					end
					group = MAIMasqueGroups.Groups["MAI " .. parent]
					if not btn.MasqueButtonData then
						btn.MasqueButtonData = {
							Button = btn,
							Icon = _G[v .. "IconTexture"],
						}
					end
					group:AddButton(btn, btn.MasqueButtonData, "Item")
				end
			end
		end
	end
end

PetBar = CreateFrame( "FRAME", "PetBar", UIParent)
PetBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 100)
PetBar:EnableMouse(false)
PetBarThinker = CreateFrame( "FRAME", "PetBarThinker", UIParent)

function MAISetupPetbar()
	PetBar:SetSize(PetActionButton1:GetWidth() * 12, PetActionButton1:GetHeight())
	PetBar:SetPoint("CENTER", UIParent, "CENTER")
	for i = 1, 10 do
		local petbtn = _G["PetActionButton" .. i]
		petbtn:SetParent(PetBar)
		if i == 1 then
			if petbtn.hooked == nil then
				petbtn.hooked = true
				hooksecurefunc(petbtn, "SetPoint", function(self, ...)
					if self.setpoint then return end
					self.setpoint = true
					self:ClearAllPoints()
					self:SetPoint("TOPLEFT", PetBar, "TOPLEFT", (i - 1) * self:GetWidth(), 0)
					self.setpoint = false
				end)
			end
		end

		petbtn:ClearAllPoints()
		petbtn:SetPoint("LEFT", PetBar, "LEFT", (i - 1) * petbtn:GetWidth(), 0)
	end

	function PetBarThinker.Think()
		if PetBarThinker.exists ~= UnitExists("pet") then
			PetBarThinker.exists = UnitExists("pet")

			if not UnitExists("pet") then
				PetBar:SetAlpha(0)
				for i = 1, 10 do
					local petbtn = _G["PetActionButton" .. i]
					petbtn:SetAlpha(0)
				end
			else
				PetBar:SetAlpha(1)
				for i = 1, 10 do
					local petbtn = _G["PetActionButton" .. i]
					petbtn:SetAlpha(1)
				end
			end
		end
		C_Timer.After(0.5, PetBarThinker.Think)
	end
	PetBarThinker.Think()

	if PetActionBarFrame then
		PetActionBarFrame:SetParent(MAIHIDDEN)
	end

	MAIUpdateActionButton()
end
