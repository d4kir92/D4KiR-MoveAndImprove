-- By D4KiR

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

MAIVERSION = "2022.08.19-13:40"

FLATBORDER = 0.068
local MAICOLORBACKGROUNDHEADER = 	{0.2, 0.2, 0.2, 0.7}
local MAICOLORBACKGROUND = 			{0.0, 0.0, 0.0, 0.7}



MAIDEBUG = false



function MAICheckIfSame(src, dest)
	if dest == nil then
		return true
	end
	for i, v in pairs(src) do
		if src[i] ~= nil and dest[i] ~= nil and src[i] ~= dest[i] and i ~= "ILVL" and i ~= "XPTAB" and i ~= "menu" and i ~= "toggler" then
			if type(src[i]) == "number" and type( dest[i] ) == "number" then
				if MAIMathR(src[i], 1) ~= MAIMathR(dest[i], 1) then
					print("MAICheckIfSame NUM:", i, v, src[i], dest[i])
					return false
				end
			elseif i ~= "mmicon" and i ~= "CLASSES" and not strfind( i, "parent" ) then
				print("MAICheckIfSame", i, v, src[i], dest[i])
				return false
			end
		end
	end
	return true
end

function MAICopy_Table(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[MAICopy_Table(orig_key)] = MAICopy_Table(orig_value)
		end
		setmetatable(copy, MAICopy_Table(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function MAICreateSlider(parent, name, key, vval, x, y, vmin, vmax, steps, form, lstr)
	local SL = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")

	SL:SetWidth( parent:GetWidth() - 30 )
	SL:SetPoint("TOPLEFT", x + 5, y)

	SL.Low:SetText(vmin)
	SL.High:SetText(vmax)

	SL.Text:SetText(MAIGT(lstr) .. ": " .. MAIGV( name .. key, vval ) )

	SL:SetMinMaxValues(vmin, vmax)
	SL:SetObeyStepOnDrag(true)
	SL:SetValueStep(steps)

	SL:SetValue(  MAIGV( name .. key, vval ) )

	SL:SetScript("OnValueChanged", function(self, val)
		--val = val - val % steps
		val = tonumber(string.format("%" .. form, val))
		if val and val ~= MAIGV( name .. key ) then
			if key == "count" then
				MAISV( name .. "rows", 1 )
				LibDD:UIDropDownMenu_SetText( _G[name .. "rowscb"], MAIGV( name .. "rows" ) )
			end
			MAISV( name .. key, val )
			SL.Text:SetText(MAIGT(lstr) .. ": " .. val)

			MAIUpdateActionButton()
			if MAIUpdateMAIMicroButtons then
				MAIUpdateMAIMicroButtons()
			end
		end
	end)

	return SL
end

function MAIAddChatCheckBox( name, value, x, y )
	if MAIGV( "ChatFrame1" .. name ) == nil then
		MAISV( "ChatFrame1" .. name, value )
	end
	local cb = CreateFrame("CheckButton", name, MAIMENU, "ChatConfigCheckButtonTemplate")
	cb:SetSize(20, 20)
	cb:SetPoint("TOPLEFT", x, y)
	cb:SetChecked(MAIGV( "ChatFrame1" .. name ) )
	cb:SetScript("OnClick", function(self)
		MAISV( "ChatFrame1" .. name, not MAIGV( "ChatFrame1" .. name ) )
	end)
	local function MAIUpdateChatCheckbox()
		self = cb
		if self:GetChecked() ~= MAIGV( "ChatFrame1" .. name ) then
			self:SetChecked(MAIGV( "ChatFrame1" .. name ) )
			MAIUpdateChatChannels()
		end
		C_Timer.After( 0.1, MAIUpdateChatCheckbox )
	end
	MAIUpdateChatCheckbox()
	cb.text = cb:CreateFontString(nil, "ARTWORK")
	cb.text:SetFont(STANDARD_TEXT_FONT, 10, "")
	cb.text:SetPoint("LEFT", cb, "RIGHT", 0, 0)
	cb.text:SetText(MAIGT(name))
	if MAIGV( "nochanges" ) then
		cb:SetChecked( false )
		cb:Disable()
		cb.text:SetTextColor( 0.4, 0.4, 0.4, 1 )
	end
end

local maiuicolortab = {}

function MAIGetUIColor()
	if MAIGV( "MAIUIColorR" ) ~= nil and MAIGV( "MAIUIColorG" ) ~= nil and MAIGV( "MAIUIColorB" ) ~= nil and not MAIGV( "nochanges" ) then
		return MAIGV( "MAIUIColorR" ), MAIGV( "MAIUIColorG" ), MAIGV( "MAIUIColorB" )
	else
		return 1, 1, 1
	end
end

function MAIRegisterUIColor( ele )
	if MAIGV( "UIColorEnabled", true ) then
		if not MAIGV( "nochanges" ) then
			tinsert( maiuicolortab, ele )
			ele:SetVertexColor( MAIGetUIColor() )
		end
	end
end

function MAIUIColorUpdate()
	if MAIGV( "UIColorEnabled", true ) then
		for i, v in pairs( maiuicolortab ) do
			v:SetVertexColor( MAIGetUIColor() )
		end
	end
end

local maiframecolortab = {}
function MAIGetFrameColor()
	if MAIGV( "MAIFrameColorR" ) ~= nil and MAIGV( "MAIFrameColorG" ) ~= nil and MAIGV( "MAIFrameColorB" ) ~= nil and not MAIGV( "nochanges" ) then
		return MAIGV( "MAIFrameColorR" ), MAIGV( "MAIFrameColorG" ), MAIGV( "MAIFrameColorB" )
	else
		return 1, 1, 1
	end
end

function MAIRegisterFrameColor( ele )
	if MAIGV( "FrameColorEnabled", true ) then
		if not MAIGV( "nochanges" ) then
			tinsert( maiframecolortab, ele )
			ele:SetVertexColor( MAIGetFrameColor() )
		end
	end
end

function MAIFrameColorUpdate()
	if MAIGV( "FrameColorEnabled", true ) then
		for i, v in pairs( maiframecolortab ) do
			v:SetVertexColor( MAIGetFrameColor() )
		end
	end
end

local MAINL = 0
local MAIStanceBar = CreateFrame( "FRAME", "MAIStanceBar", StanceBar)
MAIStanceBar:SetSize(30, 30)
MAIStanceBar:SetPoint("BOTTOMLEFT", StanceBar, "BOTTOMLEFT", 0, 0)

if false then
	MAIStanceBar.texture = MAIStanceBar:CreateTexture(nil, "BACKGROUND")
	MAIStanceBar.texture:SetAllPoints(MAIStanceBar)
	MAIStanceBar.texture:SetColorTexture(0, 1, 0, 0.5)
end

function MAIIsSpellKnown( spellid, from )
	if spellid then
		return IsSpellKnown( spellid )
	else
		if from ~= "spellstate 2.1" and from ~= "MAIThink" then
			print("[MAI] |cFFFF0000NO SPELLID IN MAIIsSpellKnown|r" .. ": " .. from, spellid)
		end
		return false
	end
end

function MAIUpdateStanceBarSize()
	local maxw = 0
	local btns = 0
	local hr = 0
	local nl = 0

	local list = {}
	local x = 1
	local y = 1
	for i = 1, 40 do
		local b = _G["MAIStanceButton" .. i]
		if b and b.spellid1 and MAIIsSpellKnown(b.spellid1, "MAIUpdateStanceBarSize 1") then
			list[y] = list[y] or {}
			list[y] = x
			if b.nl then
				y = y + 1
			end
			x = x + 1
		end
	end

	local dir = "RIGHT"
	for i = 1, 40 do
		local b = _G["MAIStanceButton" .. i]
		if b then
			if (not b.allclassesplus or (b.allclassesplus and MAIGV( "StanceBar" .. "allclassesplus"  ))) then
				if b.spellid1 and MAIIsSpellKnown(b.spellid1, "MAIUpdateStanceBarSize 2" ) then
					if b.hr then
						hr = hr + 1
					end
					if b.nl then
						nl = nl + 1
						btns = 0
					end
					
					local ofsx = 0
					local ofsy = MAINL + nl * (30 + MAIGV( "StanceBar" .. "spacing" ))
					if dir == "RIGHT" then
						ofsx = btns * 30 + btns * MAIGV( "StanceBar" .. "spacing" ) + hr * MAIGV( "StanceBar" .. "spacing" )
					end
					b:SetPoint("BOTTOMLEFT", ofsx, ofsy)

					btns = btns + 1
					if btns > maxw then
						maxw = btns
					end
				end
			end
		else
			break
		end
	end

	local sw = 30 * maxw + MAIGV( "StanceBar" .. "spacing" ) * (maxw - 1) + hr * MAIGV( "StanceBar" .. "spacing" )
	local sh = 30 + nl * (30 + MAIGV( "StanceBar" .. "spacing" ))

	local localizedClass, englishClass, classIndex = UnitClass("PLAYER")
	if englishClass == "HUNTER" or englishClass == "SHAMAN" or englishClass == "MAGE" or englishClass == "WARLOCK" then
		StanceBar:SetSize(sw, sh)
	end
	MAIStanceBar:SetSize(sw, sh)
end
-- LIBS



-- OUTPUT
function MAIMSGS()
	print(" ")
end

function MAIMSG( str, ... )
	print("|cFFAAAAFF[MAI] |r" .. tostring( str ), ...)
end

function MAIERR( str, ... )
	print("|cFFAAAAFF[MAI v" .. MAIVERSION .. "-|cffff0000ERROR|cFFAAAAFF] |cffff0000" .. tostring( str ), ...)
end
-- OUTPUT



MAITHINKER = CreateFrame( "FRAME", "MAITHINKER", UIParent)
MAITHINKER.tab = {}
MAITHINKER.frames = {}

MAIMENU = CreateFrame( "FRAME", "MAIMENU", UIParent)

MAIMENUMOVING = CreateFrame( "FRAME", "MAIMENUMOVING", UIParent)

-- ELEMENTS
local ELEMENTS = {}
local ELENAMES = {}
local NOTGOOD = {}
local NOCHANGES = {}
function MAIAddElement(tab)
	--if _G[tab.name] == nil then
		--print(tab.name)
		--return
	--else
		tinsert(ELENAMES, tab.name)
	--end
	if tab.name == nil then
		MAIERR("[MAIAddElement] FAILED: No Name specified")
		return
	end
	if tab.lstr == nil then
		MAIERR("[MAIAddElement] No Translation specified for: " .. tab.name)
		return
	end

	local element = {}
	element.name = tab.name
	element.lstr = tab.lstr
	element.sw = tab.sw
	element.sh = tab.sh
	element.setup = tab.setup
	element.setmovable = tab.setmovable
	element.setuserplaced = tab.setuserplaced
	element.anchor = tab.anchor or "CENTER"
	element.forcedrag = tab.forcedrag
	element.notgood = tab.notgood
	element.nochanges = tab.nochanges or false

	if tab.notgood then
		NOTGOOD[tab.name] = true
	end
	if tab.nochanges then
		NOCHANGES[tab.name] = true
	end

	tinsert(ELEMENTS, element)
end
-- ELEMENTS

local once = false
function MAISetupMainMenuBarVehicleLeaveButton()
	MainMenuBarVehicleLeaveButton:SetParent(UIParent)
end

function MAISetupPlayerPowerBarAlt()
	function UnitPowerBarAltStatus_UpdateText(self)
		local powerBar = self:GetParent();
		if powerBar.displayedValue and self:IsShown() then
			TextStatusBar_UpdateTextStringWithValues(self, self.text, floor(powerBar.displayedValue), powerBar.minPower, powerBar.maxPower);
		end
	end
	function UnitPowerBarAltStatus_ToggleFrame(self)
		if PlayerPowerBarAlt:IsShown() then
			self:Show();
			UnitPowerBarAltStatus_UpdateText(self);
		end
	end
	UnitPowerBarAltStatus_ToggleFrame(PlayerPowerBarAltStatusFrame)
	
	if MAIGV( "PlayerPowerBarAlt" .. "hideartwork" ) then
		PlayerPowerBarAlt.frame.Show = PlayerPowerBarAlt.frame.Hide
		PlayerPowerBarAlt.frame:Hide()
	end
end

MAIMoneyBar = CreateFrame( "FRAME", "MAIMoneyBar", UIParent )
MAIMoneyBar:SetSize( 180, 20 )
MAIMoneyBar:SetPoint( "CENTER" )

function MAISetupMAIMoneyBar()
	MAIMoneyBar.text = MAIMoneyBar:CreateFontString(nil, "ARTWORK")
	MAIMoneyBar.text:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
	MAIMoneyBar.text:SetPoint("CENTER", MAIMoneyBar, "CENTER", 0, 0)
	MAIMoneyBar.text:SetText(GetCoinTextureString(GetMoney()))

	MAIMoneyBar:RegisterEvent("PLAYER_MONEY")
	MAIMoneyBar:SetScript("OnEvent", function(self, ...)
		MAIMoneyBar.text:SetText( GetCoinTextureString( GetMoney() ) )
	end)

	if MAIBUILD ~= "RETAIL" then
		GOLD_AMOUNT_SYMBOL = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t"
		SILVER_AMOUNT_SYMBOL = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t"
		COPPER_AMOUNT_SYMBOL = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t"
	end
end

local FACTION_HORDE = 0
local FACTION_ALLIANCE = 1
local spirittime = nil

function MAISetupUIWidgetTopCenterContainerFrame()
	UIWidgetTopCenterContainerFrame.textHorde = UIWidgetTopCenterContainerFrame:CreateFontString(nil, "ARTWORK")
	UIWidgetTopCenterContainerFrame.textHorde:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
	UIWidgetTopCenterContainerFrame.textHorde:SetPoint("TOP", UIWidgetTopCenterContainerFrame, "TOP", 144, -10)
	UIWidgetTopCenterContainerFrame.textHorde:SetText("")

	UIWidgetTopCenterContainerFrame.textAllia = UIWidgetTopCenterContainerFrame:CreateFontString(nil, "OVERLAY")
	UIWidgetTopCenterContainerFrame.textAllia:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
	UIWidgetTopCenterContainerFrame.textAllia:SetPoint("TOP", UIWidgetTopCenterContainerFrame, "TOP", -144, -10)
	UIWidgetTopCenterContainerFrame.textAllia:SetText("")

	UIWidgetTopCenterContainerFrame.textSpiri = UIWidgetTopCenterContainerFrame:CreateFontString(nil, "OVERLAY")
	UIWidgetTopCenterContainerFrame.textSpiri:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
	UIWidgetTopCenterContainerFrame.textSpiri:SetPoint("TOP", UIWidgetTopCenterContainerFrame, "TOP", 0, 16)
	UIWidgetTopCenterContainerFrame.textSpiri:SetText("")

	function MAIThinkBG()
		if UnitInBattleground("PLAYER") then
			RequestBattlefieldScoreData()

			local _, _, _, _, numHorde = GetBattlefieldTeamInfo(FACTION_HORDE)
			local _, _, _, _, numAlliance = GetBattlefieldTeamInfo(FACTION_ALLIANCE)
		
			UIWidgetTopCenterContainerFrame.textHorde:SetText("H " .. numHorde)
			UIWidgetTopCenterContainerFrame.textAllia:SetText("A " .. numAlliance)
			
			if spirittime then
				UIWidgetTopCenterContainerFrame.textSpiri:SetText( tonumber(string.format("%." .. 0 .. "f", spirittime)))
			end

			if GetAreaSpiritHealerTime() >= 1 then
				spirittime = GetAreaSpiritHealerTime()
			elseif spirittime then
				spirittime = spirittime - 0.1
				if spirittime <= 0 then
					spirittime = 30
				end
			end

			if PVPMatchScoreboard then
				if GetUnitSpeed("PLAYER") > 0 then
					PVPMatchScoreboard:SetAlpha(0.5)
				else
					PVPMatchScoreboard:SetAlpha(1)
				end
			end
			C_Timer.After(0.1, MAIThinkBG)
		else
			UIWidgetTopCenterContainerFrame.textHorde:SetText("")
			UIWidgetTopCenterContainerFrame.textAllia:SetText("")
			UIWidgetTopCenterContainerFrame.textSpiri:SetText("")

			C_Timer.After(1, MAIThinkBG)
		end
	end
	MAIThinkBG()
end

function MAISetupGroupLootFrame()
	for i = 2, 4 do
		local lf = _G["GroupLootFrame" .. i]

		-- Position
		hooksecurefunc(lf, "SetPoint", function(self, ...)
			if self.setpoint then return end
			self.setpoint = true
			self:ClearAllPoints()
			self:SetPoint("BOTTOM", _G["GroupLootFrame" .. i - 1], "TOP", 0, 3)
			self.setpoint = false
		end)
		lf:SetPoint("BOTTOM")

		-- SCALE
		hooksecurefunc(lf, "SetScale", function(self, ...)
			if self.setscale then return end
			self.setscale = true
			self:SetScale(_G["GroupLootFrame" .. i - 1]:GetScale())
			self.setscale = false
		end)
		lf:SetScale(1)
	end
end

local MAIFRAMES = {}
tinsert(MAIFRAMES, {
	"GameMenuFrame",
	1
})
tinsert(MAIFRAMES, {
	"InterfaceOptionsFrame",
	1
})
tinsert(MAIFRAMES, {
	"QuickKeybindFrame",
	1
})
tinsert(MAIFRAMES, {
	"VideoOptionsFrame",
	1
})
tinsert(MAIFRAMES, {
	"KeyBindingFrame",
	1
})
tinsert(MAIFRAMES, {
	"MacroFrame",
	1
})
tinsert(MAIFRAMES, {
	"AddonList",
	1
})

tinsert(MAIFRAMES, {
	"ContainerFrame" .. 1,
	1,
	true,
	nil,
	true
})
for i = 2, 5 do
	tinsert(MAIFRAMES, {
		"ContainerFrame" .. i,
		1,
		true,
		"ContainerFrame" .. i - 1,
		true
	})
end

tinsert(MAIFRAMES, {
	"LFGParentFrame",
	1
})
tinsert(MAIFRAMES, {
	"LootFrame",
	1
})
tinsert(MAIFRAMES, {
	"CharacterFrame",
	1
})
tinsert(MAIFRAMES, {
	"InspectFrame",
	1
})
tinsert(MAIFRAMES, {
	"SpellBookFrame",
	1
})
tinsert(MAIFRAMES, {
	"PlayerTalentFrame",
	1
})
tinsert(MAIFRAMES, {
	"FriendsFrame",
	1
})
tinsert(MAIFRAMES, {
	"HelpFrame",
	1
})
tinsert(MAIFRAMES, {
	"TradeSkillFrame",
	1
})
tinsert(MAIFRAMES, {
	"QuestLogFrame",
	1
})
tinsert(MAIFRAMES, {
	"WorldMapFrame",
	1
})
tinsert(MAIFRAMES, {
	"ChallengesKeystoneFrame",
	1
})
tinsert(MAIFRAMES, {
	"CovenantMissionFrame",
	1
})
tinsert(MAIFRAMES, {
	"OrderHallMissionFrame",
	1
})
tinsert(MAIFRAMES, {
	"PVPMatchScoreboard",
	1
})
tinsert(MAIFRAMES, {
	"GossipFrame",
	1
})
tinsert(MAIFRAMES, {
	"MerchantFrame",
	1
})
tinsert(MAIFRAMES, {
	"PetStableFrame",
	1
})
tinsert(MAIFRAMES, {
	"QuestFrame",
	1
})
tinsert(MAIFRAMES, {
	"ClassTrainerFrame",
	1
})
tinsert(MAIFRAMES, {
	"AchievementFrame",
	1
})
tinsert(MAIFRAMES, {
	"CommunitiesFrame",
	1
})
tinsert(MAIFRAMES, {
	"PVEFrame",
	1
})
tinsert(MAIFRAMES, {
	"EncounterJournal",
	1
})
--[[tinsert(MAIFRAMES, {
	"CollectionsJournal",
	1
})]]
tinsert(MAIFRAMES, {
	"WeeklyRewardsFrame",
	1
})
tinsert(MAIFRAMES, {
	"BankFrame",
	1
})
if MAIBUILD ~= "RETAIL" then
	tinsert(MAIFRAMES, {
		"WardrobeFrame",
		1
	})
end
tinsert(MAIFRAMES, {
	"DressUpFrame",
	1
})
tinsert(MAIFRAMES, {
	"MailFrame",
	1
})
tinsert(MAIFRAMES, {
	"OpenMailFrame",
	1
})
tinsert(MAIFRAMES, {
	"AuctionHouseFrame",
	1
})
tinsert(MAIFRAMES, {
	"AnimaDiversionFrame",
	1
})
tinsert(MAIFRAMES, {
	"CovenantSanctumFrame",
	1
})
tinsert(MAIFRAMES, {
	"SoulbindViewer",
	1
})
tinsert(MAIFRAMES, {
	"GarrisonLandingPage",
	1
})
tinsert(MAIFRAMES, {
	"PlayerChoiceFrame",
	1,
	true
})

local currentFrame = nil
local currentFrameName = nil
local scaler = CreateFrame("FRAME")
scaler:SetScript("OnUpdate", function()
	if currentFrame and not currentFrame:IsShown() then
		currentFrame:SetAlpha(1)
		currentFrame = nil
		currentFrameName = nil
		GameTooltip:Hide()
	end
	if currentFrame then		
		local curMouseX, curMouseY = GetCursorPosition()

		-- Only try to scale once there was at least one previous position
		if scaler.prevMouseX and scaler.prevMouseY then
			if curMouseY > scaler.prevMouseY then
				-- Add to scale
				local newScale = math.min(
					currentFrame:GetScale() + 0.006,
					1.5
				)

				-- Scale
				currentFrame:SetScale(newScale)
				MAISV( currentFrameName .. "scale", newScale )
			elseif curMouseY < scaler.prevMouseY then
				-- Subtract from scale
				local newScale = math.max(
					currentFrame:GetScale() - 0.006,
					0.5
				)

				-- Scale
				currentFrame:SetScale(newScale)
				MAISV( currentFrameName .. "scale", newScale )
			end
		end

		GameTooltip:SetOwner(currentFrame)
		GameTooltip:SetText(math.floor( currentFrame:GetScale() * 100 ) .. "%")

		-- Update previous mouse position
		scaler.prevMouseX = curMouseX
		scaler.prevMouseY = curMouseY
	end
end)

local frameinit = {}
function MAIMoveFrames()
	if not InCombatLockdown() then
		local allsetup = true
		for i, mf in pairs(MAIFRAMES) do
			local name = mf[1]
			local frame = _G[name]
			local scale = mf[2]
			local dontscale = mf[3]
			local mainparent = mf[4]
			if frame and frameinit[name] == nil then
				frameinit[name] = true
				if scale ~= 1 then
					frame:SetScale(scale)
				end
				if MAIGV( name .. "Enabled" ) then
					frame:SetMovable(true)
					frame:SetUserPlaced( false )
					frame:EnableMouse(true)
					frame:SetClampedToScreen(true)
					frame:RegisterForDrag("LeftButton", "RightButton")
					--frame:SetResizable(true)
					frame:SetScript( "OnDragStart", function(self, btn)
						frame:SetUserPlaced( false )

						frame:SetAlpha(0.34)

						frame.ismoving = true
						if btn == "RightButton" then
							--frame:RegisterForDrag("RightButton")

							frame.iscaling = true
							
							currentFrame = frame
							currentFrameName = name

							frame.prevMouseX = nil
							frame.prevMouseY = nil
							
							GameTooltip:Hide()

							--[[
							MAISV( name .. "scale", 1 )
							frame:SetScale( MAIGV( name .. "scale" ) )

							MAISV( mf[1] .. "point", nil )
							MAISV( mf[1] .. "parent", nil )
							MAISV( mf[1] .. "relativePoint", nil )
							MAISV( mf[1] .. "ofsx", nil )
							MAISV( mf[1] .. "ofsy", nil )

							MAIMSG( "RESETTED", name, ", please reload" )]]
						elseif btn == "LeftButton" then
							if not InCombatLockdown() then
								--frame:RegisterForDrag("LeftButton")
								self:StartMoving()
							end
						--elseif btn == "LeftButton" then
							--MAIMSG( MAIGT("draghelp") )
						end
					end)

					function frame:UpdateValues()
						if not InCombatLockdown() then
							if frame:GetLeft() then
								frame.x = frame:GetLeft() 
								frame.y = (frame:GetTop() - frame:GetHeight()) 

								MAISV( mf[1] .. "point", "BOTTOMLEFT" )
								MAISV( mf[1] .. "parent", "UIParent" )
								MAISV( mf[1] .. "relativePoint", "BOTTOMLEFT" )
								MAISV( mf[1] .. "ofsx", frame.x )
								MAISV( mf[1] .. "ofsy", frame.y )
								
								frame:ClearAllPoints()
								frame:SetPoint( MAIGV( mf[1] .. "point"), MAIGV( mf[1] .. "parent"), MAIGV( mf[1] .. "relativePoint"), MAIGV( mf[1] .. "ofsx"), MAIGV( mf[1] .. "ofsy") )
							else
								C_Timer.After( 0.01, frame.UpdateValues )
							end
						end
					end

					frame:SetScript("OnDragStop", function(self)
						frame:SetAlpha(1)

						if frame.ismoving then
							frame.ismoving = false
							frame:StopMovingOrSizing()
							frame:UpdateValues()

							frame:SetUserPlaced( false )

							if strfind(name, "ContainerFrame") == 1 then
								C_UI.Reload()
							end
						end
						if frame.isscaling then
							frame.isscaling = false
						end
						currentFrame = nil
						currentFrameName = nil
					end)

					hooksecurefunc(frame, "SetPoint", function( self, ... )
						if self.setpoint then return end
						self.setpoint = true
						if not InCombatLockdown() then
							if MAIGV( mf[1] .. "parent" ) == nil then
								MAISV( mf[1] .. "parent", UIParent )
							end

							if MAIGV( mf[1] .. "point" ) and MAIGV( mf[1] .. "relativePoint" ) and self:GetPoint() then
								self:ClearAllPoints()
								if type(MAIGV( mf[1] .. "parent" )) == "table" then
									MAISV( mf[1] .. "parent", "UIParent" )
								end
								self:SetPoint( MAIGV( mf[1] .. "point" ), MAIGV( mf[1] .. "parent" ), MAIGV( mf[1] .. "relativePoint" ), MAIGV( mf[1] .. "ofsx" ), MAIGV( mf[1] .. "ofsy" ) )
							end
						end
						self.setpoint = false
					end )

					if not dontscale and MAIGV( name .. "Scale" ) then
						if MAIGV( name .. "scale" ) then
							if frame:GetHeight() * MAIGV( name .. "scale" ) > GetScreenHeight() then
								MAISV( name .. "scale", GetScreenHeight() / frame:GetHeight() )
								frame:SetScale( MAIGV( name .. "scale" ) )
							end
							frame:SetScale( MAIGV( name .. "scale" ) )
						else
							frame:SetScale( 1 )
						end
					end

					local p1, p2, p3, p4, p5 = frame:GetPoint()
					if frame.GetPoint and frame:GetPoint() then
						frame:ClearAllPoints()
						frame:SetPoint(p1, p2, p3, p4, p5)
					end

					frame.maialpha = 1
					function frame:MAIThink()
						if MouseIsOver( frame ) or GetUnitSpeed( "PLAYER" ) == 0 or UnitOnTaxi( "PLAYER" ) then
							frame.maialpha = MAIMathC( frame.maialpha + 0.05, 0.34, 1 )
						elseif not MAIGV( "nochanges" ) and MAIGV( "frametransparency", true ) then
							frame.maialpha = MAIMathC( frame.maialpha - 0.05, 0.34, 1 )
						end
						frame:SetAlpha( frame.maialpha )

						C_Timer.After( 0.01, frame.MAIThink )
					end
					frame:MAIThink()
				end

				if WorldMapFrame and WorldMapFrame.GetName and WorldMapFrame:GetName() == mf[1] then
					if WorldMapFrame.ScrollContainer.Child.TiledBackground then
						WorldMapFrame.ScrollContainer.Child.TiledBackground:Hide()
					end
					WorldMapFrame.BlackoutFrame.Show = WorldMapFrame.BlackoutFrame.Hide
					WorldMapFrame.BlackoutFrame:Hide()

					WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
						local x,y = MapCanvasScrollControllerMixin.GetCursorPosition(f);
						local s = WorldMapFrame:GetScale();
						return x/s, y/s;
					end

					if MAIBUILD ~= "RETAIL" then -- TBC, ERA
						WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", function(self, delta)
							local x, y = self:GetNormalizedCursorPosition()
							local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange()
							if delta == 1 then
								if nextZoomInScale > self:GetCanvasScale() then
									self:InstantPanAndZoom( nextZoomInScale, x, y )
								end
							else
								if nextZoomOutScale < self:GetCanvasScale() then
									self:InstantPanAndZoom( nextZoomOutScale, x, y )
								end
							end
						end)
					end
				end
			else
				allsetup = false
			end
		end
		if not allsetup then
			C_Timer.After(0.1, MAIMoveFrames)
		end
	else
		C_Timer.After(0.1, MAIMoveFrames)
	end
end

-- ELEMENTS
function MAIGetElementList()
	MAIAddElement(
		{
			["name"] = "minimapbuttons",
			["lstr"] = "minimapbuttons",
			["setup"] = MAISetupMinimapButtons,
			["sw"] = 30 * 6,
			["sh"] = 30 * 2,
			["nochanges"] = true
		}
	)

	MAIAddElement(
		{
			["name"] = "Minimap",
			["lstr"] = MINIMAP_LABEL,
			["setup"] = MAISetupMinimap
		}
	)
	
	MAIAddElement(
		{
			["name"] = "PlayerFrame",
			["lstr"] = "playerframe",
			["setmovable"] = true,
			["setuserplaced"] = true,
			["setup"] = MAISetupPlayerFrame
		}
	)
	MAIAddElement(
		{
			["name"] = "TargetFrame",
			["lstr"] = "targetframe",
			["setmovable"] = true,
			["setuserplaced"] = true,
			["setup"] = MAISetupTargetFrame
		}
	)
	MAIAddElement(
		{
			["name"] = "TargetFrameToT",
			["lstr"] = "targetframetot",
			["setmovable"] = true,
			["setuserplaced"] = true,
			["setup"] = MAISetupTargetFrameToT,
			["notgood"] = true,
			["nochanges"] = true
		}
	)
	MAIAddElement(
		{
			["name"] = "FocusFrame",
			["lstr"] = "focusframe",
			["setmovable"] = true,
			["setuserplaced"] = true,
			["setup"] = MAISetupFocusFrame
		}
	)
	MAIAddElement(
		{
			["name"] = "PetFrame",
			["lstr"] = "petframe",
			["setmovable"] = true,
			["setuserplaced"] = true,
			["forcedrag"] = true,
			["setup"] = MAISetupPetFrame,
			["notgood"] = true,
			["nochanges"] = true
		}
	)
	MAIAddElement(
		{
			["name"] = "MAIBossList",
			["lstr"] = "bossframe",
			["setmovable"] = true,
			["setuserplaced"] = true,
			["setup"] = MAISetupBossFrame
		}
	)
	for i = 1, 4 do
		MAIAddElement(
			{
				["name"] = "PartyMemberFrame" .. i,
				["lstr"] = "PartyMemberFrame" .. i,
				["setup"] = "MAISetupPartyMemberFrame" .. i,
				["setmovable"] = true,
				["setuserplaced"] = true,
				["forcedrag"] = true,
				["notgood"] = true,
				["nochanges"] = true
			}
		)
	end

	if not IsAddOnLoaded("Questie") then
		MAIAddElement(
			{
				["name"] = "ObjectiveTrackerFrame",
				["lstr"] = "questlog",
				["setup"] = MAISetupObjectiveTrackerFrame,
				["sw"] = 235,
				["sh"] = 600,
				["anchor"] = "TOPLEFT",
				["forcedrag"] = true
			}
		)
		MAIAddElement(
			{
				["name"] = "QuestWatchFrame",
				["lstr"] = "questlog",
				["setup"] = MAISetupQuestWatchFrame,
				["sw"] = 235,
				["sh"] = 600,
				["anchor"] = "TOPLEFT",
				["forcedrag"] = true
			}
		)
	end

	MAIAddElement(
		{
			["name"] = "TemporaryEnchantFrame",
			["lstr"] = "temporaryenchantframe",
			["setup"] = MAISetupTemporaryEnchantFrame,
			["notgood"] = true
		}
	)

	MAIAddElement(
		{
			["name"] = "MAIDebuffFrame",
			["lstr"] = "debuffframe",
			["setup"] = MAISetupDebuffFrame,
			["notgood"] = true
		}
	)

	MAIAddElement(
		{
			["name"] = "MAIBuffFrame",
			["lstr"] = "buffframe",
			["setup"] = MAISetupBuffFrame
		}
	)

	MAIAddElement(
		{
			["name"] = "MawBuffsBelowMinimapFrame",
			["lstr"] = "animapowers",
			["setup"] = MAISetupMawBuffsBelowMinimapFrame
		}
	)

	MAIAddElement(
		{
			["name"] = "DurabilityFrame",
			["lstr"] = DURABILITY,
			["setup"] = MAISetupDurabilityFrame
		}
	)

	if Arena_LoadUI then
		if MAITAB["ArenaEnemyFramesEnabled"] or MAITAB["ArenaPrepFramesEnabled"] then
			Arena_LoadUI()
		end
	end
	MAIAddElement(
		{
			["name"] = "ArenaEnemyFrames",
			["lstr"] = ARENA_TEAM,
			["sw"] = 100,
			["sh"] = 40,
			["setmovable"] = true,
			["setuserplaced"] = true,
			["forcedrag"] = true,
			["setup"] = MAISetupArenaEnemyFrames,
			["notgood"] = true,
			["nochanges"] = true
		}
	)

	for i = 1, 5 do
		MAIAddElement({
			["name"] = "ArenaEnemyFrame" .. i .."CastingBar",
			["lstr"] = "ArenaEnemyFrame" .. i .."CastingBar",
			["notgood"] = true,
			["nochanges"] = true
		})
	end
	
	MAIAddElement(
		{
			["name"] = "ArenaPrepFrames",
			["lstr"] = ARENA_TEAM .. " (" .. PREVIEW  .. ")",
			["sw"] = 100,
			["sh"] = 40,
			["setmovable"] = true,
			["setuserplaced"] = true,
			["forcedrag"] = true,
			["setup"] = MAISetupArenaPrepFrames,
			["notgood"] = true,
			["nochanges"] = true
		}
	)

	MAIAddElement(
		{
			["name"] = "VehicleSeatIndicator",
			["lstr"] = "vehicleseats"
		}
	)

	MAIAddElement(
		{
			["name"] = "CastingBarFrame",
			["lstr"] = "castingbar",
			["setup"] = MAISetupCastingBar
		}
	)

	MAIAddElement(
		{
			["name"] = "ArcheologyDigsiteProgressBar",
			["lstr"] = "archeologydigsiteprogressbar",
			["setup"] = MAISetupArcheologyDigsiteProgressBar
		}
	)

	MAIAddElement(
		{
			["name"] = "MAIMicroButtons",
			["lstr"] = "micromenu",
			["setup"] = MAISetupMAIMicroButtons
		}
	)

	for i = 1, MAIMAXBAR do
		local lstr = MAIGT("actionbar") .. " " .. i
		if i == 1 then
			lstr = lstr .. " (" .. "MainBar" .. ")"
		elseif i == 2 then
			lstr = lstr .. " (" .. "MainBar 2. Page" .. ")"
		elseif i == 3 then
			lstr = lstr .. " (" .. "Rightbar (Right)" .. ")"
		elseif i == 4 then
			lstr = lstr .. " (" .. "Rightbar (Left)" .. ")"
		elseif i == 5 then
			lstr = lstr .. " (" .. "Bottombar (Right)" .. ")"
		elseif i == 6 then
			lstr = lstr .. " (" .. "Bottombar (Left)" .. ")"
		else
			lstr = lstr .. " (" .. "Custom Bar" .. ")"

			_, englishClass = UnitClass("PLAYER")
			if englishClass == "DRUID" then
				if i == 7 then
					lstr = lstr .. " (" .. "CAT-FORM" .. ")"
				end
				if i == 9 then
					lstr = lstr .. " (" .. "BEAR-FORM" .. ")"
				end
				if i == 10 then
					lstr = lstr .. " (" .. "MOONKIN-FORM" .. ")"
				end
			elseif englishClass == "ROGUE" then
				if i == 7 then
					lstr = lstr .. " (" .. "STEALTH" .. ")"
				end
			end
		end
		MAIAddElement(
			{
				["name"] = "ActionBar" .. i,
				["lstr"] = lstr,
				["setup"] = MAISetupActionButtons,
				["forcedrag"] = (i == 1),
				["notgood"] = (i == 2),
				["nochanges"] = (i == 2) or i > 6
			}
		)
	end

	MAIAddElement(
			{
			["name"] = "PetBar",
			["lstr"] = "petactionbar",
			["setup"] = MAISetupPetbar
		}
	)

	MAIAddElement(
			{
			["name"] = "StanceBar",
			["lstr"] = "stancebar",
			["setup"] = MAISetupStanceBar
		}
	)

	MAIAddElement(
			{
			["name"] = "MultiCastActionBarFrame",
			["lstr"] = "MultiCastActionBarFrame",
			["setup"] = MAISetupMultiCastActionBarFrame
		}
	)

	MAIAddElement(
			{
			["name"] = "ExtraActionButton1",
			["lstr"] = "extraaction",
			["setup"] = MAISetupExtraActionButton,
			["sw"] = 52,
			["sh"] = 52
		}
	)

	MAIAddElement(
			{
			["name"] = "ZoneAbilityFrame",
			["lstr"] = "zoneability",
			["setup"] = MAISetupZoneAbilityFrame,
			["sw"] = 256,
			["sh"] = 128
		}
	)

	MAIAddElement(
			{
			["name"] = "BagBar",
			["lstr"] = INVTYPE_BAG,
			["setup"] = MAISetupBagBar
		}
	)

	MAIAddElement(
			{
			["name"] = "MirrorTimer1",
			["lstr"] = "timer",
			["setup"] = MAISetupMirrorTimer1,
			["sw"] = 206,
			["sh"] = 26
		}
	)

	MAIAddElement(
			{
			["name"] = "AlertFrame",
			["lstr"] = "alerts",
			["sw"] = 60,
			["sh"] = 60
		}
	)

	MAIAddElement(
			{
			["name"] = "MAIStatusBar",
			["lstr"] = "statusbar",
			["setup"] = MAISetupStatusBar
		}
	)

	MAIAddElement(
			{
			["name"] = "MAISkills",
			["lstr"] = "skills",
			["setup"] = MAISetupSkills
		}
	)

	if TalkingHead_LoadUI then
		TalkingHead_LoadUI()

		MAIAddElement(
				{
				["name"] = "TalkingHeadFrame",
				["lstr"] = "talkinghead",
				["sw"] = 570,
				["sh"] = 155
			}
		)
	end

	MAIAddElement(
			{
			["name"] = "ChatFrame1",
			["lstr"] = CHAT
		}
	)

	MAIAddElement(
			{
			["name"] = "PlayerPowerBarAlt",
			["lstr"] = getglobal("ALTERNATE_RESOURCE_TEXT"),
			["setup"] = MAISetupPlayerPowerBarAlt,
			["setmovable"] = true,
			["setuserplaced"] = true,
			["sw"] = 40,
			["sh"] = 40
		}
	)

	MAIAddElement(
			{
			["name"] = "UIWidgetPowerBarContainerFrame",
			["lstr"] = "UIWidgetPowerBarContainerFrame",
			["setup"] = MAISetupUIWidgetPowerBarContainerFrame,
			["sw"] = 40,
			["sh"] = 40
		}
	)

	MAIAddElement(
			{
			["name"] = "MAIMoneyBar",
			["lstr"] = "MAIMoneyBar",
			["setup"] = MAISetupMAIMoneyBar,
			["nochanges"] = true
		}
	)

	MAIAddElement(
			{
			["name"] = "UIWidgetTopCenterContainerFrame",
			["lstr"] = "UIWidgetTopCenter",
			["setup"] = MAISetupUIWidgetTopCenterContainerFrame,
			["sw"] = 140,
			["sh"] = 60
		}
	)

	MAIAddElement(
			{
			["name"] = "UIWidgetBelowMinimapContainerFrame",
			["lstr"] = "UIWidgetBelowMinimap",
			--["setup"] = MAISetupUIWidgetBelowMinimapContainerFrame,
			["sw"] = 140,
			["sh"] = 60
		}
	)

	MAIAddElement(
			{
			["name"] = "GV",
			["lstr"] = "GV",
			["setup"] = MAISetupGV,
			["nochanges"] = true
		}
	)

	if PlayerChoice_LoadUI then
		PlayerChoice_LoadUI()

		MAIAddElement(
			{
				["name"] = "TorghastPlayerChoiceToggleButton",
				["lstr"] = "TorghastPlayerChoiceToggleButton"
			}
		)
	end

	MAIAddElement(
			{
			["name"] = "TargetFrameSpellBar",
			["lstr"] = "TargetFrameSpellBar",
			["setup"] = MAISetupTargetFrameSpellBar,
			["setmovable"] = true,
			["setuserplaced"] = true,
			["notgood"] = true,
			["nochanges"] = true
		}
	)

	MAIAddElement(
			{
			["name"] = "FocusFrameSpellBar",
			["lstr"] = "FocusFrameSpellBar",
			["setup"] = MAISetupFocusFrameSpellBar,
			["setmovable"] = true,
			["setuserplaced"] = true,
			["notgood"] = true,
			["nochanges"] = true
		}
	)

	MAIAddElement(
			{
			["name"] = "GroupLootFrame1",
			["lstr"] = "GroupLootFrame1",
			["setup"] = MAISetupGroupLootFrame
		}
	)
	
	MAIAddElement(
		{
			["name"] = "MainMenuBarVehicleLeaveButton",
			["lstr"] = LEAVE_VEHICLE,
			["setup"] = MAISetupMainMenuBarVehicleLeaveButton
		}
	)

	MAIAddElement(
		{
			["name"] = "GryphonLeft",
			["lstr"] = "gryphonleft",
			["setup"] = MAISetupGryphonLeft
		}
	)

	MAIAddElement(
		{
			["name"] = "GryphonRight",
			["lstr"] = "gryphonright",
			["setup"] = MAISetupGryphonRight
		}
	)

	MAIAddElement(
		{
			["name"] = "GameTooltip",
			["lstr"] = "tooltip",
			["setup"] = MAISetupGameTooltip,
			["sw"] = 60,
			["sh"] = 60
		}
	)

	MAIAddElement(
		{
			["name"] = "FPSFrame",
			["lstr"] = string.upper(getglobal("FPS_ABBR")),
			["setup"] = MAISetupFPSFrame
		}
	)

	MAIAddElement(
		{
			["name"] = "PingFrame",
			["lstr"] = "PING",
			["setup"] = MAISetupPingFrame
		}
	)

	MAIAddElement(
		{
			["name"] = "UIErrorsFrame",
			["lstr"] = "UIErrorsFrame"
		}
	)
end
-- ELEMENTS



-- SETTINGS
local ELESETTINGS = {
	["UnitFrames"] = {
		"PlayerFrame",
		"TargetFrame",
		"FocusFrame",
		"ArenaEnemyFrames",
		"ArenaPrepFrames",
		"MAIBossList",
		["UnitFramesAdvanced"] = {
			"PetFrame",
			"TargetFrameToT",
			"TargetFrameSpellBar",
			"FocusFrameSpellBar",
		}
	},
	["Interface"] = {
		["ActionBars"] = {
			"ActionBar" .. 1,
			"ActionBar" .. 2,
			"ActionBar" .. 3,
			"ActionBar" .. 4,
			"ActionBar" .. 5,
			"ActionBar" .. 6,
			"ActionBar" .. 7,
			"ActionBar" .. 8,
			"ActionBar" .. 9,
			"ActionBar" .. 10,
			"PetBar",
			"StanceBar",
			"MultiCastActionBarFrame",
			"ExtraActionButton1",
			"ZoneAbilityFrame",
			"MainMenuBarVehicleLeaveButton",
			"GryphonLeft",
			"GryphonRight",
		},
		["MAIBuffFrame"] = {
			"MAIDebuffFrame",
			"TemporaryEnchantFrame"
		},
		["Minimap"] = {
			"minimapbuttons",
			--"Post",
			--"Calendar",
			--"WorldMapButton"
		},
		["MAIStatusBar"] = {
			--"EPBar",
			--"REPBar",
			--"HonorBar",
			--"AzeriteBar"
		},
		"MawBuffsBelowMinimapFrame",
		"CastingBarFrame",
		"ArcheologyDigsiteProgressBar",
		"MirrorTimer1",
		"DurabilityFrame",
		"VehicleSeatIndicator",
		"MAIMicroButtons",
		"BagBar",
		"PlayerPowerBarAlt",
		"UIWidgetPowerBarContainerFrame",
		"TalkingHeadFrame",
		"ChatFrame1",
		"GameTooltip",
		"AlertFrame",
		"GroupLootFrame1",
		"MAISkills"
	},
	["InterfaceAdvanced"] = {
		"UIWidgetTopCenterContainerFrame",
		"UIWidgetBelowMinimapContainerFrame",
		"FPSFrame",
		"PingFrame",
		"GV",
		"TorghastPlayerChoiceToggleButton",
		"MAIMoneyBar",
		"UIErrorsFrame"
	}
}
for i = 1, 5 do
	tinsert(ELESETTINGS["UnitFrames"], "ArenaEnemyFrame" .. i .. "CastingBar")
end

function MAIisGreaterThan(a, b)
	return a < b
end

function MAISortUnderTable(tab)
	table.sort(tab, MAIisGreaterThan)
	for i, v in pairs(tab) do
		if type(v) == "table" then
			MAISortUnderTable(v)
		end
	end
end
-- SETTINGS



local MOVER = {}
local btnw = 220
local btnh = 24
local bbr = 10
local sbr = 2
local py = 0

function MAISetupMAIMENU()
	if MAIGV( "nochanges" ) == nil then
		MAISV( "nochanges", false )
	end

	local Y = -10
	MAIMENUMOVING:SetSize(bbr + btnw + sbr + btnw + bbr, 135)
	MAIMENUMOVING:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	MAIMENUMOVING.texture = MAIMENUMOVING:CreateTexture(nil, "BACKGROUND")
	MAIMENUMOVING.texture:SetAllPoints(MAIMENUMOVING)
	MAIMENUMOVING.texture:SetColorTexture(unpack(MAICOLORBACKGROUND))
	MAIMENUMOVING:SetClampedToScreen(true)
	MAIMENUMOVING:SetMovable(true)
	MAIMENUMOVING:EnableMouse(true)
	MAIMENUMOVING:RegisterForDrag("LeftButton")
	MAIMENUMOVING.isMoving = false
	MAIMENUMOVING:SetScript("OnDragStart", function(self)
		self.isMoving = true
		self:StartMoving()
	end)
	MAIMENUMOVING:SetScript("OnDragStop", function(self)
		self.isMoving = false
		self:StopMovingOrSizing()

		local point, _, relativePoint, ofsx, ofsy = self:GetPoint()
		if point then
			MAISV( "MAIMENUMOVING" .. "point", point )
			MAISV( "MAIMENUMOVING" .. "relativePoint", relativePoint )
			MAISV( "MAIMENUMOVING" .. "ofsx", MAIMathR(ofsx, 0) )
			MAISV( "MAIMENUMOVING" .. "ofsy", MAIMathR(ofsy, 0) )
		end
	end)
	if true then
		local point = MAIGV( "MAIMENUMOVING" .. "point" )
		local relativePoint = MAIGV( "MAIMENUMOVING" .. "relativePoint" )
		local ofsx = MAIGV( "MAIMENUMOVING" .. "ofsx" )
		local ofsy = MAIGV( "MAIMENUMOVING" .. "ofsy" )
		if point then
			MAIMENUMOVING:ClearAllPoints()
			MAIMENUMOVING:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
		end
		if MAIGV( "toggler" ) then
			MAIMENUMOVING:Show()
		else
			MAIMENUMOVING:Hide()
		end
	end

	MAIMENUMOVING.TOGGLE = CreateFrame("Button", "MAIMENUMOVING.TOGGLE", MAIMENUMOVING, "UIPanelButtonTemplate")
	MAIMENUMOVING.TOGGLE:SetSize(btnw, btnh)
	MAIMENUMOVING.TOGGLE:SetText("TOGGLE")
	MAIMENUMOVING.TOGGLE:SetPoint("TOPLEFT", MAIMENUMOVING, "TOPLEFT", bbr, Y)
	MAIMENUMOVING.TOGGLE:SetScript("OnClick", function()
		MAIToggleDragger()
	end)

	MAIMENUMOVING.RELOAD = CreateFrame("Button", "MAIMENUMOVING.RELOAD", MAIMENUMOVING, "UIPanelButtonTemplate")
	MAIMENUMOVING.RELOAD:SetSize(btnw, btnh)
	MAIMENUMOVING.RELOAD:SetText(getglobal("RELOADUI"))
	MAIMENUMOVING.RELOAD:SetPoint("TOPLEFT", MAIMENUMOVING, "TOPLEFT", bbr + btnw + sbr, Y)
	MAIMENUMOVING.RELOAD:SetScript("OnClick", function()
		C_UI.Reload()
	end)
	
	Y = Y - (btnh + sbr)

	MAIMENUMOVING.MOVEALL = CreateFrame("Button", "MAIMENUMOVING.MOVEALL", MAIMENUMOVING, "UIPanelButtonTemplate")
	MAIMENUMOVING.MOVEALL:SetSize(btnw, btnh)
	MAIMENUMOVING.MOVEALL:SetText(MAIGT("moveall"))
	MAIMENUMOVING.MOVEALL:SetPoint("TOPLEFT", MAIMENUMOVING, "TOPLEFT", bbr, Y)
	MAIMENUMOVING.MOVEALL:SetScript("OnClick", function()
		for i, v in pairs(ELEMENTS) do
			MAISV( v.name .. "move", true )
		end
		C_UI.Reload()
	end)

	MAIMENUMOVING.UNMOVEALL = CreateFrame("Button", "MAIMENUMOVING.UNMOVEALL", MAIMENUMOVING, "UIPanelButtonTemplate")
	MAIMENUMOVING.UNMOVEALL:SetSize(btnw, btnh)
	MAIMENUMOVING.UNMOVEALL:SetText(MAIGT("movenothing"))
	MAIMENUMOVING.UNMOVEALL:SetPoint("TOPLEFT", MAIMENUMOVING, "TOPLEFT", bbr + btnw + sbr, Y)
	MAIMENUMOVING.UNMOVEALL:SetScript("OnClick", function()
		for i, v in pairs(ELEMENTS) do
			MAISV( v.name .. "move", false )
		end
		C_UI.Reload()
	end)
	
	Y = Y - 30

	if MAIGV( "hideunmoved" ) then
		MAISV( "hideunmoved", true )
	end
	local CBHideUnmoved = CreateFrame("CheckButton", "HideUnmoved", MAIMENUMOVING, "ChatConfigCheckButtonTemplate")
	CBHideUnmoved:SetSize(btnh, btnh)
	CBHideUnmoved:SetPoint("TOPLEFT", MAIMENUMOVING, "TOPLEFT", bbr, Y)
	CBHideUnmoved:SetChecked(MAIGV( "hideunmoved" ))
	CBHideUnmoved:SetScript("OnClick", function(self)
		local newval = self:GetChecked()
		MAISV( "hideunmoved", newval )
		MAITHINKER.force = true
	end)
	CBHideUnmoved.text = CBHideUnmoved:CreateFontString(nil, "ARTWORK")
	CBHideUnmoved.text:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
	CBHideUnmoved.text:SetPoint("LEFT", CBHideUnmoved, "RIGHT", 0, 0)
	CBHideUnmoved.text:SetText(getglobal("HIDE") .. " (" .. getglobal("NPE_MOVE") .. ": " .. getglobal("OFF") .. ")")

	Y = Y - 20

	if MAIGV( "hidehidden" ) then
		MAISV( "hidehidden", true )
	end
	local CBHideHidden = CreateFrame("CheckButton", "HideHidden", MAIMENUMOVING, "ChatConfigCheckButtonTemplate")
	CBHideHidden:SetSize(btnh, btnh)
	CBHideHidden:SetPoint("TOPLEFT", MAIMENUMOVING, "TOPLEFT", bbr, Y)
	CBHideHidden:SetChecked(MAIGV( "hidehidden" ))
	CBHideHidden:SetScript("OnClick", function(self)
		local newval = self:GetChecked()
		MAISV( "hidehidden", newval )
		MAITHINKER.force = true
	end)
	CBHideHidden.text = CBHideHidden:CreateFontString(nil, "ARTWORK")
	CBHideHidden.text:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
	CBHideHidden.text:SetPoint("LEFT", CBHideHidden, "RIGHT", 0, 0)
	CBHideHidden.text:SetText(getglobal("HIDE") .. " (" .. MAIGT("hidden") .. ")")

	Y = Y - 20

	if MAIGV( "snaptogrid" ) == nil then
		MAISV( "snaptogrid", true )
	end
	local CBSnapToGrid = CreateFrame("CheckButton", "CBSnapToGrid", MAIMENUMOVING, "ChatConfigCheckButtonTemplate")
	CBSnapToGrid:SetSize(btnh, btnh)
	CBSnapToGrid:SetPoint("TOPLEFT", MAIMENUMOVING, "TOPLEFT", bbr, Y)
	CBSnapToGrid:SetChecked(MAIGV( "snaptogrid" ))
	CBSnapToGrid:SetScript("OnClick", function(self)
		local newval = self:GetChecked()
		MAISV( "snaptogrid", newval )
	end)
	CBSnapToGrid.text = CBSnapToGrid:CreateFontString(nil, "ARTWORK")
	CBSnapToGrid.text:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
	CBSnapToGrid.text:SetPoint("LEFT", CBSnapToGrid, "RIGHT", 0, 0)
	CBSnapToGrid.text:SetText(MAIGT("snaptogrid"))

	MAIMENU:SetClampedToScreen(true)
	MAIMENU:SetMovable(true)
	MAIMENU:EnableMouse(true)
	MAIMENU:RegisterForDrag("LeftButton")
	MAIMENU.isMoving = false
	MAIMENU:SetScript("OnDragStart", function(self)
		self.isMoving = true
		self:StartMoving()
	end)
	MAIMENU:SetScript("OnDragStop", function(self)
		self.isMoving = false
		self:StopMovingOrSizing()

		local point, parent, relativePoint, ofsx, ofsy = self:GetPoint()
		if point then
			MAISV( "MAIMENU" .. "point", point )
			MAISV( "MAIMENU" .. "relativePoint", relativePoint )
			MAISV( "MAIMENU" .. "ofsx", MAIMathR(ofsx, 0) )
			MAISV( "MAIMENU" .. "ofsy", MAIMathR(ofsy, 0) )
		end
	end)

	MAIMENU:SetSize(bbr + btnw + sbr + btnw + bbr, 200)

	--MAIMENU
	MAIMENU.texture = MAIMENU:CreateTexture(nil, "BACKGROUND")
	MAIMENU.texture:SetAllPoints(MAIMENU)
	MAIMENU.texture:SetColorTexture(unpack(MAICOLORBACKGROUND))

	MAIMENU.textureHeader = MAIMENU:CreateTexture(nil, "BACKGROUND")
	MAIMENU.textureHeader:SetSize(MAIMENU:GetWidth(), sbr + btnh + sbr)
	MAIMENU.textureHeader:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", 0, 0)
	MAIMENU.textureHeader:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

	MAIMENU.textheader = MAIMENU:CreateFontString(nil, "ARTWORK")
	MAIMENU.textheader:SetFont(STANDARD_TEXT_FONT, 14, "")
	MAIMENU.textheader:SetPoint("LEFT", MAIMENU, "TOPLEFT", 5, -15)
	MAIMENU.textheader:SetText("Move And Improve (V.: " .. MAIVERSION .. ")")

	MAIMENU.CLOSE = CreateFrame("Button", "MAIMENU.CLOSE", MAIMENU, "UIPanelCloseButton")
	MAIMENU.CLOSE:SetSize(btnh, btnh)
	MAIMENU.CLOSE:SetText(getglobal("CLOSEUI"))
	MAIMENU.CLOSE:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", MAIMENU:GetWidth() - btnh - sbr, -sbr)
	MAIMENU.CLOSE:SetScript("OnClick", function()
		MAIMENU:Hide()
		MAIMENUMOVING:Hide()
		MAISV( "menu", false )
		MAISV( "toggler", false )
	end)

	py = py - sbr - btnh - sbr - bbr

	MAIMENU.PROFILES = CreateFrame("Button", "MAIMENU.PROFILES", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.PROFILES:SetSize(btnw, btnh)
	MAIMENU.PROFILES:SetText( MAIGT("profile") .. ": " .. MAIGCP() )
	MAIMENU.PROFILES:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr, py)
	MAIMENU.PROFILES:SetScript("OnClick", function()
		if MAIProfiles == nil then
			local categoryOrder = { }
			for k in pairs( MAITAB["PROFILES"] ) do
				if strEmpty( k ) then
					MAIMSG( "|cFFFF0000ONE PROFILE HAS INVALID NAME: " .. tostring( k ) )
				else
					tinsert( categoryOrder, k )
				end
			end
			table.sort( categoryOrder )

			MAIProfiles = CreateFrame("Frame", "MAIProfiles", UIParent)
			MAIProfiles:SetFrameStrata("FULLSCREEN")
			MAIProfiles:SetSize(btnw * 2 + 3 * bbr, 200)

			MAIProfiles:IsUserPlaced(true)
			MAIProfiles:SetClampedToScreen(true)
			MAIProfiles:SetMovable(true)
			MAIProfiles:EnableMouse(true)
			MAIProfiles:RegisterForDrag("LeftButton")
			MAIProfiles:SetScript("OnDragStart", MAIProfiles.StartMoving)
			MAIProfiles:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing()
				
				local point, _, relativePoint, ofsx, ofsy = self:GetPoint()
				MAISV( "MAIProfiles" .. "point", point )
				MAISV( "MAIProfiles" .. "relativePoint", relativePoint )
				MAISV( "MAIProfiles" .. "ofsx", MAIMathR(ofsx, 0) )
				MAISV( "MAIProfiles" .. "ofsy", MAIMathR(ofsy, 0) )
			end)

			local point = MAIGV( "MAIProfiles" .. "point" ) or "CENTER"
			local relativePoint = MAIGV( "MAIProfiles" .. "relativePoint" ) or "CENTER"
			local ofsx = MAIGV( "MAIProfiles" .. "ofsx" ) or 250
			local ofsy = MAIGV( "MAIProfiles" .. "ofsy" ) or -250
			MAIProfiles:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
			
			MAIProfiles.texture = MAIProfiles:CreateTexture(nil, "BACKGROUND")
			MAIProfiles.texture:SetAllPoints(MAIProfiles)
			MAIProfiles.texture:SetColorTexture(unpack(MAICOLORBACKGROUND))
		
			MAIProfiles.textureHeader = MAIProfiles:CreateTexture(nil, "BACKGROUND")
			MAIProfiles.textureHeader:SetSize(MAIProfiles:GetWidth(), sbr + btnh + sbr)
			MAIProfiles.textureHeader:SetPoint("TOPLEFT", MAIProfiles, "TOPLEFT", 0, 0)
			MAIProfiles.textureHeader:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))
		
			MAIProfiles.textheader = MAIProfiles:CreateFontString(nil, "ARTWORK")
			MAIProfiles.textheader:SetFont(STANDARD_TEXT_FONT, 14, "")
			MAIProfiles.textheader:SetPoint( "LEFT", MAIProfiles, "TOPLEFT", 5, -15 )
			MAIProfiles.textheader:SetText( MAIGT( "profiles" ) )
			
			local b = CreateFrame("Button", "close", MAIProfiles, "UIPanelButtonTemplate")
			b:SetSize( 26, 26 )
			b:SetPoint("TOPRIGHT", MAIProfiles, "TOPRIGHT", 0, 0)
			b:SetScript("OnClick", function()
				MAIProfiles:Hide()
			end)
			b:SetText("X")

			local add = CreateFrame("Button", "addprof", MAIProfiles, "UIPanelButtonTemplate")
			add:SetSize( btnw, btnh )
			add:SetPoint( "TOPLEFT", MAIProfiles, "TOPLEFT", btnw, -2 )
			add:SetText( MAIGT( "addprofile" ) )
			add:SetScript("OnClick", function()
				MAIAddProfiles = CreateFrame("Frame", "MAIAddProfiles", UIParent)
				MAIAddProfiles:SetFrameStrata("FULLSCREEN_DIALOG")
				MAIAddProfiles:SetSize(400, 200)
				MAIAddProfiles:SetPoint( "Center", 0, 0 )

				MAIAddProfiles:IsUserPlaced(true)
				MAIAddProfiles:SetClampedToScreen(true)
				MAIAddProfiles:SetMovable(true)
				MAIAddProfiles:EnableMouse(true)
				MAIAddProfiles:RegisterForDrag("LeftButton")
				MAIAddProfiles:SetScript("OnDragStart", MAIAddProfiles.StartMoving)
				MAIAddProfiles:SetScript("OnDragStop", function(self)
					self:StopMovingOrSizing()
				end)
				
				MAIAddProfiles.texture = MAIAddProfiles:CreateTexture(nil, "BACKGROUND")
				MAIAddProfiles.texture:SetAllPoints(MAIAddProfiles)
				MAIAddProfiles.texture:SetColorTexture(unpack(MAICOLORBACKGROUND))
			
				MAIAddProfiles.textureHeader = MAIAddProfiles:CreateTexture(nil, "BACKGROUND")
				MAIAddProfiles.textureHeader:SetSize(MAIAddProfiles:GetWidth(), sbr + btnh + sbr)
				MAIAddProfiles.textureHeader:SetPoint("TOPLEFT", MAIAddProfiles, "TOPLEFT", 0, 0)
				MAIAddProfiles.textureHeader:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))
			
				MAIAddProfiles.textheader = MAIAddProfiles:CreateFontString(nil, "ARTWORK")
				MAIAddProfiles.textheader:SetFont(STANDARD_TEXT_FONT, 14, "")
				MAIAddProfiles.textheader:SetPoint( "LEFT", MAIAddProfiles, "TOPLEFT", 5, -15 )
				MAIAddProfiles.textheader:SetText( MAIGT( "addprofile" ) )



				MAIAddProfiles.cb = MAICreateDropdown( {
					["name"] = "cbprof",
					["parent"] = MAIAddProfiles,
					["title"] = MAIGT("inheritfrom"),
					["items"] = categoryOrder,
					["defaultVal"] = "", 
					["changeFunc"] = function(dropdown_frame, dropdown_val)
						MAIAddProfiles.cb.value = dropdown_val
					end
				} )
				MAIAddProfiles.cb:SetPoint( "TOPLEFT", MAIAddProfiles, "TOPLEFT", -10, -40 )
				MAIAddProfiles.cb.value = ""


				MAIAddProfiles.editbox = CreateFrame("EditBox", nil, MAIAddProfiles, "InputBoxTemplate")
				MAIAddProfiles.editbox:SetSize(200, 24)
				MAIAddProfiles.editbox:SetPoint("TOPLEFT", MAIAddProfiles, "TOPLEFT", 10, -72)
				MAIAddProfiles.editbox:SetText( MAIGT("Profile" ) )

				MAIAddProfiles.add = CreateFrame("Button", "addprofile", MAIAddProfiles, "UIPanelButtonTemplate")
				MAIAddProfiles.add:SetSize( btnw, btnh )
				MAIAddProfiles.add:SetPoint( "TOPLEFT", MAIAddProfiles, "TOPLEFT", 2, -72 - 24 - 10 )
				MAIAddProfiles.add:SetText( MAIGT( "addprofile" ) )
				MAIAddProfiles.add:SetScript("OnClick", function()
					local newpro = MAIAddProfiles.editbox:GetText()
					if newpro and not strEmpty( newpro ) and MAITAB["PROFILES"][newpro] == nil then
						local from = MAIAddProfiles.cb.value
						if strEmpty( from ) then
							MAITAB["PROFILES"][newpro] = {}
						else
							MAITAB["PROFILES"][newpro] = MAITAB["PROFILES"][from]
						end
						MAISCP( newpro )
						C_UI.Reload()
					else
						if newpro and strEmpty( newpro ) then
							MAIMSG( "|cFFFF0000The Profilename is empty!" )
						elseif MAITAB["PROFILES"][newpro] ~= nil then
							MAIMSG( "|cFFFF0000Profile: " .. tostring( newpro ) .. " already exists!" )
						end
					end
				end )
			end )


			MAIProfiles.SF = CreateFrame( "ScrollFrame", "MAIProfiles_SF", MAIProfiles, "UIPanelScrollFrameTemplate" )
			MAIProfiles.SF:SetPoint( "TOPLEFT", MAIProfiles, 2, -28 - 2 )
			MAIProfiles.SF:SetPoint( "BOTTOMRIGHT", MAIProfiles, -24, 2 )

			MAIProfiles.SC = CreateFrame("Frame", "MAIProfiles_SC", MAIProfiles.SF)
			MAIProfiles.SC:SetSize( 400, 400 )
			MAIProfiles.SC:SetPoint( "TOPLEFT", MAIProfiles.SF, "TOPLEFT", 0, 0 )

			MAIProfiles.SF:SetScrollChild( MAIProfiles.SC )

			local count = 0
			for index, name in pairs( categoryOrder ) do
				local prof = CreateFrame("Button", name, MAIProfiles.SC, "UIPanelButtonTemplate")
				prof:SetSize( btnw, btnh )
				prof:SetPoint( "TOPLEFT", MAIProfiles.SC, "TOPLEFT", 0, - count * btnh )
				if name == MAIGCP() then
					prof:SetText( MAIGT( "current") .. ": " .. name )
				else
					prof:SetText( name )
				end
				prof:SetScript("OnClick", function()
					MAISCP( name )
					C_UI.Reload()
				end )

				if name ~= "DEFAULT" then
					local rem = CreateFrame("Button", name .. "rem", MAIProfiles.SC, "UIPanelButtonTemplate")
					rem:SetSize( btnw / 2, btnh )
					rem:SetPoint( "TOPLEFT", MAIProfiles.SC, "TOPLEFT", btnw, - count * btnh )
					rem:SetText( MAIGT( "remove" ) )
					rem:SetScript("OnClick", function()
						MAITAB["PROFILES"][name] = nil
						if name == MAIGCP() then
							MAISCP( "DEFAULT" )
						end
						C_UI.Reload()
					end )
				end

				--[[local exp = CreateFrame("Button", name .. "exp", MAIProfiles.SC, "UIPanelButtonTemplate")
				exp:SetSize( btnw / 2, btnh )
				exp:SetPoint( "TOPLEFT", MAIProfiles.SC, "TOPLEFT", btnw + btnw/2, - count * btnh )
				exp:SetText( MAIGT( "share" ) .. " (WIP)" )]]

				count = count + 1
			end
		elseif MAIProfiles:IsShown() then
			MAIProfiles:Hide()
		else
			MAIProfiles:Show()
		end
	end)

	MAIMENU.DISCORD = CreateFrame("Button", "MAIMENU.DISCORD", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.DISCORD:SetSize(btnw, btnh)
	MAIMENU.DISCORD:SetText("DISCORD")
	MAIMENU.DISCORD:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr + btnw + sbr, py)
	local discordwin = nil
	MAIMENU.DISCORD:SetScript("OnClick", function()
		if discordwin == nil then
			discordwin = CreateFrame("Frame", "discordwin", UIParent)
			discordwin:SetSize(215, 45)
			discordwin:SetPoint("CENTER", 0, 0)

			discordwin.textureheader = discordwin:CreateTexture(nil, "ARTWORK")
			discordwin.textureheader:SetDrawLayer("ARTWORK", 7)
			discordwin.textureheader:SetAllPoints()
			discordwin.textureheader:SetColorTexture(0.1, 0.1, 0.1, 0.8)

			discordwin.textheader = discordwin:CreateFontString(nil, "ARTWORK")
			discordwin.textheader:SetFont(STANDARD_TEXT_FONT, 8, "")
			discordwin.textheader:SetPoint("LEFT", discordwin, "TOPLEFT", 5, -10)
			discordwin.textheader:SetText("Move And Improve: Discord")

			local b = CreateFrame("Button", "close", discordwin, "UIPanelButtonTemplate")
			b:SetSize(20, 20) -- width, height
			b:SetPoint("TOPRIGHT", discordwin, "TOPRIGHT", 0, 0)
			b:SetScript("OnClick", function()
				discordwin:Hide()
				discordwin.visible = false
			end)
			b:SetText("X")

			discordwin.editbox = CreateFrame("EditBox", nil, discordwin, "InputBoxTemplate")
			discordwin.editbox:SetSize(200, 24)
			discordwin.editbox:SetPoint("LEFT", discordwin, "TOPLEFT", 10, -30)
			discordwin.editbox:SetText("https://discord.gg/UeBsafs")

			discordwin.visible = true
		elseif discordwin.visible then
			discordwin:Hide()
			discordwin.visible = false
			discordwin.editbox:SetText("https://discord.gg/UeBsafs")
		else
			discordwin:Show()
			discordwin.visible = true
			discordwin.editbox:SetText("https://discord.gg/UeBsafs")
		end
	end)

	py = py - sbr - btnh - sbr - bbr

	MAIMENU.TOGGLE = CreateFrame("Button", "MAIMENU.TOGGLE", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.TOGGLE:SetSize(btnw, btnh)
	MAIMENU.TOGGLE:SetText("TOGGLE")
	MAIMENU.TOGGLE:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr, py)
	MAIMENU.TOGGLE:SetScript("OnClick", function()
		MAIToggleDragger()
	end)

	MAIMENU.DEBUGFSTACK = CreateFrame("Button", "MAIMENU.DEBUGFSTACK", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.DEBUGFSTACK:SetSize(btnw, btnh)
	MAIMENU.DEBUGFSTACK:SetText("DEBUG: /fstack")
	MAIMENU.DEBUGFSTACK:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr + btnw + sbr, py)
	MAIMENU.DEBUGFSTACK:SetScript("OnClick", function()
		SlashCmdList["FRAMESTACK"]()	
	end)

	py = py - sbr - btnh - sbr
	
	MAIMENU.ELEMENTS = CreateFrame("Button", "MAIMENU.RELOAD", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.ELEMENTS:SetSize(btnw, btnh)
	local mcur = 0
	local mmax = 0
	for i, v in pairs(ELEMENTS) do
		if _G[v.name] ~= nil then
			mmax = mmax + 1
		end

		if MAIGV( v.name .. "Enabled" ) then
			if _G[v.name] ~= nil then
				mcur = mcur + 1
			end
		end	
	end
	MAIMENU.ELEMENTS:SetText(mcur .. "/" .. mmax .. " " .. MAIGT("elements"))
	MAIMENU.ELEMENTS:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr, py)
	MAIMENU.ELEMENTS:SetScript("OnClick", function()
		MAIMENU.CLOSE:Click()
		if MAIMENUELEMENTS == nil then
			MAIMENUELEMENTS = CreateFrame( "FRAME", "MAIMENUELEMENTS", UIParent)
			MAIMENUELEMENTS:SetSize(bbr + btnw + bbr + btnw + 9 * bbr, 600)
			MAIMENUELEMENTS:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			MAIMENUELEMENTS.texture = MAIMENUELEMENTS:CreateTexture(nil, "BACKGROUND")
			MAIMENUELEMENTS.texture:SetAllPoints(MAIMENUELEMENTS)
			MAIMENUELEMENTS.texture:SetColorTexture(unpack(MAICOLORBACKGROUND))

			MAIMENUELEMENTS.textureHeader = MAIMENUELEMENTS:CreateTexture(nil, "BACKGROUND")
			MAIMENUELEMENTS.textureHeader:SetSize(MAIMENUELEMENTS:GetWidth(), sbr + btnh + sbr)
			MAIMENUELEMENTS.textureHeader:SetPoint("TOPLEFT", MAIMENUELEMENTS, "TOPLEFT", 0, 0)
			MAIMENUELEMENTS.textureHeader:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

			MAIMENUELEMENTS.textheader = MAIMENUELEMENTS:CreateFontString(nil, "ARTWORK")
			MAIMENUELEMENTS.textheader:SetFont(STANDARD_TEXT_FONT, 14, "")
			MAIMENUELEMENTS.textheader:SetPoint("LEFT", MAIMENUELEMENTS, "TOPLEFT", 5, -15)
			MAIMENUELEMENTS.textheader:SetText(MAIGT("elements") .. " [Select atleast 1]")

			MAIMENUELEMENTS:SetClampedToScreen(true)
			MAIMENUELEMENTS:SetMovable(true)
			MAIMENUELEMENTS:EnableMouse(true)
			MAIMENUELEMENTS:RegisterForDrag("LeftButton")
			MAIMENUELEMENTS:SetScript("OnDragStart", MAIMENUELEMENTS.StartMoving)
			MAIMENUELEMENTS:SetScript("OnDragStop", MAIMENUELEMENTS.StopMovingOrSizing)

			MAIMENUELEMENTS.CLOSE = CreateFrame("Button", "MAIMENUELEMENTS.CLOSE", MAIMENUELEMENTS, "UIPanelCloseButton")
			MAIMENUELEMENTS.CLOSE:SetSize(btnh, btnh)
			MAIMENUELEMENTS.CLOSE:SetText(getglobal("CLOSEUI"))
			MAIMENUELEMENTS.CLOSE:SetPoint("TOPLEFT", MAIMENUELEMENTS, "TOPLEFT", MAIMENUELEMENTS:GetWidth() - btnh - sbr, -sbr)
			MAIMENUELEMENTS.CLOSE:SetScript("OnClick", function()
				MAIMENUELEMENTS:Hide()

				MAISV( "menu", true )
				MAISV( "toggler", false )

				if not MAICheckIfSame(MAITAB["PROFILES"][MAIGCP()], OLDMAITAB) then
					C_UI.Reload()
				end
				if mcur == 0 then
					C_UI.Reload()
				end

				C_Timer.After(0.1, MAIOpenMenu)
			end)

			MAIMENUELEMENTS.SCROLL = CreateFrame("ScrollFrame", "MAIMENUELEMENTS.SCROLL", MAIMENUELEMENTS, "UIPanelScrollFrameTemplate")
			MAIMENUELEMENTS.SCROLL:SetSize( MAIMENUELEMENTS:GetWidth() - ( 24 ), MAIMENUELEMENTS:GetHeight() - ( sbr + btnh + sbr ) )
			MAIMENUELEMENTS.SCROLL:SetPoint("TOPLEFT", MAIMENUELEMENTS, "TOPLEFT", 0, - ( sbr + btnh + sbr ) )

			MAIMENUELEMENTS.SCROLLCHILD = CreateFrame("Frame", "MAIMENUELEMENTS.SCROLLCHILD", MAIMENUELEMENTS)
			MAIMENUELEMENTS.SCROLLCHILD:SetSize(MAIMENUELEMENTS.SCROLL:GetWidth(), 2000)
			MAIMENUELEMENTS.SCROLLCHILD:SetPoint("TOPLEFT", MAIMENUELEMENTS, "TOPLEFT", 0, -sbr - btnh - sbr)

			MAIMENUELEMENTS.SCROLL:SetScrollChild(MAIMENUELEMENTS.SCROLLCHILD)
			
			function MAIRecTab(tab, bo)
				for i, v in pairs(tab) do
					if type(v) == "table" and _G[i .. "btn"] then
						MAISV( i .. "Enabled", bo )
						_G[i .. "btn"]:SetChecked(bo)
						MAIRecTab(v, bo)
					elseif _G[v .. "btn"] then
						MAISV( v .. "Enabled", bo )
						_G[v .. "btn"]:SetChecked(bo)
					end
				end
			end

			function MAICreateSettingsCheckBox( ele, x, y, tab, notgood )
				local line = CreateFrame( "FRAME", lstr, MAIMENUELEMENTS.SCROLLCHILD)
				line:SetSize(MAIMENUELEMENTS.SCROLL:GetWidth(), btnh)
				line:SetPoint("TOPLEFT", MAIMENUELEMENTS.SCROLLCHILD, "TOPLEFT", x, y)
				
				line.btn = CreateFrame("CheckButton", ele .. "btn", line, "UICheckButtonTemplate") --CreateFrame("CheckButton", "moversettingsmove", mover, "UICheckButtonTemplate")
				line.btn:SetSize(btnh, btnh)
				line.btn:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)
				line.btn:SetScript("OnClick", function(self)
					if MAILoaded then
						if self:GetChecked() then
							MAISV( ele .. "Enabled", true )
						else
							MAISV( ele .. "Enabled", false )
						end

						if tab ~= nil then
							MAIRecTab(tab, MAIGV( ele .. "Enabled" ))
						end

						MAITHINKER.force = true
					end
				end)
				if MAILoaded and MAIGV( ele .. "Enabled" ) == nil then
					MAISV( ele .. "Enabled", false )
				end
				if MAILoaded and MAIGV( ele .. "Enabled" ) then
					line.btn:SetChecked(true)
				end

				line.text = line:CreateFontString(nil, "ARTWORK")
				line.text:SetFont(STANDARD_TEXT_FONT, 14, "THINOUTLINE")
				line.text:SetPoint("LEFT", line, "LEFT", btnh, 0)
				line.text:SetText(MAIGT(ele))

				if NOTGOOD[ele] then
					line.text:SetTextColor( 1, 0.4, 0.4, 1 )
				elseif ele == "MAIBuffFrame" then
					line.text:SetTextColor( 1, 1, 0.4, 1)
				end
				if MAIGV( "nochanges" ) then
					if NOCHANGES[ele] then
						line.btn:Disable()
						line.text:SetTextColor( 0.4, 0.4, 0.4, 1)
					end
				end
			end

			local cpy = 0
			function MAICreateLines(tab, x)
				for i, v in pairs(tab) do
					if type(v) == "table" then
						MAICreateSettingsCheckBox( i, x, cpy, v, true )

						cpy = cpy - 24
						MAICreateLines(v, x + bbr)
					else
						if tContains(ELENAMES, v) then
							MAICreateSettingsCheckBox( v, x, cpy, nil, true )
							cpy = cpy - 24
						end
					end
				end
			end

			if not IsAddOnLoaded("Questie") then
				if ObjectiveTrackerFrame then
					tinsert(ELESETTINGS["Interface"], "ObjectiveTrackerFrame")
				elseif QuestWatchFrame then
					tinsert(ELESETTINGS["Interface"], "QuestWatchFrame")
				end
			end

			for i = 1, 4 do
				tinsert(ELESETTINGS["UnitFrames"]["UnitFramesAdvanced"], "PartyMemberFrame" .. i)
			end
			MAISortUnderTable(ELESETTINGS)
			MAICreateLines(ELESETTINGS, bbr)

			MAIMENUELEMENTS.SCROLLCHILD:SetHeight(math.abs(cpy))
		else
			if MAIMENUELEMENTS:IsVisible() then
				MAIMENUELEMENTS:Hide()
			else
				MAIMENUELEMENTS:Show()
			end
		end
	end)

	MAIMENU.FRAMES = CreateFrame("Button", "MAIMENU.RELOAD", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.FRAMES:SetSize(btnw, btnh)
	local mfcur = 0
	local mfmax = 0
	for i, v in pairs(MAIFRAMES) do
		local name = v[1]

		mfmax = mfmax + 1

		if MAIGV( name .. "Enabled" ) then
			mfcur = mfcur + 1
		end	
	end
	MAIMENU.FRAMES:SetText(mfcur .. "/" .. mfmax .. " " .. MAIGT("frames"))
	MAIMENU.FRAMES:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr + btnw + sbr, py)
	MAIMENU.FRAMES:SetScript("OnClick", function()
		MAIMENU.CLOSE:Click()
		if MAIMENUFRAMES == nil then
			MAIMENUFRAMES = CreateFrame( "FRAME", "MAIMENUFRAMES", UIParent)
			MAIMENUFRAMES:SetSize(bbr + btnw + bbr + btnw + 9 * bbr, 600)
			MAIMENUFRAMES:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			MAIMENUFRAMES.texture = MAIMENUFRAMES:CreateTexture(nil, "BACKGROUND")
			MAIMENUFRAMES.texture:SetAllPoints(MAIMENUFRAMES)
			MAIMENUFRAMES.texture:SetColorTexture(unpack(MAICOLORBACKGROUND))

			MAIMENUFRAMES.textureHeader = MAIMENUFRAMES:CreateTexture(nil, "BACKGROUND")
			MAIMENUFRAMES.textureHeader:SetSize(MAIMENUFRAMES:GetWidth(), sbr + btnh + sbr + btnh + sbr)
			MAIMENUFRAMES.textureHeader:SetPoint("TOPLEFT", MAIMENUFRAMES, "TOPLEFT", 0, 0)
			MAIMENUFRAMES.textureHeader:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

			MAIMENUFRAMES.textheader = MAIMENUFRAMES:CreateFontString(nil, "ARTWORK")
			MAIMENUFRAMES.textheader:SetFont(STANDARD_TEXT_FONT, 14, "")
			MAIMENUFRAMES.textheader:SetPoint("LEFT", MAIMENUFRAMES, "TOPLEFT", 5, -15)
			MAIMENUFRAMES.textheader:SetText( MAIGT("frames") )

			MAIMENUFRAMES.textheader2 = MAIMENUFRAMES:CreateFontString(nil, "ARTWORK")
			MAIMENUFRAMES.textheader2:SetFont(STANDARD_TEXT_FONT, 14, "")
			MAIMENUFRAMES.textheader2:SetPoint("LEFT", MAIMENUFRAMES, "TOPLEFT", 5, -40)
			MAIMENUFRAMES.textheader2:SetText( "[" .. MAIGT( "moveframes" ) .. "] [" .. MAIGT( "scaleframes" ) .. "]" )
			
			function MAIFramesAllEnabled( bo )
				for i, v in pairs( MAIFRAMES ) do
					local name = v[1]
					MAISV( name .. "Enabled", bo )
					_G[name .. "btn"]:SetChecked(bo)
				end
			end
			function MAIFramesAllScale( bo )
				for i, v in pairs( MAIFRAMES ) do
					local name = v[1]
					if _G[name .. "btn2"] then
						MAISV( name .. "Scale", bo )
						_G[name .. "btn2"]:SetChecked(bo)
					end
				end
			end

			MAIMENUFRAMES.btn = CreateFrame("CheckButton", "all" .. "btn", MAIMENUFRAMES, "UICheckButtonTemplate") --CreateFrame("CheckButton", "moversettingsmove", mover, "UICheckButtonTemplate")
			MAIMENUFRAMES.btn:SetSize(btnh, btnh)
			MAIMENUFRAMES.btn:SetPoint("TOPLEFT", MAIMENUFRAMES, "TOPLEFT", bbr, -btnh - 30 )
			MAIMENUFRAMES.btn:SetScript("OnClick", function(self)
				if MAILoaded then
					MAIFramesAllEnabled( self:GetChecked() )
				end
			end)

			MAIMENUFRAMES.btn2 = CreateFrame("CheckButton", "all" .. "btn", MAIMENUFRAMES, "UICheckButtonTemplate") --CreateFrame("CheckButton", "moversettingsmove", mover, "UICheckButtonTemplate")
			MAIMENUFRAMES.btn2:SetSize(btnh, btnh)
			MAIMENUFRAMES.btn2:SetPoint("TOPLEFT", MAIMENUFRAMES, "TOPLEFT", bbr + btnh, -btnh - 30 )
			MAIMENUFRAMES.btn2:SetScript("OnClick", function(self)
				if MAILoaded then
					MAIFramesAllScale( self:GetChecked() )
				end
			end)

			MAIMENUFRAMES.text = MAIMENUFRAMES:CreateFontString(nil, "ARTWORK")
			MAIMENUFRAMES.text:SetFont(STANDARD_TEXT_FONT, 14, "THINOUTLINE")
			MAIMENUFRAMES.text:SetPoint("TOPLEFT", MAIMENUFRAMES, "TOPLEFT", bbr + btnh + btnh, -btnh - 30 - btnh/4 )
			MAIMENUFRAMES.text:SetText( MAIGT( "all" ) )

			MAIMENUFRAMES:SetClampedToScreen(true)
			MAIMENUFRAMES:SetMovable(true)
			MAIMENUFRAMES:EnableMouse(true)
			MAIMENUFRAMES:RegisterForDrag("LeftButton")
			MAIMENUFRAMES:SetScript("OnDragStart", MAIMENUFRAMES.StartMoving)
			MAIMENUFRAMES:SetScript("OnDragStop", MAIMENUFRAMES.StopMovingOrSizing)

			MAIMENUFRAMES.CLOSE = CreateFrame("Button", "MAIMENUFRAMES.CLOSE", MAIMENUFRAMES, "UIPanelCloseButton")
			MAIMENUFRAMES.CLOSE:SetSize(btnh, btnh)
			MAIMENUFRAMES.CLOSE:SetText(getglobal("CLOSEUI"))
			MAIMENUFRAMES.CLOSE:SetPoint("TOPLEFT", MAIMENUFRAMES, "TOPLEFT", MAIMENUFRAMES:GetWidth() - btnh - sbr, -sbr)
			MAIMENUFRAMES.CLOSE:SetScript("OnClick", function()
				MAIMENUFRAMES:Hide()

				MAISV( "menu", true )
				MAISV( "toggler", false )

				if not MAICheckIfSame(MAITAB["PROFILES"][MAIGCP()], OLDMAITAB) then
					C_UI.Reload()
				end
				if mcur == 0 then
					C_UI.Reload()
				end

				C_Timer.After(0.1, MAIOpenMenu)
			end)

			MAIMENUFRAMES.SCROLL = CreateFrame("ScrollFrame", "MAIMENUFRAMES.SCROLL", MAIMENUFRAMES, "UIPanelScrollFrameTemplate")
			MAIMENUFRAMES.SCROLL:SetSize( MAIMENUFRAMES:GetWidth() - ( 24 ), MAIMENUFRAMES:GetHeight() - ( sbr + btnh + sbr + btnh + sbr + btnh + sbr ) )
			MAIMENUFRAMES.SCROLL:SetPoint("TOPLEFT", MAIMENUFRAMES, "TOPLEFT", 0, - ( sbr + btnh + sbr + btnh + sbr + btnh + sbr ) )

			MAIMENUFRAMES.SCROLLCHILD = CreateFrame("Frame", "MAIMENUFRAMES.SCROLLCHILD", MAIMENUFRAMES)
			MAIMENUFRAMES.SCROLLCHILD:SetSize(MAIMENUFRAMES.SCROLL:GetWidth(), 2000)
			MAIMENUFRAMES.SCROLLCHILD:SetPoint("TOPLEFT", MAIMENUFRAMES, "TOPLEFT", 0, -sbr - btnh - sbr)

			MAIMENUFRAMES.SCROLL:SetScrollChild(MAIMENUFRAMES.SCROLLCHILD)
			
			function MAICreateSettingsCheckBox( ele, x, y, notgood, notscale )
				local line = CreateFrame( "FRAME", lstr, MAIMENUFRAMES.SCROLLCHILD)
				line:SetSize(MAIMENUFRAMES.SCROLL:GetWidth(), btnh)
				line:SetPoint("TOPLEFT", MAIMENUFRAMES.SCROLLCHILD, "TOPLEFT", x, y)

				if MAILoaded and MAIGV( ele .. "Enabled" ) == nil then
					MAISV( ele .. "Enabled", false )
				end
				if MAILoaded and MAIGV( ele .. "Scale" ) == nil then
					MAISV( ele .. "Scale", false )
				end

				line.btn = CreateFrame("CheckButton", ele .. "btn", line, "UICheckButtonTemplate") --CreateFrame("CheckButton", "moversettingsmove", mover, "UICheckButtonTemplate")
				line.btn:SetSize(btnh, btnh)
				line.btn:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)
				line.btn:SetScript("OnClick", function(self)
					if MAILoaded then
						if self:GetChecked() then
							MAISV( ele .. "Enabled", true )
						else
							MAISV( ele .. "Enabled", false )
						end

						MAITHINKER.force = true
					end
				end)
				if MAILoaded and MAIGV( ele .. "Enabled" ) then
					line.btn:SetChecked(true)
				end

				if not notscale then
					line.btn2 = CreateFrame("CheckButton", ele .. "btn2", line, "UICheckButtonTemplate") --CreateFrame("CheckButton", "moversettingsmove", mover, "UICheckButtonTemplate")
					line.btn2:SetSize(btnh, btnh)
					line.btn2:SetPoint("TOPLEFT", line, "TOPLEFT", btnh, 0)
					line.btn2:SetScript("OnClick", function(self)
						if MAILoaded then
							if self:GetChecked() then
								MAISV( ele .. "Scale", true )
							else
								MAISV( ele .. "Scale", false )
							end

							MAITHINKER.force = true
						end
					end)

					if MAILoaded and MAIGV( ele .. "Scale" ) then
						line.btn2:SetChecked(true)
					end
				else
					MAISV( ele .. "Scale", false )
				end

				line.btn3 = CreateFrame("Button", ele .. "btn3", line, "UIPanelButtonTemplate" )
				line.btn3:SetText( getglobal( "RESET" ) )
				line.btn3:SetSize(btnh * 4, btnh)
				line.btn3:SetPoint("LEFT", line, "RIGHT", -btnh * 4 - 2, 0)
				line.btn3:SetScript("OnClick", function(self)
					if MAILoaded then
						MAISV( ele .. "Scale", true )

						MAISV( ele .. "point", nil )
						MAISV( ele .. "parent", nil )
						MAISV( ele .. "relativePoint", nil )
						MAISV( ele .. "ofsx", nil )
						MAISV( ele .. "ofsy", nil )

						MAITHINKER.force = true
					end
				end)



				line.text = line:CreateFontString(nil, "ARTWORK")
				line.text:SetFont(STANDARD_TEXT_FONT, 14, "THINOUTLINE")
				line.text:SetPoint("LEFT", line, "LEFT", btnh + btnh, 0)
				line.text:SetText(MAIGT(ele))

				if notgood then
					line.text:SetTextColor( 1, 0.4, 0.4, 1 )
				end
				if MAIGV( "nochanges" ) then
					if NOCHANGES[ele] then
						line.btn:Disable()
						line.text:SetTextColor( 0.4, 0.4, 0.4, 1)
					end
				end
			end

			local cpy = 0
			function MAICreateLines(tab, x)
				for i, v in pairs(tab) do
					MAICreateSettingsCheckBox( v[1], x, cpy, v[5], v[3] )
					cpy = cpy - 24
				end
			end

			MAICreateLines(MAIFRAMES, bbr)

			MAIMENUFRAMES.SCROLLCHILD:SetHeight(math.abs(cpy))
		else
			if MAIMENUFRAMES:IsVisible() then
				MAIMENUFRAMES:Hide()
			else
				MAIMENUFRAMES:Show()
			end
		end
	end)
	if MAIGV( "nochanges" ) then
		MAIMENU.FRAMES:Disable()
	end

	py = py - btnh - sbr

	if MAIGV( "MAIUIColorR" ) == nil then
		MAISV( "MAIUIColorR", 1 )
	end
	if MAIGV( "MAIUIColorG" ) == nil then
		MAISV( "MAIUIColorG", 1 )
	end
	if MAIGV( "MAIUIColorB" ) == nil then
		MAISV( "MAIUIColorB", 1 )
	end

	if MAIGV( "MAIFrameColorR" ) == nil then
		MAISV( "MAIFrameColorR", 1 )
	end
	if MAIGV( "MAIFrameColorG" ) == nil then
		MAISV( "MAIFrameColorG", 1 )
	end
	if MAIGV( "MAIFrameColorB" ) == nil then
		MAISV( "MAIFrameColorB", 1 )
	end

	if MAIGV( "ZoomOut" ) == nil then
		if MAIBUILD == "RETAIL" then
			MAISV( "ZoomOut", 2.6 )
		else
			MAISV( "ZoomOut", 4.0 )
		end
	end
	local maxzoom = 4.0
	if MAIBUILD == "RETAIL" then
		maxzoom = 2.6
	end

	if MAIGV( "WorldTextScale" ) == nil then
		if MAIBUILD == "RETAIL" then
			MAISV( "WorldTextScale", 1.0 )
		else
			MAISV( "WorldTextScale", 1.0 )
		end
	end

	local currentlychanging = ""
	function ShowColorPicker( r, g, b, a, changedCallback )
		ColorPickerFrame:SetColorRGB( r, g, b )
		ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a
		ColorPickerFrame.previousValues = { r, g, b, a }
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = 
			changedCallback, changedCallback, changedCallback
		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
		ColorPickerFrame:SetScale( 2 )
		ColorPickerFrame:HookScript( "OnHide", function()
			currentlychanging = ""
		end )
	end

	local iconsize = 0.6

	local r, g, b, a = 0, 0, 0, 1
	local function MAIUIColor( restore )
		if currentlychanging == "MAIUIColor" then
			local newR, newG, newB, newA
			if restore then
				newR, newG, newB, newA = unpack(restore)
			else
				newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
			end
			r, g, b, a = newR, newG, newB, newA
			MAISV( "MAIUIColorR", MAIMathR( r, 2 ) )
			MAISV( "MAIUIColorG", MAIMathR( g, 2 ) )
			MAISV( "MAIUIColorB", MAIMathR( b, 2 ) )

			MAIUIColorUpdate()
		end
	end
	
	MAIMENU.UIColorEnabled = CreateFrame("CheckButton", "UIColorEnabled", MAIMENU, "ChatConfigCheckButtonTemplate")
	MAIMENU.UIColorEnabled:SetHitRectInsets(0, 0, 0, 0)
	MAIMENU.UIColorEnabled:SetSize( 25, 25 )
	MAIMENU.UIColorEnabled:SetPoint("TOPLEFT", bbr, py)
	MAIMENU.UIColorEnabled:SetChecked( MAIGV( "UIColorEnabled", true ) )
	MAIMENU.UIColorEnabled:SetScript("OnClick", function(self)
		local newval = self:GetChecked()
		MAISV( "UIColorEnabled", newval )
		C_UI.Reload()
	end)
	MAIMENU.UIColor = CreateFrame("Button", "MAIMENU.UIColor", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.UIColor:SetSize(btnw - 25, btnh)
	MAIMENU.UIColor:SetText( MAIGT( "elementscolor" ) )
	MAIMENU.UIColor:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr + 25, py)
	MAIMENU.UIColor:SetScript("OnClick", function()
		currentlychanging = "MAIUIColor"
		ShowColorPicker( MAIGV( "MAIUIColorR", 1 ), MAIGV( "MAIUIColorG", 1 ), MAIGV( "MAIUIColorB", 1 ), nil, MAIUIColor )
	end)
	MAIMENU.UIColor.texture = MAIMENU.UIColor:CreateTexture( nil, "ARTWORK" )
	MAIMENU.UIColor.texture:SetSize( btnh * iconsize, btnh * iconsize )
	MAIMENU.UIColor.texture:SetPoint( "LEFT", MAIMENU.UIColor, "LEFT", 6, -1 )
	MAIMENU.UIColor.texture:SetTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\white" )
	MAIMENU.UIColor.texture:SetVertexColor(MAIGetUIColor())
	MAIRegisterUIColor( MAIMENU.UIColor.texture )
	if MAIGV( "nochanges" ) or not MAIGV( "UIColorEnabled", true ) then
		MAIMENU.UIColor:Disable()
	end

	local function MAIFrameColor( restore )
		if currentlychanging == "MAIFrameColor" then
			local newR, newG, newB, newA
			if restore then
				newR, newG, newB, newA = unpack(restore)
			else
				newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
			end
			r, g, b, a = newR, newG, newB, newA
			MAISV( "MAIFrameColorR", MAIMathR( r, 2 ) )
			MAISV( "MAIFrameColorG", MAIMathR( g, 2 ) )
			MAISV( "MAIFrameColorB", MAIMathR( b, 2 ) )

			MAIFrameColorUpdate()
		end
	end

	MAIMENU.FrameColorEnabled = CreateFrame("CheckButton", "FrameColorEnabled", MAIMENU, "ChatConfigCheckButtonTemplate")
	MAIMENU.FrameColorEnabled:SetHitRectInsets(0, 0, 0, 0)
	MAIMENU.FrameColorEnabled:SetSize( 25, 25 )
	MAIMENU.FrameColorEnabled:SetPoint("TOPLEFT", bbr + btnw + sbr, py)
	MAIMENU.FrameColorEnabled:SetChecked( MAIGV( "FrameColorEnabled", true ) )
	MAIMENU.FrameColorEnabled:SetScript("OnClick", function(self)
		local newval = self:GetChecked()
		MAISV( "FrameColorEnabled", newval )
		C_UI.Reload()
	end)
	MAIMENU.FrameColor = CreateFrame("Button", "MAIMENU.FrameColor", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.FrameColor:SetSize(btnw - 25, btnh)
	MAIMENU.FrameColor:SetText( MAIGT( "framescolor" ) )
	MAIMENU.FrameColor:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr + btnw + sbr + 25, py)
	MAIMENU.FrameColor:SetScript("OnClick", function()
		currentlychanging = "MAIFrameColor"
		ShowColorPicker( MAIGV( "MAIFrameColorR", 1 ), MAIGV( "MAIFrameColorG", 1 ), MAIGV( "MAIFrameColorB", 1 ), nil, MAIFrameColor )
	end)
	MAIMENU.FrameColor.texture = MAIMENU.FrameColor:CreateTexture( nil, "ARTWORK" )
	MAIMENU.FrameColor.texture:SetSize( btnh * iconsize, btnh * iconsize )
	MAIMENU.FrameColor.texture:SetPoint( "LEFT", MAIMENU.FrameColor, "LEFT", 6, -1 )
	MAIMENU.FrameColor.texture:SetTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\white" )
	MAIMENU.FrameColor.texture:SetVertexColor(MAIGetFrameColor())
	MAIRegisterFrameColor( MAIMENU.FrameColor.texture )
	if MAIGV( "nochanges" ) or not MAIGV( "FrameColorEnabled", true ) then
		MAIMENU.FrameColor:Disable()
	end

	py = py - btnh * 1.5 - bbr

	MAIMENU.ZoomOut = MAICreateSlider(MAIMENU, "MAIMENU.ZoomOut", "MAIZoomOut", MAIGV( "ZoomOut" ), 10, py, 1.0, maxzoom, 0.1, ".1f", MAIGT("zoomout"))
	MAIMENU.ZoomOut:HookScript("OnValueChanged", function(self, val)
		MAISV( "ZoomOut", MAIMathR(val, 2) )
		ConsoleExec("cameraDistanceMaxZoomFactor " .. MAIGV( "ZoomOut" ))
	end)

	py = py - btnh * 1.5 - bbr

	MAIMENU.WorldTextScale = MAICreateSlider(MAIMENU, "MAIMENU.WorldTextScale", "MAIWorldTextScale", MAIGV( "WorldTextScale" ), 10, py, 0.1, 10.0, 0.1, ".1f", MAIGT("WorldTextScale"))
	MAIMENU.WorldTextScale:HookScript("OnValueChanged", function(self, val)
		MAISV( "WorldTextScale", MAIMathR(val, 2) )
		ConsoleExec("WorldTextScale " .. MAIGV( "WorldTextScale" ))
	end)

	if MAIGV( "nochanges" ) then
		MAIMENU.ZoomOut:Disable()
		MAIMENU.ZoomOut.Text:SetTextColor( 0.4, 0.4, 0.4, 1 )
		MAIMENU.WorldTextScale:Disable()
		MAIMENU.WorldTextScale.Text:SetTextColor( 0.4, 0.4, 0.4, 1 )
	end

	py = py - btnh - bbr

	if MAIGV( "mmicon" ) == nil then
		MAISV( "mmicon", {} )
	end
	if MAIGV( "mmicon" )["hide"] == nil then
		MAIGV( "mmicon" )["hide"] = false
	end
	MAIMENU.mmicon = CreateFrame("CheckButton", "mmicon", MAIMENU, "ChatConfigCheckButtonTemplate")
	MAIMENU.mmicon:SetSize(20, 20)
	MAIMENU.mmicon:SetPoint("TOPLEFT", bbr, py)
	MAIMENU.mmicon:SetChecked(not MAIGV( "mmicon" )["hide"] )
	MAIMENU.mmicon:SetScript("OnClick", function(self)
		local newval = self:GetChecked()
		if ToggleMinimapButton then
			ToggleMinimapButton()
		end
	end)
	MAIMENU.mmicon:SetScript("OnUpdate", function(self)
		if self:GetChecked() ~= not MAIGV( "mmicon" )["hide"] then
			self:SetChecked(not MAIGV( "mmicon" )["hide"] )
		end
	end)
	MAIMENU.mmicon.text = MAIMENU.mmicon:CreateFontString(nil, "ARTWORK")
	MAIMENU.mmicon.text:SetFont(STANDARD_TEXT_FONT, 10, "")
	MAIMENU.mmicon.text:SetPoint("LEFT", MAIMENU.mmicon, "RIGHT", 0, 0)
	MAIMENU.mmicon.text:SetText(MAIGT("minimapicon"))

	MAIMENU.nochanges = CreateFrame("CheckButton", "nochanges", MAIMENU, "ChatConfigCheckButtonTemplate")
	MAIMENU.nochanges:SetSize(20, 20)
	MAIMENU.nochanges:SetPoint("TOPLEFT", bbr + btnw + sbr, py)
	MAIMENU.nochanges:SetChecked(MAIGV( "nochanges" ) )
	MAIMENU.nochanges:SetScript("OnClick", function(self)
		local newval = self:GetChecked()
		MAISV( "nochanges", newval )

		C_UI.Reload()
	end)
	MAIMENU.nochanges.text = MAIMENU.nochanges:CreateFontString(nil, "ARTWORK")
	MAIMENU.nochanges.text:SetFont(STANDARD_TEXT_FONT, 10, "")
	MAIMENU.nochanges.text:SetPoint("LEFT", MAIMENU.nochanges, "RIGHT", 0, 0)
	MAIMENU.nochanges.text:SetText( "*" .. MAIGT("cry") .. "* " .. MAIGT("nochanges") )

	py = py - btnh
	
	if MAIGV( "PaperDollFrame" .. "showilvl" ) == nil then
		MAISV( "PaperDollFrame" .. "showilvl", true )
	end
	MAIMENU.showilvl = CreateFrame("CheckButton", "showilvl", MAIMENU, "ChatConfigCheckButtonTemplate")
	MAIMENU.showilvl:SetSize(20, 20)
	MAIMENU.showilvl:SetPoint("TOPLEFT", bbr, py)
	MAIMENU.showilvl:SetChecked(MAIGV( "PaperDollFrame" .. "showilvl" ) )
	MAIMENU.showilvl:SetScript("OnClick", function(self)
		MAISV( "PaperDollFrame" .. "showilvl", not MAIGV( "PaperDollFrame" .. "showilvl" ) )
	end)
	local function MAIUpdate()
		self = MAIMENU.showilvl
		if MAIGV( "nochanges" ) then
			self:SetChecked( false )
		else
			if self:GetChecked() ~= MAIGV( "PaperDollFrame" .. "showilvl" ) then
				self:SetChecked( MAIGV( "PaperDollFrame" .. "showilvl" ) )
			end
		end
		C_Timer.After( 0.1, MAIUpdate )
	end
	MAIUpdate()
	MAIMENU.showilvl.text = MAIMENU.showilvl:CreateFontString(nil, "ARTWORK")
	MAIMENU.showilvl.text:SetFont(STANDARD_TEXT_FONT, 10, "")
	MAIMENU.showilvl.text:SetPoint("LEFT", MAIMENU.showilvl, "RIGHT", 0, 0)
	MAIMENU.showilvl.text:SetText(MAIGT("showilvl"))
	if MAIGV( "nochanges" ) then
		MAIMENU.showilvl:SetChecked( false )
		MAIMENU.showilvl:Disable()
		MAIMENU.showilvl.text:SetTextColor( 0.4, 0.4, 0.4, 1 )
	end

	MAIMENU.frametransparency = CreateFrame("CheckButton", "frametransparency", MAIMENU, "ChatConfigCheckButtonTemplate")
	MAIMENU.frametransparency:SetSize(20, 20)
	MAIMENU.frametransparency:SetPoint("TOPLEFT", bbr + btnw + sbr, py)
	MAIMENU.frametransparency:SetChecked( MAIGV( "frametransparency", true ) )
	MAIMENU.frametransparency:SetScript("OnClick", function(self)
		local newval = self:GetChecked()
		MAISV( "frametransparency", newval )
	end)
	MAIMENU.frametransparency.text = MAIMENU.frametransparency:CreateFontString(nil, "ARTWORK")
	MAIMENU.frametransparency.text:SetFont(STANDARD_TEXT_FONT, 10, "")
	MAIMENU.frametransparency.text:SetPoint("LEFT", MAIMENU.frametransparency, "RIGHT", 0, 0)
	MAIMENU.frametransparency.text:SetText( MAIGT("frametransparency") )
	if MAIGV( "nochanges" ) then
		MAIMENU.frametransparency:SetChecked( false )
		MAIMENU.frametransparency:Disable()
		MAIMENU.frametransparency.text:SetTextColor( 0.4, 0.4, 0.4, 1 )
	end

	py = py - btnh - bbr
	
	MAIAddChatCheckBox( "chatshortchannels", true, bbr, py )
	MAIAddChatCheckBox( "chatitemicons", true, bbr + btnw + sbr, py )

	py = py - btnh

	MAIAddChatCheckBox( "chatclassicons", true, bbr, py )
	MAIAddChatCheckBox( "chatraceicons", false, bbr + btnw + sbr, py )

	py = py - btnh

	MAIMENU.blockmessagesheader = MAIMENU:CreateFontString(nil, "ARTWORK")
	MAIMENU.blockmessagesheader:SetFont(STANDARD_TEXT_FONT, 10, "")
	MAIMENU.blockmessagesheader:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr, py)
	MAIMENU.blockmessagesheader:SetText(MAIGT("blockwords") .. " (, = seperator/empty = disabled):")

	py = py - bbr
	if MAIGV( "blockwords" ) == nil then
		MAISV( "blockwords", "BOOST,BUY GOLD" )
	end
	function MAICheckBlockedWords()
		if MAIGV( "blockwords" ) and MAIGV( "blockwords" ) ~= "" and MAIGV( "blockwords" ) ~= " " then
			for i, v in pairs({string.split(",", MAIGV( "blockwords" ) )}) do
				if strlen(v) < 3 then
					print("|cFFFF0000" .. "[MAI] " .. "Blockword \"" .. v .. "\" is to short!")
				end
			end
		end
	end
	MAICheckBlockedWords()
	MAIMENU.blockmessages = CreateFrame("EditBox", "MAIMENU.blockmessages", MAIMENU, "InputBoxTemplate")
	MAIMENU.blockmessages:SetSize(btnw * 2, btnh)
	MAIMENU.blockmessages:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr + 5, py)
	MAIMENU.blockmessages:SetText( MAIGV( "blockwords" ) or "" )
	MAIMENU.blockmessages:SetAutoFocus(false)
	MAIMENU.blockmessages:SetScript("OnTextChanged", function(self, value)
		self.lastchange = GetTime()
		C_Timer.After(1, function()
			if self.lastchange < GetTime() - 0.9 then
				if MAIGV( "blockwords" ) ~= self:GetText() then
					MAISV( "blockwords", self:GetText() )
					if self:GetText() ~= "" then
						print("|cFF00FF00" .. "[MAI] " .. "Blockwords changed to: |r")
						for i, v in pairs({string.split(",", MAIGV( "blockwords" ))}) do
							if strlen(v) < 3 then
								print(" • |cFFFF0000" .. v .. " [TO SHORT!]")
							else
								print(" • |cFF00FF00" .. v)
							end
						end
					else
						print("|cFFFF0000" .. "[MAI] " .. "Blockwords are disabled")
					end
				end
			end
		end)
	end)

	py = py - sbr - btnh - sbr - bbr

	MAIMENU.RESET = CreateFrame("Button", "MAIMENU.RESET", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.RESET:SetSize(btnw, btnh)
	MAIMENU.RESET:SetText(getglobal("RESET"))
	MAIMENU.RESET:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr, py)
	MAIMENU.RESET:SetScript("OnClick", function()
		local areyousure = CreateFrame("Frame", "AreYouSureReset", UIParent)
		areyousure:SetSize(bbr + btnw + bbr + btnw + bbr, 30 + bbr + btnh + bbr)
		areyousure:SetPoint("CENTER", UIParent, "CENTER", 0, -200)	

		areyousure.texture = areyousure:CreateTexture(nil, "BACKGROUND")
		areyousure.texture:SetAllPoints(areyousure)
		areyousure.texture:SetColorTexture(unpack(MAICOLORBACKGROUND))

		areyousure.textureHeader = areyousure:CreateTexture(nil, "BACKGROUND")
		areyousure.textureHeader:SetSize(areyousure:GetWidth(), sbr + btnh + sbr)
		areyousure.textureHeader:SetPoint("TOPLEFT", areyousure, "TOPLEFT", 0, 0)
		areyousure.textureHeader:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

		areyousure.textheader = areyousure:CreateFontString(nil, "ARTWORK")
		areyousure.textheader:SetFont(STANDARD_TEXT_FONT, 14, "")
		areyousure.textheader:SetPoint("LEFT", areyousure, "TOPLEFT", 5, -15)
		areyousure.textheader:SetText("Are you sure?")

		local yes = CreateFrame("Button", "done", areyousure, "UIPanelButtonTemplate")
		yes:SetSize(btnw, btnh) -- width, height
		yes:SetText(getglobal("YES"))
		yes:SetPoint("TOPLEFT", areyousure, "TOPLEFT", bbr, -30 - bbr)
		yes:SetScript("OnClick", function()
			MAITAB = {}
			C_UI.Reload()
		end)

		local no = CreateFrame("Button", "done", areyousure, "UIPanelButtonTemplate")
		no:SetSize(btnw, btnh) -- width, height
		no:SetText(getglobal("NO"))
		no:SetPoint("TOPLEFT", areyousure, "TOPLEFT", bbr + btnw + bbr, -30 - bbr)
		no:SetScript("OnClick", function()
			areyousure:Hide()
		end)
	end)

	MAIMENU.RELOAD = CreateFrame("Button", "MAIMENU.RELOAD", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.RELOAD:SetSize(btnw, btnh)
	MAIMENU.RELOAD:SetText(getglobal("RELOADUI"))
	MAIMENU.RELOAD:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr + btnw + sbr, py)
	MAIMENU.RELOAD:SetScript("OnClick", function()
		C_UI.Reload()
	end)

	py = py - btnh - sbr

	MAIMENU.CANCEL = CreateFrame("Button", "MAIMENU.CANCEL", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.CANCEL:SetSize(btnw, btnh)
	MAIMENU.CANCEL:SetText(getglobal("CANCEL"))
	MAIMENU.CANCEL:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr, py)
	MAIMENU.CANCEL:SetScript("OnClick", function()
		local reload = false
		if OLDMAITAB ~= nil then
			if not MAICheckIfSame(MAITAB["PROFILES"][MAIGCP()], OLDMAITAB) then
				reload = true
			end

			MAITAB["PROFILES"][MAIGCP()] = OLDMAITAB
		end

		MAIMENU:Hide()
		MAIMENUMOVING:Hide()
		if MAILoaded then
			MAISV( "menu", false )
			MAISV( "toggler", false )
		end

		MAIMENU.TOGGLE:SetText(MAIGT("unlock"))
		MAIMENUMOVING.TOGGLE:SetText(MAIGT("unlock"))

		if reload then
			C_UI.Reload()
		end
	end)

	MAIMENU.DONE = CreateFrame("Button", "MAIMENU.DONE", MAIMENU, "UIPanelButtonTemplate")
	MAIMENU.DONE:SetSize(btnw, btnh)
	MAIMENU.DONE:SetText(getglobal("DONE") .. " (" .. getglobal("RELOADUI") .. ")")
	MAIMENU.DONE:SetPoint("TOPLEFT", MAIMENU, "TOPLEFT", bbr + btnw + sbr, py)
	MAIMENU.DONE:SetScript("OnClick", function()
		MAIMENU:Hide()
		MAIMENUMOVING:Hide()
		MAISV( "menu", false )
		MAISV( "toggler", false )

		MAIMENU.TOGGLE:SetText(MAIGT("unlock"))
		MAIMENUMOVING.TOGGLE:SetText(MAIGT("unlock"))
		
		if not MAICheckIfSame(MAITAB["PROFILES"][MAIGCP()], OLDMAITAB) then
			C_UI.Reload()
		end
	end)

	py = py - btnh - bbr

	MAIMENU:SetSize( bbr + btnw + sbr + btnw + bbr, math.abs( py ) )

	local point = MAIGV( "MAIMENU" .. "point" )
	local relativePoint = MAIGV( "MAIMENU" .. "relativePoint" )
	local ofsx = MAIGV( "MAIMENU" .. "ofsx" )
	local ofsy = MAIGV( "MAIMENU" .. "ofsy" )

	if point then
		MAIMENU:SetPoint(point, nil, relativePoint, ofsx, ofsy)
	else
		MAIMENU:SetPoint("CENTER", nil, "CENTER", 0, 0)
	end

	MAIALPHAGRID = 0.2

	MAIGRID = CreateFrame("Frame", "MAIGRID", UIParent)
	MAIGRID:SetSize(GetScreenWidth(), GetScreenHeight())
	MAIGRID:SetPoint("CENTER", 0, 0)

	MAIGRID.texture = MAIGRID:CreateTexture(nil, "BACKGROUND")
	MAIGRID.texture:SetDrawLayer("BACKGROUND", 0)
	MAIGRID.texture:SetAllPoints(MAIGRID)
	MAIGRID.texture:SetColorTexture(1, 1, 1, 0)

	local co = 0
	for y = -MAIMathR(GetScreenHeight() / 2, 0), -GetScreenHeight(), -4 do
		MAIGRID.texture = MAIGRID:CreateTexture(nil, "ARTWORK")
		MAIGRID.texture:SetDrawLayer("ARTWORK", 7)
		MAIGRID.texture:SetSize(GetScreenWidth(), 1)
		MAIGRID.texture:SetPoint("TOPLEFT", 0, y)
		if y == -MAIMathR(GetScreenHeight() / 2, 0) then
			MAIGRID.texture:SetColorTexture(0, 1, 0, MAIALPHAGRID)
		elseif co % 25 == 0 then
			MAIGRID.texture:SetColorTexture(1, 0, 0, MAIALPHAGRID)
		elseif co % 5 == 0 then
			MAIGRID.texture:SetColorTexture(0, 0, 1, MAIALPHAGRID)
		else
			--MAIGRID.texture:SetColorTexture(0, 0, 0, MAIALPHAGRID)
		end
		co = co + 1
	end
	co = 0
	for y = -MAIMathR(GetScreenHeight() / 2, 0), 0, 4 do
		MAIGRID.texture = MAIGRID:CreateTexture(nil, "ARTWORK")
		MAIGRID.texture:SetDrawLayer("ARTWORK", 7)
		MAIGRID.texture:SetSize(GetScreenWidth(), 1)
		MAIGRID.texture:SetPoint("TOPLEFT", 0, y)
		if y == -MAIMathR(GetScreenHeight() / 2, 0) then
			MAIGRID.texture:SetColorTexture(0, 1, 0, 1)
		elseif co % 25 == 0 then
			MAIGRID.texture:SetColorTexture(1, 0, 0, MAIALPHAGRID)
		elseif co % 5 == 0 then
			MAIGRID.texture:SetColorTexture(0, 0, 1, MAIALPHAGRID)
		else
			--MAIGRID.texture:SetColorTexture(0, 0, 0, MAIALPHAGRID)
		end
		co = co + 1
	end
	co = 0
	for x = MAIMathR(GetScreenWidth() / 2, 0), GetScreenWidth(), 4 do
		MAIGRID.texture = MAIGRID:CreateTexture(nil, "ARTWORK")
		MAIGRID.texture:SetDrawLayer("ARTWORK", 7)
		MAIGRID.texture:SetSize(1, GetScreenHeight())
		MAIGRID.texture:SetPoint("TOPLEFT", x, 0)
		if x == MAIMathR(GetScreenWidth() / 2, 0) then
			MAIGRID.texture:SetColorTexture(0, 1, 0, 1)
		elseif co % 25 == 0 then
			MAIGRID.texture:SetColorTexture(1, 0, 0, MAIALPHAGRID)
		elseif co % 5 == 0 then
			MAIGRID.texture:SetColorTexture(0, 0, 1, MAIALPHAGRID)
		else
			--MAIGRID.texture:SetColorTexture(0, 0, 0, MAIALPHAGRID)
		end
		co = co + 1
	end
	co = 0
	for x = MAIMathR(GetScreenWidth() / 2, 0), 0, -4 do
		MAIGRID.texture = MAIGRID:CreateTexture(nil, "ARTWORK")
		MAIGRID.texture:SetDrawLayer("ARTWORK", 7)
		MAIGRID.texture:SetSize(1, GetScreenHeight())
		MAIGRID.texture:SetPoint("TOPLEFT", x, 0)
		if x == MAIMathR(GetScreenWidth() / 2, 0) then
			MAIGRID.texture:SetColorTexture(0, 1, 0, 1)
		elseif co % 25 == 0 then
			MAIGRID.texture:SetColorTexture(1, 0, 0, MAIALPHAGRID)
		elseif co % 5 == 0 then
			MAIGRID.texture:SetColorTexture(0, 0, 1, MAIALPHAGRID)
		else
			--MAIGRID.texture:SetColorTexture(0, 0, 0, MAIALPHAGRID)
		end
		co = co + 1
	end

	MAIINFO = CreateFrame("Frame", "MAIGRID", UIParent)
	MAIINFO:SetSize(GetScreenWidth(), GetScreenHeight())
	MAIINFO:SetPoint("CENTER", 0, 0)

	MAIINFO.text = MAIINFO:CreateFontString(nil, "ARTWORK")
	MAIINFO.text:SetFont(STANDARD_TEXT_FONT, 40, "THINOUTLINE")
	MAIINFO.text:SetPoint("CENTER", MAIINFO, "CENTER", 0, 0)
	MAIINFO.text:SetText(MAIGT("elements") .. ": " .. MAIGT("locked"))

	MAIINFO.text2 = MAIINFO:CreateFontString(nil, "ARTWORK")
	MAIINFO.text2:SetFont(STANDARD_TEXT_FONT, 70, "THINOUTLINE")
	MAIINFO.text2:SetPoint( "CENTER", MAIINFO, "CENTER", 0, 200 )
	MAIINFO.text2:SetText("FSTACK Enabled")
	MAIINFO.text2:SetTextColor( 1, 1, 0, 1 )

	function MAIToggleDragger()
		MAISV( "toggler", not MAIGV( "toggler" ) )

		if MAIGV( "toggler" ) then
			LoadAddOn("Blizzard_ArenaUI")
			MAIMENUMOVING:Show()
			MAIMENU:Hide()
		else
			MAIMENUMOVING:Hide()
			MAIMENU:Show()
		end

		if MAIGV( "toggler" ) then
			MAIMENU.TOGGLE:SetText(MAIGT("lock"))
			MAIMENUMOVING.TOGGLE:SetText(MAIGT("lock"))
		else
			MAIMENU.TOGGLE:SetText(MAIGT("unlock"))
			MAIMENUMOVING.TOGGLE:SetText(MAIGT("unlock"))
		end
	end

	function MAITHINKING()
		if MAILoaded and (MAITHINKER.toggler ~= MAIGV( "toggler" ) or MAITHINKER.tabsize ~= getn(MAITHINKER.tab) or MAITHINKER.force == true) then
			MAITHINKER.toggler = MAIGV( "toggler" )
			MAITHINKER.tabsize = getn(MAITHINKER.tab)
			MAITHINKER.force = false

			if MAIGV( "toggler" ) then
				MAIGRID:Show()
			else
				MAIGRID:Hide()
			end

			for i, v in pairs(MAITHINKER.tab) do
				if not InCombatLockdown() then
					if MAIGV( "toggler" ) and MAIGV( v.element.name .. "Enabled" ) then
						local show = true
						if MAIGV( "hideunmoved" ) and not MAIGV( v.element.name .. "move" ) then
							show = false
						end
						if MAIGV( "hidehidden" ) and MAIGV( v.element.name .. "hide" ) then
							show = false
						end
						if show then
							v:Show()
							if v.settingsbtn then
								v.settingsbtn:EnableMouse(true)
							end
							v.settingsmove:EnableMouse(true)
						else
							v:Hide()
							if v.settingsbtn then
							v.settingsbtn:EnableMouse(false)
							end
							v.settingsmove:EnableMouse(false)
						end
					else
						v:Hide()
						if v.settingsbtn then
						v.settingsbtn:EnableMouse(false)
						end
						v.settingsmove:EnableMouse(false)
					end
				end
			end
		end

		if not MAIGV( "toggler" ) and MAIMENU:IsShown() then
			MAIINFO.text:SetText(MAIGT("elements") .. ": " .. MAIGT("locked"))
		else
			MAIINFO.text:SetText("")
		end
		
		local tooltip = FrameStackTooltip;
		if tooltip and ( tooltip:IsVisible() ) then
			MAIINFO.text2:SetAlpha( 1 )
		else
			MAIINFO.text2:SetAlpha( 0 )
		end

		C_Timer.After(0.3, MAITHINKING)
	end
	MAITHINKING()

	MAITHINKER.alphaframes = {}
	MAITHINKER.update = true
	function MAITHINKINGALPHA()
		if MAITHINKER.update or MAITHINKER.fsize ~= #MAITHINKER.frames then
			MAITHINKER.fsize = #MAITHINKER.frames
			MAITHINKER.update = false

			MAITHINKER.alphaframes = {} -- new table
			for i, s in pairs(MAITHINKER.frames) do
				if not MAIGV( s.element.name .. "hide" ) and (MAIGV( s.element.name .. "alpha", 1 ) ~= 1 or MAIGV( s.element.name .. "alpha2", 1 ) ~= 1 or MAIGV( s.element.name .. "alpha3", 1 ) ~= 1) then
					tinsert(MAITHINKER.alphaframes, s)
				end
			end
		end
	
		for i, s in pairs(MAITHINKER.alphaframes) do
			if s.frame._alpha == nil then
				s.frame._alpha = 1
			end

			if UnitInVehicle and UnitInVehicle("PLAYER") then
				s.frame._alpha = MAIGV( s.frame.element.name .. "alpha3", 1 )
			elseif MouseIsOver(s.frame) or SpellFlyout and MouseIsOver(SpellFlyout) and SpellFlyout:GetParent() and SpellFlyout:GetParent():GetParent():GetName() == s.frame.flyoutname then
				s.frame._alpha = 1
			elseif InCombatLockdown() then
				s.frame._alpha = MAIGV( s.frame.element.name .. "alpha2", 1 )
			elseif not InCombatLockdown() then
				s.frame._alpha = MAIGV( s.frame.element.name .. "alpha", 1 )
			end

			s.frame._alpha = MAIMathC( s.frame._alpha, 0, 1 )
			if MAIMathR(s.frame:GetAlpha(), 2) ~= s.frame._alpha then
				s.frame:SetAlpha(s.frame._alpha)
				if s.frame.btns ~= nil then
					for i, v in pairs(s.frame.btns) do
						v:SetAlpha(s.frame._alpha)
					end
				end
			end
		end

		if MAIGV( "toggler" ) then
			C_Timer.After(0.09, MAITHINKINGALPHA)
		else
			C_Timer.After(0.5, MAITHINKINGALPHA)
		end
	end
	MAITHINKINGALPHA()

	if mcur == 0 then
		MAIMENU.ELEMENTS:Click()
	end
end

function MAIOpenMenu()
	MAISV( "menu", true )
	if MAIGV( "menu" ) then
		if MAIGV( "toggler" ) then
			MAIMENUMOVING:Show()
			MAIMENU:Hide()
		else
			MAIMENUMOVING:Hide()
			MAIMENU:Show()
		end
		OLDMAITAB = MAICopy_Table( MAITAB["PROFILES"][MAIGCP()] )
	end
end

function MAIToggleMenu()
	MAISV( "menu", not MAIGV( "menu" ) )
	if MAIGV( "menu" ) then
		if MAIGV( "toggler" ) then
			MAIMENUMOVING:Show()
			MAIMENU:Hide()
		else
			MAIMENUMOVING:Hide()
			MAIMENU:Show()
		end

		OLDMAITAB = MAICopy_Table( MAITAB["PROFILES"][MAIGCP()] )
	else
		MAIMENU:Hide()
		MAIMENUMOVING:Hide()
	end
end

SLASH_MAI1, SLASH_MAI2, SLASH_MAI3 = "/mai", "/moveandimprove", "/mai help"
SlashCmdList["MAI"] = function(msg)
	if msg == "" then
		MAISV( "menu", not MAIGV( "menu" ) )
		if MAIGV( "menu" ) then
			if MAIGV( "toggler" ) then
				MAIMENUMOVING:Show()
				MAIMENU:Hide()
			else
				MAIMENUMOVING:Hide()
				MAIMENU:Show()
			end

			OLDMAITAB = MAICopy_Table( MAITAB["PROFILES"][MAIGCP()] )
		else
			MAIMENU:Hide()
			MAIMENUMOVING:Hide()
		end
	elseif msg == "help" then
		MAIMSGS()
		MAIMSG("HELP")
		MAIMSG("----- ----- ----- ----- ----- ----- ----- ----- -----")
		MAIMSG("1. Drag all elements out of the mid")
		MAIMSGS()
		MAIMSG("2. If you want just some, press on disable all")
		MAIMSG("Then enable the ones you want to move")
		MAIMSG("----- ----- ----- ----- ----- ----- ----- ----- -----")
		MAIMSG("If something works wrong -> Press on Refresh!")
		MAIMSG("Still wrong? May be a bug, report it via my discord")
		MAIMSG("----- ----- ----- ----- ----- ----- ----- ----- -----")
		MAIMSGS()
	end
end

SLASH_RL1 = "/rl"
SlashCmdList["RL"] = function(msg)
	C_UI.Reload()
end

function MAIElementSetup(element)
	if MAILoaded and MAIGV( element.name .. "Enabled" ) then
		if _G[element.name] == nil then
			C_Timer.After(0.1, function()
				MAIElementSetup(element)
			end)
		else
			local mover = CreateFrame( "FRAME", element.name .. "Mover", UIParent)
			mover:Hide()
			mover.element = element -- assign element
			if MAIGV( element.name .. "sizew" ) == nil then
				MAISV( element.name .. "sizew", 60 )
			end
			if MAIGV( element.name .. "sizeh" ) == nil then
				MAISV( element.name .. "sizeh", 60 )
			end
			if MAIGV( element.name .. "scale" ) == nil then
				MAISV( element.name .. "scale", 1 )
			end
			mover:SetSize( MAIGV( element.name .. "sizew" ), MAIGV( element.name .. "sizeh" ) ) -- set default size
			mover:SetScale( MAIGV( element.name .. "scale" ) )
			mover:SetPoint("CENTER", 0, 0)
			mover:SetFrameStrata("HIGH")

			mover.texture = mover:CreateTexture(nil, "BACKGROUND")
			mover.texture:SetAllPoints(mover)
			mover.texture:SetColorTexture(0.7, 0.7, 1.0, 0.5)

			mover.text = mover:CreateFontString(nil, "ARTWORK")
			mover.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
			mover.text:SetPoint("TOP", mover, "TOP", 0, -2)
			mover.text:SetText(MAIGT(element.lstr))

			mover.textcenter = mover:CreateFontString(nil, "ARTWORK")
			mover.textcenter:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
			mover.textcenter:SetPoint("CENTER", mover, "CENTER", 0, 0)
			mover.textcenter:SetText("FRAME NOT CREATED YET")
			
			mover.textmove= mover:CreateFontString(nil, "ARTWORK")
			mover.textmove:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
			mover.textmove:SetPoint("BOTTOMLEFT", mover, "BOTTOMLEFT", 16, 1)

			-- Drag and Drop
			mover:SetClampedToScreen(true)
			mover:SetMovable(true)
			mover:EnableMouse(true)
			mover:RegisterForDrag("LeftButton")
			mover.isMoving = false
			mover:SetScript("OnDragStart", function(self)
				if self.frame and self.frame.element.forcedrag then
					self.frame:ClearAllPoints()
				end
				self.isMoving = true
				self:StartMoving()
			end)
			mover:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing()
				self.isMoving = false
				
				local point, parent, relativePoint, ofsx, ofsy = self:GetPoint()

				if point then
					ofsx = MAIMathR(ofsx, 0)
					ofsy = MAIMathR(ofsy, 0)

					if parent == nil then
						-- SNAP TO BORDER / CENTER
						local snap = 10
						local snapgrid = 10

						if ofsx < snap and ofsx > -snap then
							ofsx = 0
						end
						if ofsy < snap and ofsy > -snap then
							ofsy = 0
						end

						-- SNAP TO GRID
						if MAIGV( "snaptogrid" ) then
							if ofsx >= 0 then
								if ofsx % 10 == 0 then
									-- nothing
								elseif ofsx % snapgrid <= snapgrid / 2 then
									ofsx = ofsx - (ofsx % snapgrid)
								else
									ofsx = ofsx + (snapgrid - ofsx % snapgrid)
								end
							else
								if ofsx % 10 == 0 then
									-- nothing
								elseif -ofsx % snapgrid <= snapgrid / 2 then
									ofsx = ofsx + (snapgrid - ofsx % snapgrid)
								else
									ofsx = ofsx - (ofsx % snapgrid)
								end
							end
							if ofsy >= 0 then
								if ofsy % 10 == 0 then
									-- nothing
								elseif ofsy % snapgrid <= snapgrid / 2 then
									ofsy = ofsy - (ofsy % snapgrid)
								else
									ofsy = ofsy + (snapgrid - ofsy % snapgrid)
								end
							else
								if ofsy % 10 == 0 then
									-- nothing
								elseif -ofsy % snapgrid <= snapgrid / 2 then
									ofsy = ofsy + (snapgrid - ofsy % snapgrid)
								else
									ofsy = ofsy - (ofsy % snapgrid)
								end
							end
						end
						
						self:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)

						if self.frame and self.frame.element.forcedrag then
							self.frame.force = true
							self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
						end
					end
					
					MAISV( self.element.name .. "point", point )
					MAISV( self.element.name .. "relativePoint", relativePoint )
					MAISV( self.element.name .. "ofsx", ofsx )
					MAISV( self.element.name .. "ofsy", ofsy )
				else
					MAIERR(mover:GetName() .. " DRAG-FAIL")
				end
			end)

			if MAIGV( element.name .. "move" ) == nil then
				MAISV( element.name .. "move", true )
			end

			if MAIGV( element.name .. "improvements" ) == nil then
				MAISV( element.name .. "improvements", true )
			end

			if MAIGV( element.name .. "hideartwork" ) == nil then
				MAISV( element.name .. "hideartwork", true )
			end

			if MAIGV( element.name .. "hide" ) == nil then
				MAISV( element.name .. "hide", false )
			end
			
			if MAIGV( element.name .. "alpha" ) == nil then -- alpha outside of combat
				MAISV( element.name .. "alpha", 1 )
			end
			if MAIGV( element.name .. "alpha2" ) == nil then -- alpha inside of combat
				MAISV( element.name .. "alpha2", 1 )
			end

			function mover.Think()
				if mover.frame == nil then
					if _G[mover.element.name] ~= nil then
						mover.frame = _G[mover.element.name]
						if not InCombatLockdown() or MAIEVENT == "PLAYER_ENTERING_WORLD" then
							local mov = mover
							-- link them
							mover.frame.mover = mover
							mover.frame.element = mover.element

							-- Fix them
							if element.setmovable or element.setuserplaced then
								if mover.frame.SetMovable then
									mover.frame:SetMovable(true)
								end
							end
							if element.setuserplaced then
								if mover.frame.SetUserPlaced then
									mover.frame:SetUserPlaced(true)
								end
							end

							-- IGNORE BLIZZARD
							mover.frame:SetAttribute('ignoreFramePositionManager', true )
							mover.frame.ignoreFramePositionManager = true
							UIPARENT_MANAGED_FRAME_POSITIONS[mover.element.name] = nil

							-- Scale
							if MAIGV( mover.element.name .. "scale" ) == nil then
								MAISV( mover.element.name .. "scale", 1 )
							end
							hooksecurefunc(mover.frame, "SetScale", function(s, scale)
								if s.setscale then return end
								s.setscale = true

								s:SetScale( MAIGV( mov.element.name .. "scale" ) )
								mover:SetScale( MAIGV( mov.element.name .. "scale" ) )

								if mov.settingsbtn then
									mov.settingsbtn:SetScale( 1 / MAIGV( mov.element.name .. "scale" ) )
									mov.settingsmove:SetScale( 1 / MAIGV( mov.element.name .. "scale" ) )
									mov.textcenter:SetScale( 1 / MAIGV( mov.element.name .. "scale" ) )
									mov.textmove:SetScale( 1 / MAIGV( mov.element.name .. "scale" ) )
									mov.text:SetScale( 1 / MAIGV( mov.element.name .. "scale" ) )
								end

								s.setscale = false
							end)
							if MAIGV( mover.element.name .. "scale" ) ~= 1 then
								mover.frame:SetScale( MAIGV( mover.element.name .. "scale" ) )
							end

							-- Size
							hooksecurefunc(mover.frame, "SetSize", function(s)
								local osw, osh = mover.frame:GetSize()
								local sw = nil
								local sh = nil
								if mov.element.sw ~= nil then
									sw = mov.element.sw
								end
								if mov.element.sh ~= nil then
									sh = mov.element.sh
								end

								if sw then
									MAISV( element.name .. "sizew", sw )
								end
								if sh then
									MAISV( element.name .. "sizeh", sh )
								end

								if osw ~= sw or osh ~= sh then
									if sw == nil then
										sw = osw
									end
									if sh == nil then
										sh = osh
									end
									if sw and sh then
										mover:SetSize(sw, sh)
									elseif sw then
										mover:SetWidth(sw)
									elseif sh then
										mover:SetHeight(sh)
									end
								end
							end)
							local _sw, _sh = mover.frame:GetSize()
							mover.frame:SetSize(_sw, _sh)
							
							-- Position
							if MAIGV( mover.element.name .. "move" ) then
								hooksecurefunc(mover.frame, "SetPoint", function(s, ...)
									if s.maisetpoint then return end
									s.maisetpoint = true

									if element.setmovable or element.setuserplaced then
										if s.SetMovable then
											s:SetMovable(true)
										end
									end
									if element.setuserplaced then
										if s.SetUserPlaced then
											s:SetUserPlaced(true)
										end
									end

									if s.OldClearAllPoints and s.OldSetPoint and s ~= GameTooltip then
										if mov.element.name ~= "Minimap" or Minimap:GetParent() ~= FarmHud then
											s:OldClearAllPoints()
											s:OldSetPoint(mov.element.anchor, mov, mov.element.anchor, 0, 0)
										end
									else
										if mov.element.name ~= "Minimap" or Minimap:GetParent() ~= FarmHud then
											s:ClearAllPoints()
											s:SetPoint(mov.element.anchor, mov, mov.element.anchor, 0, 0)
										end
									end
									
									if element.setmovable or element.setuserplaced then
										if s.SetMovable then
											s:SetMovable(false)
										end
									end								
									
									s.maisetpoint = false
								end)
								if element.setmovable or element.setuserplaced then
									if mover.frame.SetMovable then
										mover.frame:SetMovable(true)
									end
								end
								if element.setuserplaced then
									if mover.frame.SetUserPlaced then
										mover.frame:SetUserPlaced(true)
									end
								end

								if MAIGV( mover.element.name .. "point" ) ~= nil then
									if mover.frame:GetPoint() then
										mover.frame:SetPoint(mover.frame:GetPoint())
									else
										mover.frame:SetPoint("CENTER")
									end
								end

								local point = MAIGV( mover.element.name .. "point" )
								local parent = nil
								local relativePoint = MAIGV( mover.element.name .. "relativePoint" )
								local ofsx = MAIGV( mover.element.name .. "ofsx" )
								local ofsy = MAIGV( mover.element.name .. "ofsy" )
								mover:ClearAllPoints()

								if point then
									mover.force = true
									mover:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
									mover.force = false
								else
									point, parent, relativePoint, ofsx, ofsy = mover.frame:GetPoint()
									if point and parent == nil or parent == UIParent then
										mover:SetPoint(point, parent, relativePoint, ofsx, ofsy)
									else
										local l, b, w, h = mover.frame:GetRect()
										if l == nil and b == nil then
											mover:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
										else -- Position from Original
											mover:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", l, b)
										end
									end
								end
								point, parent, relativePoint, ofsx, ofsy = mover:GetPoint()
								if point and MAIGV( mover.element.name .. "point" ) == nil then
									MAISV( mover.element.name .. "point", point )
									MAISV( mover.element.name .. "relativePoint", relativePoint )
									MAISV( mover.element.name .. "ofsx", MAIMathR(ofsx, 0) )
									MAISV( mover.element.name .. "ofsy", MAIMathR(ofsy, 0) )
								end
							end
								

							-- Hide
							if MAIGV( mover.element.name .. "hide" ) then
								hooksecurefunc(mover.frame, "Show", function(s)
									if s.show then return end
									s.show = true
									if MAIGV( s.element.name .. "hide" ) then
										if not InCombatLockdown() then
											s:EnableMouse(false)
										end
										s:SetAlpha(0)
									end
									s.show = false
								end)
								if mover.frame.btns then
									for i, v in pairs(mover.frame.btns) do
										v.element = {}
										v.element.name = element.name
										hooksecurefunc(v, "Show", function(s)
											if s.show then return end
											s.show = true
											if MAIGV( s.element.name .. "hide" ) then
												if not InCombatLockdown() then
													s:EnableMouse(false)
												end
												s:SetAlpha(0)
											end
											s.show = false
										end)
									end
								end
								if MAIGV( mover.element.name .. "hide" ) then
									mover.frame:SetAlpha(0)
									if mover.frame.btns then
										for i, v in pairs(mover.frame.btns) do
											v:SetAlpha(0)
										end
									end
								end
							else
								tinsert(MAITHINKER.frames, mover)
							end

							-- Setup
							if mover.element.setup ~= nil then
								if MAIGV( "nochanges" ) and not mover.element.nochanges or not MAIGV( "nochanges" ) then
									if type( mover.element.setup ) == "string" then
										_G[ mover.element.setup ]()
									else
										mover.element.setup()
									end
								else
									--
								end
							end
						else
							if MAIGV( mover.element.name .. "hide" ) then
								mover.frame:SetAlpha(0)
							end
						end
					end
				end

				if MAIGV( "toggler" ) then
					mover.textcenter:SetAlpha(1)
					mover.textmove:SetAlpha(1)
					mover.text:SetAlpha(1)
					if MAIGV( mover.element.name .. "hide" ) then
						mover.texture:SetColorTexture(0.2, 0.2, 0.2, 0.5)
					elseif MAIGV( mover.element.name .. "move" ) then
						if MouseIsOver(mover) then
							mover.texture:SetColorTexture(1.0, 1.0, 0.7, 0.1)
							mover.textcenter:SetAlpha(0)
							mover.textmove:SetAlpha(0)
							mover.text:SetAlpha(0)
						else
							mover.texture:SetColorTexture(0.7, 0.7, 1.0, 0.5)
						end
					else
						mover.texture:SetColorTexture(0.7, 0.0, 0.0, 0.5)
					end

					if MAIGV( mover.element.name .. "hide" ) then
						mover.textcenter:SetText(MAIGT("hidden"))
					else
						local _, _, _, px, py = mover:GetPoint()
						px = MAIMathR(px, 0)
						py = MAIMathR(py, 0)
						mover.textcenter:SetText("X: " .. px .. " Y: " .. py)
					end

					if MAIGV( mover.element.name .. "move" ) then
						mover.textmove:SetText(MAIGT("move"))
					else
						mover.textmove:SetText(MAIGT("notmove"))
					end
				end

				if MAIGV( "toggler" ) then
					C_Timer.After(0.3, mover.Think)
				else
					C_Timer.After(1, mover.Think)
				end
			end
			mover.Think()

			local point = MAIGV( mover.element.name .. "point" )
			local relativePoint = MAIGV( mover.element.name .. "relativePoint" )
			local ofsx = MAIGV( mover.element.name .. "ofsx" )
			local ofsy = MAIGV( mover.element.name .. "ofsy" )
			mover:ClearAllPoints()
			if point then
				mover:SetPoint(point, UIParent, relativePoint, ofsx, ofsy)
			end

			mover.settingsbtn = CreateFrame("Button", "settingsbtn", mover, "UIPanelButtonTemplate")
			mover.settingsbtn.Text:SetFont(STANDARD_TEXT_FONT, 8, "")
			mover.settingsbtn:SetText(getglobal("SETTINGS")) --strsub(getglobal("SETTINGS"), 0, 3))
			local tw = mover.settingsbtn.Text:GetStringWidth()
			mover.settingsbtn:SetSize(tw + 10, 14)
			mover.settingsbtn:SetPoint("BOTTOMRIGHT", mover, "BOTTOMRIGHT", 2, 0)
			mover.settingsbtn:SetScript("OnClick", function(self)
				if mover.settings == nil then
					mover.settings = CreateFrame("FRAME")
					mover.settings:SetSize(440, 210)
					MAIPNLINDEX = MAIPNLINDEX or 0
					MAIPNLINDEX = MAIPNLINDEX + 1
					if MAIPNLINDEX > 7 then
						MAIPNLINDEX = 0
					end
					mover.settings:SetPoint("CENTER", -100 + MAIPNLINDEX * 100, -100 + MAIPNLINDEX * 100)
					mover.settings:SetFrameStrata("DIALOG", MAIPNLINDEX)
					mover.settings.tabs = {}

					mover.settings:SetClampedToScreen(true)
					mover.settings:SetMovable(true)
					mover.settings:EnableMouse(true)
					mover.settings:RegisterForDrag("LeftButton")
					mover.settings:SetScript("OnDragStart", mover.settings.StartMoving)
					mover.settings:SetScript("OnDragStop", mover.settings.StopMovingOrSizing)
					
					mover.settings.texture = mover.settings:CreateTexture(nil, "BACKGROUND")
					--mover.settings.texture:SetDrawLayer("BACKGROUND", MAIPNLINDEX)
					mover.settings.texture:SetSize(mover.settings:GetWidth(), 20)
					mover.settings.texture:SetPoint("TOPLEFT", 0, 0)
					mover.settings.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

					mover.settings.texture2 = mover.settings:CreateTexture(nil, "BACKGROUND")
					--mover.settings.texture2:SetDrawLayer("BACKGROUND", MAIPNLINDEX)
					mover.settings.texture2:SetSize(mover.settings:GetWidth(), 20)
					mover.settings.texture2:SetPoint("TOPLEFT", 0, -20)
					mover.settings.texture2:SetColorTexture(0, 0, 0, 0)

					mover.textheader = mover.settings:CreateFontString(nil, "ARTWORK")
					mover.textheader:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.textheader:SetPoint("LEFT", mover.settings, "TOPLEFT", 10, -10)
					mover.textheader:SetText(MAIGT(mover.element.lstr))

					mover.settings.close = CreateFrame("Button", nil, mover.settings, "UIPanelButtonTemplate")
					mover.settings.close:SetText("X")
					mover.settings.close:SetSize(20, 20)
					mover.settings.close:SetPoint("TOPRIGHT", 0, 0)
					mover.settings.close:SetScript("OnClick", function(self)
						mover.settings:Hide()
						mover.settings.visible = false
					end)

					function mover.settings.SelectTab(movertab)
						for i, v in pairs(mover.settings.tabs) do
							v.texture:SetColorTexture(unpack(MAICOLORBACKGROUND))
							v.selected = false
							v.content:Hide()
						end
						movertab.selected = true
						movertab.content:Show()
						movertab.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))
					end



					-- TAB1 - General
					mover.tab1 = CreateFrame("Button", nil, mover.settings)
					mover.tab1:SetSize(100, 20)
					mover.tab1:SetPoint("TOPLEFT", 0, -20)
					mover.tab1.selected = true
					mover.tab1:SetScript("OnClick", function(self)
						mover.settings.SelectTab(mover.tab1)
					end)
					tinsert(mover.settings.tabs, mover.tab1)

					mover.tab1.texture = mover.tab1:CreateTexture(nil, "Background")
					mover.tab1.texture:SetAllPoints(mover.tab1)
					mover.tab1.texture:SetColorTexture(0.1, 0.1, 0.1, 1)

					mover.tab1.text = mover.tab1:CreateFontString(nil, "ARTWORK")
					mover.tab1.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.tab1.text:SetPoint("CENTER", mover.tab1, "CENTER", 0, 0)
					mover.tab1.text:SetText(getglobal("GENERAL"))



					-- TAB1 - Content
					mover.tab1.content = CreateFrame( "FRAME", nil, mover.settings)
					mover.tab1.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
					mover.tab1.content:SetPoint("TOPLEFT", 0, -40)

					mover.tab1.content.texture = mover.tab1.content:CreateTexture(nil, "Background")
					mover.tab1.content.texture:SetAllPoints(mover.tab1.content)
					mover.tab1.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))



					mover.textpos = mover.tab1.content:CreateFontString(nil, "ARTWORK")
					mover.textpos:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.textpos:SetPoint("LEFT", mover.tab1.content, "TOPLEFT", 10, -10)
					mover.textpos:SetText(getglobal("POSITION"))
					function mover.TextThink()
						if mover.textpos:IsShown() then
							if MAIGV( element.name .. "ofsx" ) ~= nil and MAIGV( element.name .. "ofsy" ) ~= nil then
								mover.textpos:SetText(MAIGT("position") .. ": " .. MAIGV( element.name .. "ofsx" ) .. "," .. MAIGV( element.name .. "ofsy" ) )
							else
								mover.textpos:SetText("Position not saved yet")
							end
						end
						C_Timer.After(0.5, mover.TextThink)
					end
					mover.TextThink()

					mover.tab1.content.upf = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.upf:SetSize(20, 20)
					mover.tab1.content.upf:SetPoint("TOPLEFT", 50, -20)
					mover.tab1.content.upf:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
					mover.tab1.content.upf:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
					mover.tab1.content.upf:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.upf:SetScript("OnClick", function(self)
						local point, parent, relativePoint, ofsx, ofsy = mover:GetPoint()
						if point then
							ofsy = ofsy + 10
							MAISV( element.name .. "point", point )
							MAISV( element.name .. "relativePoint", relativePoint )
							MAISV( element.name .. "ofsx", MAIMathR(ofsx, 0) )
							MAISV( element.name .. "ofsy", MAIMathR(ofsy, 0) )

							mover:SetPoint(point, parent, relativePoint, ofsx, ofsy)
						end
					end)

					mover.tab1.content.up = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.up:SetSize(20, 20)
					mover.tab1.content.up:SetPoint("TOPLEFT", 50, -35)
					mover.tab1.content.up:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
					mover.tab1.content.up:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
					mover.tab1.content.up:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.up:SetScript("OnClick", function(self)
						local point, parent, relativePoint, ofsx, ofsy = mover:GetPoint()
						if point then
							ofsy = ofsy + 1
							MAISV( element.name .. "point", point )
							MAISV( element.name .. "relativePoint", relativePoint )
							MAISV( element.name .. "ofsx", MAIMathR(ofsx, 0) )
							MAISV( element.name .. "ofsy", MAIMathR(ofsy, 0) )

							mover:SetPoint(point, parent, relativePoint, ofsx, ofsy)
						end
					end)

					mover.tab1.content.dn = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.dn:SetText("D")
					mover.tab1.content.dn:SetSize(20, 20)
					mover.tab1.content.dn:SetPoint("TOPLEFT", 50, -75)
					mover.tab1.content.dn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
					mover.tab1.content.dn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
					mover.tab1.content.dn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.dn:SetScript("OnClick", function(self)
						local point, parent, relativePoint, ofsx, ofsy = mover:GetPoint()
						if point then
							ofsy = ofsy - 1
							MAISV( element.name .. "point", point )
							MAISV( element.name .. "relativePoint", relativePoint )
							MAISV( element.name .. "ofsx", MAIMathR(ofsx, 0) )
							MAISV( element.name .. "ofsy", MAIMathR(ofsy, 0) )

							mover:SetPoint(point, parent, relativePoint, ofsx, ofsy)
						end
					end)

					mover.tab1.content.dnf = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.dnf:SetText("D")
					mover.tab1.content.dnf:SetSize(20, 20)
					mover.tab1.content.dnf:SetPoint("TOPLEFT", 50, -90)
					mover.tab1.content.dnf:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
					mover.tab1.content.dnf:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
					mover.tab1.content.dnf:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.dnf:SetScript("OnClick", function(self)
						local point, parent, relativePoint, ofsx, ofsy = mover:GetPoint()
						if point then
							ofsy = ofsy - 10
							MAISV( element.name .. "point", point )
							MAISV( element.name .. "relativePoint", relativePoint )
							MAISV( element.name .. "ofsx", MAIMathR(ofsx, 0) )
							MAISV( element.name .. "ofsy", MAIMathR(ofsy, 0) )

							mover:SetPoint(point, parent, relativePoint, ofsx, ofsy)
						end
					end)

					mover.tab1.content.rif = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.rif:SetSize(20, 20)
					mover.tab1.content.rif:SetPoint("TOPLEFT", 85, -55)
					mover.tab1.content.rif:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
					mover.tab1.content.rif:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
					mover.tab1.content.rif:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.rif:SetScript("OnClick", function(self)
						local point, parent, relativePoint, ofsx, ofsy = mover:GetPoint()
						if point then
							ofsx = ofsx + 10
							MAISV( element.name .. "point", point )
							MAISV( element.name .. "relativePoint", relativePoint )
							MAISV( element.name .. "ofsx", MAIMathR(ofsx, 0) )
							MAISV( element.name .. "ofsy", MAIMathR(ofsy, 0) )

							mover:SetPoint(point, parent, relativePoint, ofsx, ofsy)
						end
					end)

					mover.tab1.content.ri = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.ri:SetSize(20, 20)
					mover.tab1.content.ri:SetPoint("TOPLEFT", 70, -55)
					mover.tab1.content.ri:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
					mover.tab1.content.ri:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
					mover.tab1.content.ri:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.ri:SetScript("OnClick", function(self)
						local point, parent, relativePoint, ofsx, ofsy = mover:GetPoint()
						if point then
							ofsx = ofsx + 1
							MAISV( element.name .. "point", point )
							MAISV( element.name .. "relativePoint", relativePoint )
							MAISV( element.name .. "ofsx", MAIMathR(ofsx, 0) )
							MAISV( element.name .. "ofsy", MAIMathR(ofsy, 0) )

							mover:SetPoint(point, parent, relativePoint, ofsx, ofsy)
						end
					end)

					mover.tab1.content.li = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.li:SetSize(20, 20)
					mover.tab1.content.li:SetPoint("TOPLEFT", 30, -55)
					mover.tab1.content.li:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
					mover.tab1.content.li:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
					mover.tab1.content.li:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.li:SetScript("OnClick", function(self)
						local point, parent, relativePoint, ofsx, ofsy = mover:GetPoint()
						if point then
							ofsx = ofsx - 1
							MAISV( element.name .. "point", point )
							MAISV( element.name .. "relativePoint", relativePoint )
							MAISV( element.name .. "ofsx", MAIMathR(ofsx, 0) )
							MAISV( element.name .. "ofsy", MAIMathR(ofsy, 0) )

							mover:SetPoint(point, parent, relativePoint, ofsx, ofsy)
						end
					end)

					mover.tab1.content.lif = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.lif:SetSize(20, 20)
					mover.tab1.content.lif:SetPoint("TOPLEFT", 15, -55)
					mover.tab1.content.lif:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
					mover.tab1.content.lif:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
					mover.tab1.content.lif:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.lif:SetScript("OnClick", function(self)
						local point, parent, relativePoint, ofsx, ofsy = mover:GetPoint()
						if point then
							ofsx = ofsx - 10
							MAISV( element.name .. "point", point )
							MAISV( element.name .. "relativePoint", relativePoint )
							MAISV( element.name .. "ofsx", MAIMathR(ofsx, 0) )
							MAISV( element.name .. "ofsy", MAIMathR(ofsy, 0) )

							mover:SetPoint(point, parent, relativePoint, ofsx, ofsy)
						end
					end)

					MAISV( element.name .. "scale", MAIGV( element.name .. "scale" ) or 1 )
					mover.textsca = mover.tab1.content:CreateFontString(nil, "ARTWORK")
					mover.textsca:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.textsca:SetPoint("LEFT", mover.tab1.content, "TOPLEFT", 150, -10)
					mover.textsca:SetText(MAIGT("scale") .. ": " .. MAIGV( element.name .. "scale" ) )

					mover.tab1.content.scaleup = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.scaleup:SetSize(20, 20)
					mover.tab1.content.scaleup:SetPoint("TOPLEFT", 150, -20)
					mover.tab1.content.scaleup:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
					mover.tab1.content.scaleup:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
					mover.tab1.content.scaleup:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.scaleup:SetScript("OnClick", function(self)
						local newval = MAIMathR(mover:GetScale() + 0.1, 1)
						newval = MAIMathC(newval, 0.1, 4.0)
						MAISV( element.name .. "scale", newval )
						mover:SetScale(mover:GetScale() + 0.1)
						_G[element.name]:SetScale(_G[element.name]:GetScale() + 0.1)
						mover.textsca:SetText(MAIGT("scale") .. ": " .. MAIGV( element.name .. "scale" ) )
					end)

					mover.tab1.content.scaleup = CreateFrame("Button", nil, mover.tab1.content)
					mover.tab1.content.scaleup:SetText("D")
					mover.tab1.content.scaleup:SetSize(20, 20)
					mover.tab1.content.scaleup:SetPoint("TOPLEFT", 150, -40)
					mover.tab1.content.scaleup:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
					mover.tab1.content.scaleup:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
					mover.tab1.content.scaleup:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
					mover.tab1.content.scaleup:SetScript("OnClick", function(self)
						local newval = MAIMathR(mover:GetScale() - 0.1, 1)
						newval = MAIMathC(newval, 0.1, 4.0)
						MAISV( element.name .. "scale", newval )
						mover:SetScale(mover:GetScale() - 0.1)
						_G[element.name]:SetScale(_G[element.name]:GetScale() - 0.1)
						mover.textsca:SetText(MAIGT("scale") .. ": " .. MAIGV( element.name .. "scale" ) )
					end)

					mover.tab1.content.move = CreateFrame("CheckButton", "moversettingsenabled", mover.tab1.content, "ChatConfigCheckButtonTemplate")
					mover.tab1.content.move:SetSize(20, 20)
					mover.tab1.content.move:SetPoint("TOPLEFT", 10, -120)
					mover.tab1.content.move:SetChecked( MAIGV( element.name .. "move" ) )
					mover.tab1.content.move:SetScript("OnClick", function(self)
						local newval = self:GetChecked()
						MAISV( element.name .. "move", newval )
					end)
					mover.tab1.content.move.text = mover.tab1.content.move:CreateFontString(nil, "ARTWORK")
					mover.tab1.content.move.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.tab1.content.move.text:SetPoint("LEFT", mover.tab1.content.move, "RIGHT", 0, 0)
					mover.tab1.content.move.text:SetText(MAIGT("move"))



					mover.tab1.content.improvements = CreateFrame("CheckButton", "moversettingsimprovements", mover.tab1.content, "ChatConfigCheckButtonTemplate")
					mover.tab1.content.improvements:SetSize(20, 20)
					mover.tab1.content.improvements:SetPoint("TOPLEFT", 10, -140)
					mover.tab1.content.improvements:SetChecked(MAIGV( element.name .. "improvements" ) )
					mover.tab1.content.improvements:SetScript("OnClick", function(self)
						local newval = self:GetChecked()
						MAISV( element.name .. "improvements", newval )
					end)
					mover.tab1.content.improvements.text = mover.tab1.content.improvements:CreateFontString(nil, "ARTWORK")
					mover.tab1.content.improvements.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.tab1.content.improvements.text:SetPoint("LEFT", mover.tab1.content.improvements, "RIGHT", 0, 0)
					mover.tab1.content.improvements.text:SetText(MAIGT("improvements"))



					mover.tab1.content.hideartwork = CreateFrame("CheckButton", "moversettingshideartwork", mover.tab1.content, "ChatConfigCheckButtonTemplate")
					mover.tab1.content.hideartwork:SetSize(20, 20)
					mover.tab1.content.hideartwork:SetPoint("TOPLEFT", 10, -160)
					mover.tab1.content.hideartwork:SetChecked(MAIGV( element.name .. "hideartwork" ) )
					mover.tab1.content.hideartwork:SetScript("OnClick", function(self)
						local newval = self:GetChecked()
						MAISV( element.name .. "hideartwork", newval )
					end)
					mover.tab1.content.hideartwork.text = mover.tab1.content.hideartwork:CreateFontString(nil, "ARTWORK")
					mover.tab1.content.hideartwork.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.tab1.content.hideartwork.text:SetPoint("LEFT", mover.tab1.content.hideartwork, "RIGHT", 0, 0)
					mover.tab1.content.hideartwork.text:SetText(MAIGT("hideartwork"))



					-- TAB - Appearance
					mover.tabapp = CreateFrame("Button", nil, mover.settings)
					mover.tabapp:SetSize(100, 20)
					mover.tabapp:SetPoint("TOPLEFT", 105, -20)
					mover.tabapp.selected = false
					mover.tabapp:SetScript("OnClick", function(self)
						mover.settings.SelectTab(mover.tabapp)
					end)
					tinsert(mover.settings.tabs, mover.tabapp)

					mover.tabapp.texture = mover.tabapp:CreateTexture(nil, "Background")
					mover.tabapp.texture:SetAllPoints(mover.tabapp)
					mover.tabapp.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

					mover.tabapp.text = mover.tabapp:CreateFontString(nil, "ARTWORK")
					mover.tabapp.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.tabapp.text:SetPoint("CENTER", mover.tabapp, "CENTER", 0, 0)
					mover.tabapp.text:SetText(getglobal("APPEARANCE_LABEL"))



					-- TAB - Appearance Content
					mover.tabapp.content = CreateFrame( "FRAME", nil, mover.settings)
					mover.tabapp.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
					mover.tabapp.content:SetPoint("TOPLEFT", 0, -40)

					mover.tabapp.content.texture = mover.tabapp.content:CreateTexture(nil, "Background")
					mover.tabapp.content.texture:SetAllPoints(mover.tabapp.content)
					mover.tabapp.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))




					MAISV( element.name .. "alpha", MAIGV( element.name .. "alpha" ) or 1 )
					mover.textalp = mover.tabapp.content:CreateFontString(nil, "ARTWORK")
					mover.textalp:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.textalp:SetPoint("LEFT", mover.tabapp.content, "TOPLEFT", 10, -10)
					mover.textalp:SetText(MAIGT("outofcombat"))

					mover.tabapp.content.alpha = MAICreateSlider(mover.tabapp.content, element.name, "alpha", MAIGV( element.name .. "alpha" ), 10, -20, 0, 1, 0.1, ".1f", OPACITY)
					mover.tabapp.content.alpha:HookScript("OnValueChanged", function(self, val)
						if self.alpha ~= MAIGV( element.name .. "alpha" ) then
							self.alpha = MAIGV( element.name .. "alpha" )
							_G[element.name]._alpha = 1
							_G[element.name]:SetAlpha(MAIGV( element.name .. "alpha", 1 ) )
							if _G[element.name].btns ~= nil then
								for i, v in pairs(_G[element.name].btns) do
									v:SetAlpha(MAIGV( element.name .. "alpha", 1 ) )
								end
							end

							MAITHINKER.update = true
						end
					end)

					MAISV( element.name .. "alpha2", MAIGV( element.name .. "alpha2" ) or 1 )
					mover.textalp2 = mover.tabapp.content:CreateFontString(nil, "ARTWORK")
					mover.textalp2:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.textalp2:SetPoint("LEFT", mover.tabapp.content, "TOPLEFT", 10, -50)
					mover.textalp2:SetText(MAIGT("incombat"))

					mover.tabapp.content.alpha2 = MAICreateSlider(mover.tabapp.content, element.name, "alpha2", MAIGV( element.name .. "alpha2" ), 10, -60, 0, 1, 0.1, ".1f", OPACITY)
					mover.tabapp.content.alpha2:HookScript("OnValueChanged", function(self, val)
						if self.alpha2 ~= MAIGV( element.name .. "alpha2" ) then
							self.alpha2 = MAIGV( element.name .. "alpha2" )
							_G[element.name]._alpha = 1
							_G[element.name]:SetAlpha(MAIGV( element.name .. "alpha2" ) )
							if _G[element.name].btns ~= nil then
								for i, v in pairs(_G[element.name].btns) do
									v:SetAlpha(MAIGV( element.name .. "alpha2" ) )
								end
							end

							MAITHINKER.update = true
						end
					end)

					MAISV( element.name .. "alpha3", MAIGV( element.name .. "alpha3" ) or 1 )
					mover.textalp3 = mover.tabapp.content:CreateFontString(nil, "ARTWORK")
					mover.textalp3:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.textalp3:SetPoint("LEFT", mover.tabapp.content, "TOPLEFT", 10, -90)
					mover.textalp3:SetText(MAIGT("invehicle"))

					mover.tabapp.content.alpha3 = MAICreateSlider(mover.tabapp.content, element.name, "alpha3", MAIGV( element.name .. "alpha3" ), 10, -100, 0, 1, 0.1, ".1f", OPACITY)
					mover.tabapp.content.alpha3:HookScript("OnValueChanged", function(self, val)
						if self.alpha3 ~= MAIGV( element.name .. "alpha3" ) then
							self.alpha3 = MAIGV( element.name .. "alpha3" )
							_G[element.name]._alpha = 1
							_G[element.name]:SetAlpha(MAIGV( element.name .. "alpha3" ) )
							if _G[element.name].btns ~= nil then
								for i, v in pairs(_G[element.name].btns) do
									v:SetAlpha(MAIGV( element.name .. "alpha3" ) )
								end
							end

							MAITHINKER.update = true
						end
					end)

					mover.tabapp.content.show = CreateFrame("CheckButton", "moversettingsshow", mover.tabapp.content, "ChatConfigCheckButtonTemplate")
					mover.tabapp.content.show:SetSize(20, 20)
					mover.tabapp.content.show:SetPoint("TOPLEFT", 10, -140)
					mover.tabapp.content.show:SetChecked(MAIGV( element.name .. "hide" ) )
					mover.tabapp.content.show:SetScript("OnClick", function(self)
						local newval = self:GetChecked()
						MAISV( element.name .. "hide", newval )
					end)
					mover.tabapp.content.show.text = mover.tabapp.content.show:CreateFontString(nil, "ARTWORK")
					mover.tabapp.content.show.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
					mover.tabapp.content.show.text:SetPoint("LEFT", mover.tabapp.content.show, "RIGHT", 0, 0)
					mover.tabapp.content.show.text:SetText(getglobal("HIDE"))



					local bars = {}
					for x = 1, MAIMAXBAR do
						tinsert(bars, "ActionBar" .. x)
					end
					tinsert(bars, "StanceBar")
					tinsert(bars, "PetBar")
					tinsert(bars, "MAIMicroButtons")

					if tContains(bars, element.name) then
						-- TAB2 - ActionButton
						mover.tab2 = CreateFrame("Button", nil, mover.settings)
						mover.tab2:SetSize(100, 20)
						mover.tab2:SetPoint("TOPLEFT", 210, -20)
						mover.tab2.selected = true
						mover.tab2:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab2)
						end)
						tinsert(mover.settings.tabs, mover.tab2)

						mover.tab2.texture = mover.tab2:CreateTexture(nil, "Background")
						mover.tab2.texture:SetAllPoints(mover.tab2)
						mover.tab2.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab2.text = mover.tab2:CreateFontString(nil, "ARTWORK")
						mover.tab2.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab2.text:SetPoint("CENTER", mover.tab2, "CENTER", 0, 0)
						mover.tab2.text:SetText(MAIGT("bar"))



						-- TAB2 - Content
						mover.tab2.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab2.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab2.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab2.content.texture = mover.tab2.content:CreateTexture(nil, "Background")
						mover.tab2.content.texture:SetAllPoints(mover.tab2.content)
						mover.tab2.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))



						local CB = LibDD:Create_UIDropDownMenu(element.name .. "rowscb", mover.tab2.content)
						CB:SetPoint("TOPLEFT", -10, -4)
						LibDD:UIDropDownMenu_SetWidth(CB, 80)
						LibDD:UIDropDownMenu_SetText(CB, MAIGV( element.name .. "rows" ) )
						LibDD:UIDropDownMenu_Initialize(CB, function(self, level, menuList)
							local tab = {}
							local count = MAIGV( element.name .. "count" )
							tinsert(tab, 1)
							if count == 2 then
								tinsert(tab, 2)
							elseif count == 3 then
								tinsert(tab, 3)
							elseif count == 4 then
								tinsert(tab, 2)
								tinsert(tab, 4)
							elseif count == 5 then
								tinsert(tab, 5)
							elseif count == 6 then
								tinsert(tab, 2)
								tinsert(tab, 3)
								tinsert(tab, 6)
							elseif count == 7 then
								tinsert(tab, 7)
							elseif count == 8 then
								tinsert(tab, 2)
								tinsert(tab, 4)
								tinsert(tab, 8)
							elseif count == 9 then
								tinsert(tab, 3)
								tinsert(tab, 9)
							elseif count == 10 then
								tinsert(tab, 2)
								tinsert(tab, 5)
								tinsert(tab, 10)
							elseif count == 11 then
								tinsert(tab, 11)
							elseif count == 12 then
								tinsert(tab, 2)
								tinsert(tab, 3)
								tinsert(tab, 4)
								tinsert(tab, 6)
								tinsert(tab, 12)
							end
							tinsert(tab, "max")
							
							for i, v in pairs(tab) do
								local info = LibDD:UIDropDownMenu_CreateInfo()
								info.func = self.SetValue
								info.text = v
								info.arg1 = v
								LibDD:UIDropDownMenu_AddButton(info)
							end
						end)
						function CB:SetValue(newValue)
							MAISV( element.name .. "rows", newValue )
							LibDD:UIDropDownMenu_SetText( CB, newValue )
							CloseDropDownMenus()

							MAIUpdateActionButton()
							if MAIUpdateMAIMicroButtons then
								MAIUpdateMAIMicroButtons()
							end
						end
						local text = CB:CreateFontString(nil, "ARTWORK")
						text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						text:SetPoint("LEFT", CB, "RIGHT", -10, 4)
						text:SetText(MAIGT("rows"))
						
						local vmax = 12
						if element.name == "PetBar" then
							vmax = 10
						elseif element.name == "CharacterMicroButton" and MAIBUILD ~= "RETAIL" then
							vmax = 8
						end

						MAICreateSlider(mover.tab2.content, element.name, "spacing", 4, 10, -50, -6, 36, 1.0, ".0f", "spacing")

						if element.name ~= "MAIMicroButtons" then
							MAICreateSlider(mover.tab2.content, element.name, "count", vmax, 10, -80, 1, vmax, 1.0, ".0f", "count")
						end

						if string.find(element.name, "ActionBar") then
							if MAIGV( element.name .. "hidehk" ) == nil then
								MAISV( element.name .. "hidehk", false )
							end
							mover.tab2.content.hidehk = CreateFrame("CheckButton", "moversettingsenabled", mover.tab2.content, "ChatConfigCheckButtonTemplate")
							mover.tab2.content.hidehk:SetSize(20, 20)
							mover.tab2.content.hidehk:SetPoint("TOPLEFT", 10, -110)
							mover.tab2.content.hidehk:SetChecked( MAIGV( element.name .. "hidehk" ) )
							mover.tab2.content.hidehk:SetScript("OnClick", function(self)
								local newval = self:GetChecked()
								MAISV( element.name .. "hidehk", newval )
								MAIUpdateActionButton()
							end)
							mover.tab2.content.hidehk.text = mover.tab2.content.hidehk:CreateFontString(nil, "ARTWORK")
							mover.tab2.content.hidehk.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
							mover.tab2.content.hidehk.text:SetPoint("LEFT", mover.tab2.content.hidehk, "RIGHT", 0, 0)
							mover.tab2.content.hidehk.text:SetText("Hide Hotkeys")
							
							if MAIGV( element.name .. "hidena" ) == nil then
								MAISV( element.name .. "hidena", false )
							end
							mover.tab2.content.hidena = CreateFrame("CheckButton", "moversettingsenabled", mover.tab2.content, "ChatConfigCheckButtonTemplate")
							mover.tab2.content.hidena:SetSize(20, 20)
							mover.tab2.content.hidena:SetPoint("TOPLEFT", 10, -130)
							mover.tab2.content.hidena:SetChecked( MAIGV( element.name .. "hidena" ) )
							mover.tab2.content.hidena:SetScript("OnClick", function(self)
								local newval = self:GetChecked()
								MAISV( element.name .. "hidena", newval )
								MAIUpdateActionButton()
							end)
							mover.tab2.content.hidena.text = mover.tab2.content.hidena:CreateFontString(nil, "ARTWORK")
							mover.tab2.content.hidena.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
							mover.tab2.content.hidena.text:SetPoint("LEFT", mover.tab2.content.hidena, "RIGHT", 0, 0)
							mover.tab2.content.hidena.text:SetText("Hide Name")
						end
					end

					if element.name == "BagBar" then
						-- TAB3 - Bags
						mover.tab3 = CreateFrame("Button", nil, mover.settings)
						mover.tab3:SetSize(100, 20)
						mover.tab3:SetPoint("TOPLEFT", 210, -20)
						mover.tab3.selected = true
						mover.tab3:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab3)
						end)
						tinsert(mover.settings.tabs, mover.tab3)

						mover.tab3.texture = mover.tab3:CreateTexture(nil, "Background")
						mover.tab3.texture:SetAllPoints(mover.tab3)
						mover.tab3.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab3.text = mover.tab3:CreateFontString(nil, "ARTWORK")
						mover.tab3.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab3.text:SetPoint("CENTER", mover.tab3, "CENTER", 0, 0)
						mover.tab3.text:SetText(getglobal("BAGSLOT"))



						-- tab3 - Content
						mover.tab3.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab3.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab3.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab3.content.texture = mover.tab3.content:CreateTexture(nil, "Background")
						mover.tab3.content.texture:SetAllPoints(mover.tab3.content)
						mover.tab3.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))



						mover.tab3.content.onebag = CreateFrame("CheckButton", "moversettingsenabled", mover.tab3.content, "ChatConfigCheckButtonTemplate")
						mover.tab3.content.onebag:SetSize(20, 20)
						mover.tab3.content.onebag:SetPoint("TOPLEFT", 10, -10)
						mover.tab3.content.onebag:SetChecked(MAIGV( element.name .. "onebag" ) )
						mover.tab3.content.onebag:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "onebag", newval )
						end)
						mover.tab3.content.onebag.text = mover.tab3.content.onebag:CreateFontString(nil, "ARTWORK")
						mover.tab3.content.onebag.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab3.content.onebag.text:SetPoint("LEFT", mover.tab3.content.onebag, "RIGHT", 0, 0)
						mover.tab3.content.onebag.text:SetText("One bag")
					end

					if element.name == "Minimap" then
						-- TAB4 - ActionButton
						mover.tab4 = CreateFrame("Button", nil, mover.settings)
						mover.tab4:SetSize(100, 20)
						mover.tab4:SetPoint("TOPLEFT", 210, -20)
						mover.tab4.selected = true
						mover.tab4:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab4)
						end)
						tinsert(mover.settings.tabs, mover.tab4)

						mover.tab4.texture = mover.tab4:CreateTexture(nil, "Background")
						mover.tab4.texture:SetAllPoints(mover.tab4)
						mover.tab4.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab4.text = mover.tab4:CreateFontString(nil, "ARTWORK")
						mover.tab4.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab4.text:SetPoint("CENTER", mover.tab4, "CENTER", 0, 0)
						mover.tab4.text:SetText(getglobal("MINIMAP_LABEL"))



						-- TAB4 - Content
						mover.tab4.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab4.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab4.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab4.content.texture = mover.tab4.content:CreateTexture(nil, "Background")
						mover.tab4.content.texture:SetAllPoints(mover.tab4.content)
						mover.tab4.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						if MAIGV( element.name .. "form" ) == nil then
							MAISV( element.name .. "form", "paper2" )
						end

						local CB = LibDD:Create_UIDropDownMenu(element.name .. "formcb", mover.tab4.content)
						CB:SetPoint("TOPLEFT", -10, -4)
						LibDD:UIDropDownMenu_SetWidth(CB, 80)
						LibDD:UIDropDownMenu_SetText(CB, MAIGV( element.name .. "form" ) )
						LibDD:UIDropDownMenu_Initialize(CB, function(self, level, menuList)
							local tab = {}
							tinsert(tab, "paper")
							tinsert(tab, "paper2")
							tinsert(tab, "square")
							tinsert(tab, "round")

							for i, v in pairs(tab) do
								local info = LibDD:UIDropDownMenu_CreateInfo()
								info.func = self.SetValue
								info.text = v
								info.arg1 = v
								LibDD:UIDropDownMenu_AddButton(info)
							end
						end)
						function CB:SetValue(newValue)
							MAISV( element.name .. "form", newValue )
							LibDD:UIDropDownMenu_SetText(CB, newValue )
							CloseDropDownMenus()

							MAIUpdateActionButton()
							if MAIUpdateMAIMicroButtons then
								MAIUpdateMAIMicroButtons()
							end

							C_UI.Reload()
						end
						local text = CB:CreateFontString(nil, "ARTWORK")
						text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						text:SetPoint("LEFT", CB, "RIGHT", -10, 4)
						text:SetText(MAIGT("form"))

						if MAIGV( element.name .. "hideminimapbuttons" ) == nil then
							MAISV( element.name .. "hideminimapbuttons", true )
						end
						local hideminimapbuttons = CreateFrame("CheckButton", "hideminimapbuttons", mover.tab4.content, "ChatConfigCheckButtonTemplate")
						hideminimapbuttons:SetSize(20, 20)
						hideminimapbuttons:SetPoint("TOPLEFT", 10, -40)
						hideminimapbuttons:SetChecked(MAIGV( element.name .. "hideminimapbuttons" ) )
						hideminimapbuttons:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "hideminimapbuttons", newval )
						end)
						hideminimapbuttons.text = hideminimapbuttons:CreateFontString(nil, "ARTWORK")
						hideminimapbuttons.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						hideminimapbuttons.text:SetPoint("LEFT", hideminimapbuttons, "RIGHT", 0, 0)
						hideminimapbuttons.text:SetText(MAIGT("hideminimapbuttons"))

						local range = CreateFrame("CheckButton", "range", mover.tab4.content, "ChatConfigCheckButtonTemplate")
						range:SetSize(20, 20)
						range:SetPoint("TOPLEFT", 10, -60)
						range:SetChecked(MAIGV( element.name .. "range" ) )
						range:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "range", newval )
						end)
						range.text = range:CreateFontString(nil, "ARTWORK")
						range.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						range.text:SetPoint("LEFT", range, "RIGHT", 0, 0)
						range.text:SetText(MAIGT("range"))
					end

					if element.name == "DurabilityFrame" then
						-- TAB5 - ActionButton
						mover.tab5 = CreateFrame("Button", nil, mover.settings)
						mover.tab5:SetSize(100, 20)
						mover.tab5:SetPoint("TOPLEFT", 210, -20)
						mover.tab5.selected = true
						mover.tab5:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab5)
						end)
						tinsert(mover.settings.tabs, mover.tab5)

						mover.tab5.texture = mover.tab5:CreateTexture(nil, "Background")
						mover.tab5.texture:SetAllPoints(mover.tab5)
						mover.tab5.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab5.text = mover.tab5:CreateFontString(nil, "ARTWORK")
						mover.tab5.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab5.text:SetPoint("CENTER", mover.tab5, "CENTER", 0, 0)
						mover.tab5.text:SetText(getglobal("DURABILITY"))



						-- TAB5 - Content
						mover.tab5.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab5.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab5.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab5.content.texture = mover.tab5.content:CreateTexture(nil, "Background")
						mover.tab5.content.texture:SetAllPoints(mover.tab5.content)
						mover.tab5.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))



						local gold = CreateFrame("CheckButton", "gold", mover.tab5.content, "ChatConfigCheckButtonTemplate")
						gold:SetSize(20, 20)
						gold:SetPoint("TOPLEFT", 10, -20)
						gold:SetChecked(MAIGV( element.name .. "gold" ) )
						gold:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "gold", newval )
						end)
						gold.text = gold:CreateFontString(nil, "ARTWORK")
						gold.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						gold.text:SetPoint("LEFT", gold, "RIGHT", 0, 0)
						gold.text:SetText(MAIGT("gold"))

						local ilvl = CreateFrame("CheckButton", "ilvl", mover.tab5.content, "ChatConfigCheckButtonTemplate")
						ilvl:SetSize(20, 20)
						ilvl:SetPoint("TOPLEFT", 10, -40)
						ilvl:SetChecked(MAIGV( element.name .. "ilvl" ) )
						ilvl:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "ilvl", newval )
						end)
						ilvl.text = ilvl:CreateFontString(nil, "ARTWORK")
						ilvl.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						ilvl.text:SetPoint("LEFT", ilvl, "RIGHT", 0, 0)
						ilvl.text:SetText(MAIGT("ilvl"))
					end

					if element.name == "MAIStatusBar" then
						-- TAB6 - ActionButton
						mover.tab6 = CreateFrame("Button", nil, mover.settings)
						mover.tab6:SetSize(100, 20)
						mover.tab6:SetPoint("TOPLEFT", 210, -20)
						mover.tab6.selected = true
						mover.tab6:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab6)
						end)
						tinsert(mover.settings.tabs, mover.tab6)

						mover.tab6.texture = mover.tab6:CreateTexture(nil, "Background")
						mover.tab6.texture:SetAllPoints(mover.tab6)
						mover.tab6.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab6.text = mover.tab6:CreateFontString(nil, "ARTWORK")
						mover.tab6.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab6.text:SetPoint("CENTER", mover.tab6, "CENTER", 0, 0)
						mover.tab6.text:SetText(MAIGT("MAIStatusBar"))



						-- TAB6 - Content
						mover.tab6.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab6.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab6.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab6.content.texture = mover.tab6.content:CreateTexture(nil, "Background")
						mover.tab6.content.texture:SetAllPoints(mover.tab6.content)
						mover.tab6.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))



						MAISV( element.name .. "width", MAIGV( element.name .. "width" ) or 1000 )

						mover.tab6.content.width = MAICreateSlider(mover.tab6.content, element.name, "width", MAIGV( element.name .. "width" ), 10, -30, 100, 1600, 10.0, ".0f", MAIGT("width"))
						mover.tab6.content.width:HookScript("OnValueChanged", function(self, val)
							if MAIGV( element.name .. "width" ) and MAIGV( element.name .. "width" ) > 1600 then
								MAISV( element.name .. "width", 1600 )
							end
							if self.width ~= MAIGV( element.name .. "width" ) then
								self.width = MAIGV( element.name .. "width" )
								_G[element.name]:SetWidth(MAIGV( element.name .. "width" ) )
							end
						end)

						MAISV( element.name .. "height", MAIGV( element.name .. "height" ) or 30 )
						if MAIGV( element.name .. "height" ) == 20 and MAIGV( element.name .. "fixed" ) == nil then
							MAISV( element.name .. "fixed", true )
							MAISV( element.name .. "height", 40 )
						end

						mover.tab6.content.height = MAICreateSlider(mover.tab6.content, element.name, "height", MAIGV( element.name .. "height" ), 10, -70, 10, 100, 1.0, ".0f", MAIGT("height"))
						mover.tab6.content.height:HookScript("OnValueChanged", function(self, val)
							if self.height ~= MAIGV( element.name .. "height" ) then
								self.height = MAIGV( element.name .. "height" )
								_G[element.name]:SetHeight(MAIGV( element.name .. "height" ) )
							end
						end)

						if MAIGV( element.name .. "showonlywhenhovered" ) == nil then
							MAISV( element.name .. "showonlywhenhovered", false )
						end

						local showonlywhenhovered = CreateFrame("CheckButton", "showonlywhenhovered", mover.tab6.content, "ChatConfigCheckButtonTemplate")
						showonlywhenhovered:SetSize(20, 20)
						showonlywhenhovered:SetPoint("TOPLEFT", 10, -100)
						showonlywhenhovered:SetChecked(MAIGV( element.name .. "showonlywhenhovered" ) )
						showonlywhenhovered:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "showonlywhenhovered", newval )
						end)
						showonlywhenhovered.text = showonlywhenhovered:CreateFontString(nil, "ARTWORK")
						showonlywhenhovered.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						showonlywhenhovered.text:SetPoint("LEFT", showonlywhenhovered, "RIGHT", 0, 0)
						showonlywhenhovered.text:SetText(MAIGT("showonlywhenhovered"))

						if MAIGV( element.name .. "autoselectfaction" ) == nil then
							MAISV( element.name .. "autoselectfaction", true )
						end

						if not MAIGV( "nochanges" ) then
							local autoselectfaction = CreateFrame("CheckButton", "autoselectfaction", mover.tab6.content, "ChatConfigCheckButtonTemplate")
							autoselectfaction:SetSize(20, 20)
							autoselectfaction:SetPoint("TOPLEFT", 10, -120)
							autoselectfaction:SetChecked(MAIGV( element.name .. "autoselectfaction" ) )
							autoselectfaction:SetScript("OnClick", function(self)
								local newval = self:GetChecked()
								MAISV( element.name .. "autoselectfaction", newval )
							end)
							autoselectfaction.text = autoselectfaction:CreateFontString(nil, "ARTWORK")
							autoselectfaction.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
							autoselectfaction.text:SetPoint("LEFT", autoselectfaction, "RIGHT", 0, 0)
							autoselectfaction.text:SetText(MAIGT("autoselectfaction"))

							local missingxp = CreateFrame("CheckButton", "missingxp", mover.tab6.content, "ChatConfigCheckButtonTemplate")
							missingxp:SetSize(20, 20)
							missingxp:SetPoint("TOPLEFT", 10, -140)
							missingxp:SetChecked(MAIGV( element.name .. "missingxp", true ) )
							missingxp:SetScript("OnClick", function(self)
								local newval = self:GetChecked()
								MAISV( element.name .. "missingxp", newval )
							end)
							missingxp.text = missingxp:CreateFontString(nil, "ARTWORK")
							missingxp.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
							missingxp.text:SetPoint("LEFT", missingxp, "RIGHT", 0, 0)
							missingxp.text:SetText(MAIGT("missingxp"))
						end
					end

					if element.name == "GameTooltip" and not MAIGV( "nochanges" ) then
						-- TAB7 - GameTooltip
						mover.tab7 = CreateFrame("Button", nil, mover.settings)
						mover.tab7:SetSize(100, 20)
						mover.tab7:SetPoint("TOPLEFT", 210, -20)
						mover.tab7.selected = true
						mover.tab7:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab7)
						end)
						tinsert(mover.settings.tabs, mover.tab7)

						mover.tab7.texture = mover.tab7:CreateTexture(nil, "Background")
						mover.tab7.texture:SetAllPoints(mover.tab7)
						mover.tab7.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab7.text = mover.tab7:CreateFontString(nil, "ARTWORK")
						mover.tab7.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab7.text:SetPoint("CENTER", mover.tab7, "CENTER", 0, 0)
						mover.tab7.text:SetText(MAIGT("tooltip"))



						-- tab7 - Content
						mover.tab7.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab7.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab7.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab7.content.texture = mover.tab7.content:CreateTexture(nil, "Background")
						mover.tab7.content.texture:SetAllPoints(mover.tab7.content)
						mover.tab7.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						function MAIAddCB( parent, ele, key, value, x, y )
							local opt = CreateFrame("CheckButton", key, parent, "ChatConfigCheckButtonTemplate")
							opt:SetSize(20, 20)
							opt:SetPoint("TOPLEFT", x, y)
							opt:SetChecked(MAIGV( ele .. key ) )
							opt:SetScript("OnClick", function(self)
								local newval = self:GetChecked()
								MAISV( ele .. key, newval )
							end)
							opt.text = opt:CreateFontString(nil, "ARTWORK")
							opt.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
							opt.text:SetPoint("LEFT", opt, "RIGHT", 0, 0)
							opt.text:SetText(MAIGT(key))
						end
						
						MAIAddCB( mover.tab7.content, element.name, "oncursor", false, 10, -10 )
						MAIAddCB( mover.tab7.content, element.name, "sellprice", false, 10, -30 )
						MAIAddCB( mover.tab7.content, element.name, "ilevel", false, 10, -50 )
						MAIAddCB( mover.tab7.content, element.name, "showcountryflag", true, 10, -70 )
						MAIAddCB( mover.tab7.content, element.name, "expansion", false, 10, -90 )
					end

					if element.name == "MAIBuffFrame" then
						-- TAB8 - MAIBuffFrame
						mover.tab8 = CreateFrame("Button", nil, mover.settings)
						mover.tab8:SetSize(100, 20)
						mover.tab8:SetPoint("TOPLEFT", 210, -20)
						mover.tab8.selected = true
						mover.tab8:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab8)
						end)
						tinsert(mover.settings.tabs, mover.tab8)

						mover.tab8.texture = mover.tab8:CreateTexture(nil, "Background")
						mover.tab8.texture:SetAllPoints(mover.tab8)
						mover.tab8.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab8.text = mover.tab8:CreateFontString(nil, "ARTWORK")
						mover.tab8.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab8.text:SetPoint("CENTER", mover.tab8, "CENTER", 0, 0)
						mover.tab8.text:SetText(MAIGT("buffframe"))



						-- tab8 - Content
						mover.tab8.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab8.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab8.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab8.content.texture = mover.tab8.content:CreateTexture(nil, "Background")
						mover.tab8.content.texture:SetAllPoints(mover.tab8.content)
						mover.tab8.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						if MAIGV( element.name .. "accuratetime" ) == nil then
							MAISV( element.name .. "accuratetime", true )
						end

						local accuratetime = CreateFrame("CheckButton", "accuratetime", mover.tab8.content, "ChatConfigCheckButtonTemplate")
						accuratetime:SetSize(20, 20)
						accuratetime:SetPoint("TOPLEFT", 10, -10)
						accuratetime:SetChecked(MAIGV( element.name .. "accuratetime" ) )
						accuratetime:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "accuratetime", newval )
						end)
						accuratetime.text = accuratetime:CreateFontString(nil, "ARTWORK")
						accuratetime.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						accuratetime.text:SetPoint("LEFT", accuratetime, "RIGHT", 0, 0)
						accuratetime.text:SetText(MAIGT("accuratetime"))

						MAISV( element.name .. "spacing", MAIGV( element.name .. "spacing" ) or 2 )
						mover.tab8.content.spacing = MAICreateSlider(mover.tab8.content, element.name, "spacing", MAIGV( element.name .. "spacing" ), 10, -60, 0, 20, 1.0, "1.0d", MAIGT("spacing"))
					end

					if element.name == "StanceBar" then
						-- TAB9 - StanceBar
						mover.tab9 = CreateFrame("Button", nil, mover.settings)
						mover.tab9:SetSize(100, 20)
						mover.tab9:SetPoint("TOPLEFT", 210 + 100 + 10, -20)
						mover.tab9.selected = true
						mover.tab9:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab9)
						end)
						tinsert(mover.settings.tabs, mover.tab9)

						mover.tab9.texture = mover.tab9:CreateTexture(nil, "Background")
						mover.tab9.texture:SetAllPoints(mover.tab9)
						mover.tab9.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab9.text = mover.tab9:CreateFontString(nil, "ARTWORK")
						mover.tab9.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab9.text:SetPoint("CENTER", mover.tab9, "CENTER", 0, 0)
						mover.tab9.text:SetText(MAIGT("stancebar"))



						-- tab9 - Content
						mover.tab9.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab9.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab9.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab9.content.texture = mover.tab9.content:CreateTexture(nil, "Background")
						mover.tab9.content.texture:SetAllPoints(mover.tab9.content)
						mover.tab9.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						if MAIGV( element.name .. "allclasses" ) == nil then
							MAISV( element.name .. "allclasses", true )
						end

						local allclasses = CreateFrame("CheckButton", "allclasses", mover.tab9.content, "ChatConfigCheckButtonTemplate")
						allclasses:SetSize(20, 20)
						allclasses:SetPoint("TOPLEFT", 10, -10)
						allclasses:SetChecked(MAIGV( element.name .. "allclasses" ) )
						allclasses:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "allclasses", newval )

							if MAIUpdateStanceBarSize then
								MAIUpdateStanceBarSize()
							end
						end)
						allclasses.text = allclasses:CreateFontString(nil, "ARTWORK")
						allclasses.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						allclasses.text:SetPoint("LEFT", allclasses, "RIGHT", 0, 0)
						allclasses.text:SetText(MAIGT("allclasses"))

						local allclassesplus = CreateFrame("CheckButton", "allclassesplus", mover.tab9.content, "ChatConfigCheckButtonTemplate")
						allclassesplus:SetSize(20, 20)
						allclassesplus:SetPoint("TOPLEFT", 10, -40)
						allclassesplus:SetChecked(MAIGV( element.name .. "allclassesplus" ) )
						allclassesplus:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "allclassesplus", newval )

							if MAIUpdateStanceBarSize then
								MAIUpdateStanceBarSize()
							end
						end)
						allclassesplus.text = allclassesplus:CreateFontString(nil, "ARTWORK")
						allclassesplus.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						allclassesplus.text:SetPoint("LEFT", allclassesplus, "RIGHT", 0, 0)
						allclassesplus.text:SetText(MAIGT("allclassesplus"))
					end

					if element.name == "PlayerFrame" then
						-- TAB10 - PlayerFrame
						mover.tab10 = CreateFrame("Button", nil, mover.settings)
						mover.tab10:SetSize(100, 20)
						mover.tab10:SetPoint("TOPLEFT", 210, -20)
						mover.tab10.selected = true
						mover.tab10:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab10)
						end)
						tinsert(mover.settings.tabs, mover.tab10)

						mover.tab10.texture = mover.tab10:CreateTexture(nil, "Background")
						mover.tab10.texture:SetAllPoints(mover.tab10)
						mover.tab10.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab10.text = mover.tab10:CreateFontString(nil, "ARTWORK")
						mover.tab10.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab10.text:SetPoint("CENTER", mover.tab10, "CENTER", 0, 0)
						mover.tab10.text:SetText(MAIGT("playerframe"))



						-- tab10 - Content
						mover.tab10.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab10.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab10.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab10.content.texture = mover.tab10.content:CreateTexture(nil, "Background")
						mover.tab10.content.texture:SetAllPoints(mover.tab10.content)
						mover.tab10.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						if MAIGV( element.name .. "groupindicator" ) == nil then
							MAISV( element.name .. "groupindicator", true )
						end
						local groupindicator = CreateFrame("CheckButton", "groupindicator", mover.tab10.content, "ChatConfigCheckButtonTemplate")
						groupindicator:SetSize(20, 20)
						groupindicator:SetPoint("TOPLEFT", 10, -10)
						groupindicator:SetChecked(MAIGV( element.name .. "groupindicator" ) )
						groupindicator:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "groupindicator", newval )
						end)
						groupindicator.text = groupindicator:CreateFontString(nil, "ARTWORK")
						groupindicator.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						groupindicator.text:SetPoint("LEFT", groupindicator, "RIGHT", 0, 0)
						groupindicator.text:SetText(MAIGT("groupindicator"))


						if MAIGV( element.name .. "showtotemtimer" ) == nil then
							MAISV( element.name .. "showtotemtimer", false )
						end
						local showtotemtimer = CreateFrame("CheckButton", "showtotemtimer", mover.tab10.content, "ChatConfigCheckButtonTemplate")
						showtotemtimer:SetSize(20, 20)
						showtotemtimer:SetPoint("TOPLEFT", 10, -30)
						showtotemtimer:SetChecked(MAIGV( element.name .. "showtotemtimer" ) )
						showtotemtimer:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "showtotemtimer", newval )
						end)
						showtotemtimer.text = showtotemtimer:CreateFontString(nil, "ARTWORK")
						showtotemtimer.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						showtotemtimer.text:SetPoint("LEFT", showtotemtimer, "RIGHT", 0, 0)
						showtotemtimer.text:SetText(MAIGT("totemtimer"))
					end

					if element.name == "TargetFrame" then
						-- TAB11 - TargetFrame
						mover.tab11 = CreateFrame("Button", nil, mover.settings)
						mover.tab11:SetSize(100, 20)
						mover.tab11:SetPoint("TOPLEFT", 210, -20)
						mover.tab11.selected = true
						mover.tab11:SetScript("OnClick", function(self)
							mover.settings.SelectTab(mover.tab11)
						end)
						tinsert(mover.settings.tabs, mover.tab11)

						mover.tab11.texture = mover.tab11:CreateTexture(nil, "Background")
						mover.tab11.texture:SetAllPoints(mover.tab11)
						mover.tab11.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						mover.tab11.text = mover.tab11:CreateFontString(nil, "ARTWORK")
						mover.tab11.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						mover.tab11.text:SetPoint("CENTER", mover.tab11, "CENTER", 0, 0)
						mover.tab11.text:SetText(MAIGT("targetframe"))



						-- tab11 - Content
						mover.tab11.content = CreateFrame( "FRAME", nil, mover.settings)
						mover.tab11.content:SetSize(mover.settings:GetWidth(), mover.settings:GetHeight() - 20)
						mover.tab11.content:SetPoint("TOPLEFT", 0, -40)

						mover.tab11.content.texture = mover.tab11.content:CreateTexture(nil, "Background")
						mover.tab11.content.texture:SetAllPoints(mover.tab11.content)
						mover.tab11.content.texture:SetColorTexture(unpack(MAICOLORBACKGROUNDHEADER))

						if MAIGV( element.name .. "ilvl" ) == nil then
							MAISV( element.name .. "ilvl", true )
						end

						local ilvl = CreateFrame("CheckButton", "ilvl", mover.tab11.content, "ChatConfigCheckButtonTemplate")
						ilvl:SetSize(20, 20)
						ilvl:SetPoint("TOPLEFT", 10, -10)
						ilvl:SetChecked(MAIGV( element.name .. "ilvl" ) )
						ilvl:SetScript("OnClick", function(self)
							local newval = self:GetChecked()
							MAISV( element.name .. "ilvl", newval )
						end)
						ilvl.text = ilvl:CreateFontString(nil, "ARTWORK")
						ilvl.text:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")
						ilvl.text:SetPoint("LEFT", ilvl, "RIGHT", 0, 0)
						ilvl.text:SetText(MAIGT("ilvl"))
					end

					mover.settings.SelectTab(mover.tab1)



					mover.settings.visible = true
				elseif mover.settings.visible then
					mover.settings:Hide()
					mover.settings.visible = false
				else
					mover.settings:Show()
					mover.settings.visible = true
				end
			end)
			
			mover.settingsmove = CreateFrame("CheckButton", "pnlsettingsmove", mover, "UICheckButtonTemplate")
			mover.settingsmove:SetSize(20, 20)
			mover.settingsmove:SetPoint("BOTTOMLEFT", -3, -4)
			mover.settingsmove:SetChecked( MAIGV( element.name .. "move" ) )
			mover.settingsmove:SetScript("OnClick", function(self)
				local newval = self:GetChecked()
				MAISV( element.name .. "move", newval )
			end)

			-- Scale
			mover.settingsbtn:SetScale( 1 / MAIGV( element.name .. "scale" ) )
			mover.settingsmove:SetScale( 1 / MAIGV( element.name .. "scale" ) )
			mover.textcenter:SetScale( 1 / MAIGV( element.name .. "scale" ) )
			mover.textmove:SetScale( 1 / MAIGV( element.name .. "scale" ) )
			mover.text:SetScale( 1 / MAIGV( element.name .. "scale" ) )

			tinsert(MAITHINKER.tab, mover)
		end
	end
end

function MAIIgnoreBlizz(frame)
	if type(frame) == 'string' then
		--UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
		frame = _G[frame]
	end
	if type(frame) == 'table' and type(frame.IsObjectType) == 'function' and frame:IsObjectType('Frame') then
		local name = frame:GetName()
		if name then
			--UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil
		end
	end
end

local MAIGlowAlpha = 0.75

local LEFTSLOTS = { 2, 3, 4, 5, 6, 10, 16, 20, 18 }
local RIGHTSLOTS = { 7, 8, 9, 11, 12, 13, 14, 15, 17 }
local slotbry = 0
local slotbrx = 3
function MAIAddIlvl(SLOT, i)
	if SLOT and SLOT.info == nil then
		local name = ""
		if SLOT.GetName then
			name = SLOT:GetName() .. "."
		end

		SLOT.info = CreateFrame( "FRAME", name .. "info", SLOT )
		SLOT.info:SetSize( SLOT:GetSize() )
		SLOT.info:SetPoint( "CENTER", SLOT, "CENTER", 0, 0 )
		SLOT.info:SetFrameLevel( 50 )
		SLOT.info:SetScript( "OnUpdate", function( self, elapsed ) 
			if MouseIsOver( SLOT ) then
				SLOT.text:SetAlpha( 0 )
				SLOT.texth:SetAlpha( 0 )
			else
				SLOT.text:SetAlpha( 1 )
				SLOT.texth:SetAlpha( 1 )
			end
		end )

		--[[
		SLOT.info.texture = SLOT:CreateTexture( nil, "BACKGROUND" )
		SLOT.info.texture:SetAllPoints( SLOT.info )
		SLOT.info.texture:SetVertexColor( 0.75, 0.75, 0.75, 0.5 )
		]]

		SLOT.text = SLOT.info:CreateFontString(nil, "OVERLAY")
		SLOT.text:SetFont(STANDARD_TEXT_FONT, 11, "THINOUTLINE")
		SLOT.text:SetShadowOffset(1, -1)

		SLOT.texth = SLOT.info:CreateFontString(nil, "OVERLAY")
		SLOT.texth:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
		SLOT.texth:SetShadowOffset(1, -1)

		SLOT.border = SLOT.info:CreateTexture(nil, "OVERLAY", SLOT.info)
		SLOT.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
		SLOT.border:SetBlendMode("ADD")
		SLOT.border:SetAlpha(MAIGlowAlpha)

		SLOT.text:SetPoint( "TOP", SLOT.info, "TOP", 0, -slotbry )
		SLOT.texth:SetPoint( "BOTTOM", SLOT.info, "BOTTOM", 0, slotbry )

		local NormalTexture = _G[SLOT:GetName() .. "NormalTexture"]
		if NormalTexture then
			local sw, sh = NormalTexture:GetSize()
			SLOT.border:SetWidth(sw)
			SLOT.border:SetHeight(sh)
		end

		SLOT.border:SetPoint("CENTER")
	end
end

function MAISkinFrame( frameName, ids, retry, show )
	if not MAIGV( "FrameColorEnabled", true ) then
		return
	end

	if show then
		MAIMSG( "|cFFFFFF00" .. "----------------------------" )
		MAIMSG( "|cFFFFFF00" .. "MAI DEBUG: " .. frameName )
	end

	local frames = { string.split( ".", frameName ) }
	local frame = _G
	for i, v in pairs( frames ) do
		if frame[v] then
			frame = frame[v]
		end
	end
	if frame ~= _G then
		if frame.GetRegions then
			-- if it is a frame and has some textures
			local textures = { frame:GetRegions() }
			if ids then
				for i, texture in pairs( textures ) do
					if show then
						if texture.GetTexture then
							MAIMSG("DEBUG: |cFFFFFF00" .. tostring( frameName ) .. " " .. tostring( i ) .. " " .. tostring( texture ) .. " " .. tostring( texture:GetTexture() ) )
						end
					end
					if tContains( ids, i ) then
						texture:SetVertexColor(MAIGetFrameColor())
						MAIRegisterFrameColor(texture)
					end
				end
			else
				--MAIMSG( "Missing [ids]: " .. tostring( frameName ) )
			end
		else
			-- is only a texture
			frame:SetVertexColor(MAIGetFrameColor())
			MAIRegisterFrameColor(frame)
		end
	else
		if retry then
			C_Timer.After( 0.1, function()
				MAISkinFrame( frameName, ids, retry, show )
			end )
		end
	end
end

local MAICharSlots = {
	"AmmoSlot", -- 0,
	"HeadSlot", -- 1
	"NeckSlot", -- 2
	"ShoulderSlot", -- 3
	"ShirtSlot", -- 4
	"ChestSlot", -- 5
	"WaistSlot", -- 6
	"LegsSlot", -- 7
	"FeetSlot", -- 8
	"WristSlot", -- 9
	"HandsSlot", -- 10
	"Finger0Slot", -- 11
	"Finger1Slot", -- 12
	"Trinket0Slot", -- 13
	"Trinket1Slot", -- 14
	"BackSlot", -- 15
	"MainHandSlot", -- 16
	"SecondaryHandSlot", -- 17
	"RangedSlot", -- 18
	"TabardSlot", -- 19
	--"Bag0Slot",
	--"Bag1Slot",
	--"Bag2Slot",
	--"Bag3Slot"
}

local MAIClassIDs = {2, 3, 4, 6, 8}
local MAISubClassIDs15 = {5, 6} -- 15

function MAISetup()
	MAIUpdateChatChannels()

	if MAIBUILD ~= "RETAIL" then
		-- Bag Searchbar
		BagItemSearchBox = CreateFrame("EditBox", "BagItemSearchBox", ContainerFrame1, "BagSearchBoxTemplate")
		BagItemSearchBox:SetSize(110, 18)
		BagItemSearchBox:SetPoint("TOPLEFT", ContainerFrame1, "TOPLEFT", 50, -30)
		
		-- Bag SortButton
		BagItemAutoSortButton = CreateFrame("Button", "BagItemAutoSortButton", ContainerFrame1)
		BagItemAutoSortButton:SetSize(16, 16)
		BagItemAutoSortButton:SetPoint("TOPLEFT", ContainerFrame1, "TOPLEFT", 164, -30)
		--[[
		BagItemAutoSortButton:SetNormalTexture("bags-button-autosort-up")
		BagItemAutoSortButton:SetPushedTexture("bags-button-autosort-down")
		BagItemAutoSortButton:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
		]]
		BagItemAutoSortButton:SetScript("OnClick", function(self, ...)
			PlaySound(SOUNDKIT.UI_BAG_SORTING_01);
			if SortBags then
				SortBags();
			end
		end)
		BagItemAutoSortButton:SetScript("OnEnter", function(self, ...)
			GameTooltip:SetOwner(self);
			GameTooltip:SetText(BAG_CLEANUP_BAGS);
			GameTooltip:Show();
		end)
		BagItemAutoSortButton:SetScript("OnLeave", function(self, ...)
			GameTooltip_Hide()
		end)
		
	end
	
	if MAICreateMinimapButtonsFrame then
		MAICreateMinimapButtonsFrame()
	end

	MAIGetElementList()

	for i, v in pairs(ELEMENTS) do
		LANG_MAI[v.name] = MAIGT(v.lstr)
	end
	LANG_MAI["Advanced"] = ADVANCED_LABEL
	LANG_MAI["ActionBars"] = MAIGT("actionbars")
	LANG_MAI["UnitFrames"] = UNITFRAME_LABEL
	LANG_MAI["GV"] = REWARDS
	
	MAIUpdateActionButton()

	MAIEVENT = "PLAYER_ENTERING_WORLD"
	MAISetupMAIMENU()
	for i, v in pairs(ELEMENTS) do
		MAIElementSetup(v)
	end
	MAIEVENT = nil


	if MAIGV( "menu" ) == nil then
		MAISV( "menu", true )
	end
	if MAIGV( "menu" ) then
		OLDMAITAB = MAICopy_Table( MAITAB["PROFILES"][MAIGCP()] )

		if MAIGV( "toggler" ) then
			MAIMENUMOVING:Show()
			MAIMENU:Hide()
		else
			MAIMENUMOVING:Hide()
			MAIMENU:Show()
		end
	else
		MAIMENU:Hide()
		MAIMENUMOVING:Hide()
	end

	if MAIMENU and MAIMENU.TOGGLE then
		if MAIGV( "toggler" ) then
			MAIMENU.TOGGLE:SetText(MAIGT("lock"))
			MAIMENUMOVING.TOGGLE:SetText(MAIGT("lock"))
		else
			MAIMENU.TOGGLE:SetText(MAIGT("unlock"))
			MAIMENUMOVING.TOGGLE:SetText(MAIGT("unlock"))
		end
	end

	if MAIStatusBar and not MAIGV( "MAIStatusBar" .. "Enabled" ) then
		MAIStatusBar:Hide()
	end
	--MAIMSG("Setup done (Always use the latest version)")

	if MAIGV( "showextras" ) then
		PlayerSpeed = CreateFrame( "FRAME", "PlayerSpeed", UIParent)
		PlayerSpeed:SetSize(100, 20)
		PlayerSpeed:SetPoint("TOP", UIParent, "TOP", 0, -30)

		PlayerSpeed.text = PlayerSpeed:CreateFontString(nil, "ARTWORK")
		PlayerSpeed.text:SetPoint("CENTER", PlayerSpeed, "CENTER", 0, 0)
		PlayerSpeed.text:SetFont(STANDARD_TEXT_FONT, 10, "")
		PlayerSpeed.text:SetShadowOffset(1, -1)
		PlayerSpeed.text:SetText("")
		PlayerSpeed.text:SetTextColor(0.1, 1.0, 0.1)

		function PlayerSpeed.Think()
			if MAIMathC then
				local speed = GetUnitSpeed("PLAYER") / 7 * 100
				local text = ""
				if speed > 0 then
					text = string.format("+%d", MAIMathC(speed, 0, 9000)) .. "%"
					if speed >= 100 then
						PlayerSpeed.text:SetTextColor(0.1, 1.0, 0.1)
					else
						PlayerSpeed.text:SetTextColor(1.0, 1.0, 0.1)
					end
				elseif speed < 0 then
					text = string.format("-%d", MAIMathC(speed, 0, 9000)) .. "%"
					PlayerSpeed.text:SetTextColor(1.0, 0.1, 0.1)
				end
				PlayerSpeed.text:SetText(text)
			end
			C_Timer.After(0.5, PlayerSpeed.Think)
		end
		PlayerSpeed.Think()
	end

	MAITHINKER.update = true

	if not MAIGV( "nochanges" ) then
		MAIMoveFrames()
	end

	if PaperDollFrame and not MAIGV( "nochanges" ) then
		PDThink = CreateFrame("FRAME")

		if MAIGV( "PaperDollFrame" .. "showilvl" ) == nil then
			MAISV( "PaperDollFrame" .. "showilvl", true )
		end

		PaperDollFrame.ilvl = PaperDollFrame:CreateFontString(nil, "ARTWORK")
		PaperDollFrame.ilvl:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
		PaperDollFrame.ilvl:SetPoint("TOPLEFT", CharacterWristSlot, "BOTTOMLEFT", 24, -15)
		PaperDollFrame.ilvl:SetText(ITEM_LEVEL_ABBR .. ": ?")

		for i, slot in pairs(MAICharSlots) do
			MAIAddIlvl( _G["Character" .. slot], i )
		end

		function PDThink.UpdateItemInfos()
			local count = 0
			local sum = 0
			for i, slot in pairs(MAICharSlots) do
				local id = i
				i = i - 1
				local SLOT = _G["Character" .. slot]
				if SLOT and SLOT.text ~= nil and GetInventoryItemLink and SLOT.GetID and SLOT:GetID() then
					local ItemID = GetInventoryItemLink("PLAYER", SLOT:GetID()) or GetInventoryItemID("PLAYER", SLOT:GetID())
					if ItemID ~= nil and GetDetailedItemLevelInfo then
						local t1, t2, rarity, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13 = GetItemInfo(ItemID)
						local ilvl, _, baseilvl = GetDetailedItemLevelInfo(ItemID)
						local color = ITEM_QUALITY_COLORS[rarity]
						local current, maximum = GetInventoryItemDurability(i);
						if current and maximum then
							local per = current / maximum
							if current == maximum then -- 100%
								SLOT.texth:SetTextColor(0,	1,		0,	1)
							elseif per == 0.0 then -- = 0%, black
								SLOT.texth:SetTextColor(0,	0,		0,	1)
							elseif per < 0.1 then -- < 10%, red
								SLOT.texth:SetTextColor(1,	0,		0,	1)
							elseif per < 0.3 then -- < 30%, orange
								SLOT.texth:SetTextColor(1,	0.65,	0,	1)
							elseif per < 1 then -- < 100%, red
								SLOT.texth:SetTextColor(1,	1,		0,	1)
							end
							if current ~= maximum then
								SLOT.texth:SetText(string.format("%0.0f", current / maximum * 100) .. "%")
							else
								SLOT.texth:SetText("")
							end
						else
							SLOT.texth:SetText("")
						end
						if ilvl and color then
							if slot == "AmmoSlot" then
								local COUNT = _G["Character" .. slot .. "Count"]
								if COUNT.hooked == nil then
									COUNT.hooked = true
									COUNT:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
									SLOT.maxDisplayCount = 999999
									COUNT:SetText(COUNT:GetText())
								end
							end
							if i ~= 4 and i ~= 19 and i ~= 20 then -- ignore: shirt, tabard, ammo
								count = count + 1
								sum = sum + ilvl
							end
							if MAIGV( "PaperDollFrame" .. "showilvl" ) and not MAIGV( "nochanges" ) then
								SLOT.text:SetText(color.hex .. ilvl)
								local alpha = MAIGlowAlpha
								if color.r == 1 and color.g == 1 and color.b == 1 then
									alpha = alpha - 0.2
								end
								SLOT.border:SetVertexColor(color.r, color.g, color.b, alpha)
								--SLOT.info:Show()
							else
								SLOT.text:SetText("")
								SLOT.texth:SetText("")
								SLOT.border:SetVertexColor(1, 1, 1, 0)
								--SLOT.info:Hide()
							end
						else
							SLOT.text:SetText("")
							SLOT.texth:SetText("")
							SLOT.border:SetVertexColor(1, 1, 1, 0)
							--SLOT.info:Hide()
						end
					else
						SLOT.text:SetText("")
						SLOT.texth:SetText("")
						SLOT.border:SetVertexColor(1, 1, 1, 0)
						--SLOT.info:Hide()
					end
				end
			end
			if count > 0 then
				local max = 16 -- when only mainhand
				if GetInventoryItemID("PLAYER", 17) then
					local t1, t2, rarity, ilvl, t5, t6, t7, t8, t9, t10, t11, t12, t13 = GetItemInfo(GetInventoryItemLink("PLAYER", 17))
					if t1 then -- when 2x 1handed
						max = 17
					end
				end
				if MAIBUILD == "RETAIL" then
					max = max - 1
				end
				MAIILVL = string.format("%0.2f", sum / max)
				if MAIGV( "PaperDollFrame" .. "showilvl" ) and not MAIGV( "nochanges" ) then
					PaperDollFrame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": |r" .. MAIILVL)
				else
					PaperDollFrame.ilvl:SetText("")
				end
			else
				PaperDollFrame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": " .. "|cFFFF0000?")
			end
		end

		function PDThink.Loop()
			PDThink.UpdateItemInfos()
			C_Timer.After(1, PDThink.Loop)
		end
		C_Timer.After(1, PDThink.Loop)

		PDThink:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		PDThink:SetScript("OnEvent", function(self, event, slotid, ...)
			PDThink.UpdateItemInfos()
		end)

		PaperDollFrame.btn = CreateFrame("CheckButton", "PaperDollFrame" .. "btn", PaperDollFrame, "UICheckButtonTemplate")
		PaperDollFrame.btn:SetSize(20, 20)
		PaperDollFrame.btn:SetPoint("TOPLEFT", CharacterWristSlot, "BOTTOMLEFT", 6, -10)
		PaperDollFrame.btn:SetChecked(MAIGV( "PaperDollFrame" .. "showilvl" ) )
		PaperDollFrame.btn:SetScript("OnClick", function(self)
			local newval = self:GetChecked()
			MAISV( "PaperDollFrame" .. "showilvl", newval )
			PDThink.UpdateItemInfos()
			if IFThink and IFThink.UpdateItemInfos then
				IFThink.UpdateItemInfos()
			end
			ContainerFrame_UpdateAll()
		end)

		-- Inspect
		function MAIWaitForInspectFrame()
			if InspectPaperDollFrame then
				IFThink = CreateFrame("FRAME")

				InspectPaperDollFrame.ilvl = InspectPaperDollFrame:CreateFontString(nil, "ARTWORK")
				InspectPaperDollFrame.ilvl:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
				InspectPaperDollFrame.ilvl:SetPoint("TOPLEFT", InspectWristSlot, "BOTTOMLEFT", 24, -15)
				InspectPaperDollFrame.ilvl:SetText(ITEM_LEVEL_ABBR .. ": ?")

				for i, slot in pairs(MAICharSlots) do
					MAIAddIlvl(_G["Inspect" .. slot], i )
				end

				function IFThink.UpdateItemInfos()
					local count = 0
					local sum = 0
					for i, slot in pairs(MAICharSlots) do
						local SLOT = _G["Inspect" .. slot]
						if SLOT and SLOT.text ~= nil and GetInventoryItemLink then
							local ItemID = GetInventoryItemLink("TARGET", SLOT:GetID()) --GetInventoryItemID("PLAYER", SLOT:GetID())
							if ItemID and GetDetailedItemLevelInfo then
								local t1, t2, rarity, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13 = GetItemInfo(ItemID)
								local ilvl, _, baseilvl = GetDetailedItemLevelInfo(ItemID)
								local color = ITEM_QUALITY_COLORS[rarity]
								if ilvl and color then
									if i ~= 4 and i ~= 19 and i ~= 20 then -- ignore: shirt, tabard, ammo
										count = count + 1
										sum = sum + ilvl
									end
									if MAIGV( "PaperDollFrame" .. "showilvl" ) and not MAIGV( "nochanges" ) then
										SLOT.text:SetText(color.hex .. ilvl)
										local alpha = MAIGlowAlpha
										if color.r == 1 and color.g == 1 and color.b == 1 then
											alpha = alpha - 0.2
										end
										SLOT.border:SetVertexColor(color.r, color.g, color.b, alpha)
										--SLOT.info:Show()
									else
										SLOT.text:SetText("")
										SLOT.border:SetVertexColor(1, 1, 1, 0)
										--SLOT.info:Hide()
									end
								else
									SLOT.text:SetText("")
									SLOT.border:SetVertexColor(1, 1, 1, 0)
									--SLOT.info:Hide()
								end
							else
								SLOT.text:SetText("")
								SLOT.border:SetVertexColor(1, 1, 1, 0)
								--SLOT.info:Hide()
							end
						end
					end
					if count > 0 then
						local max = 16 -- when only mainhand
						local ItemID = GetInventoryItemLink("TARGET", 17)
						if GetItemInfo and GetInventoryItemID and ItemID ~= nil then
							local t1, t2, rarity, ilvl, t5, t6, t7, t8, t9, t10, t11, t12, t13 = GetItemInfo(ItemID)
							if t1 then -- when 2x 1handed
								max = 17
							end
						end
						if MAIBUILD == "RETAIL" then
							max = max - 1
						end
						MAIILVLINSPECT = string.format("%0.2f", sum / max)
						if MAIGV( "PaperDollFrame" .. "showilvl" ) and not MAIGV( "nochanges" ) then
							InspectPaperDollFrame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": |r" .. MAIILVLINSPECT)
						else
							InspectPaperDollFrame.ilvl:SetText("")
						end
					else
						InspectPaperDollFrame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": " .. "|cFFFF0000?")
					end
				end
				C_Timer.After(0.5, IFThink.UpdateItemInfos)
		
				IFThink:RegisterEvent("INSPECT_READY")
				IFThink:SetScript("OnEvent", function(self, event, slotid, ...)
					C_Timer.After(0.1, IFThink.UpdateItemInfos)
				end)
			else
				C_Timer.After(0.1, MAIWaitForInspectFrame)
			end
		end
		MAIWaitForInspectFrame()
		

		
		-- BAGS
		hooksecurefunc("ContainerFrame_Update", function(self)
			local id = self:GetID()
			local name = self:GetName()
			local size = self.size

			for i=1, size do
				local bid = size - i + 1
				local SLOT = _G[name .. 'Item' .. bid]
				local slotLink = GetContainerItemLink(id, i)
				MAIAddIlvl(SLOT, i)

				if slotLink and GetDetailedItemLevelInfo then
					local t1, t2, rarity, t4, t5, t6, t7, t8, t9, t10, t11, classID, subclassID = GetItemInfo(slotLink)
					local ilvl, _, baseilvl = GetDetailedItemLevelInfo(slotLink)
					local color = ITEM_QUALITY_COLORS[rarity]
					if ilvl and color then
						if MAIGV( "PaperDollFrame" .. "showilvl" ) and not MAIGV( "nochanges" ) then
							if tContains(MAIClassIDs, classID) or (classID == 15 and tContains(MAISubClassIDs15, subclassID)) then
								SLOT.text:SetText(color.hex .. ilvl)
							else
								SLOT.text:SetText("")
							end
							local alpha = MAIGlowAlpha
							if color.r == 1 and color.g == 1 and color.b == 1 then
								alpha = alpha - 0.2
							end
							SLOT.border:SetVertexColor(color.r, color.g, color.b, alpha)
							--SLOT.info:Show()
						else
							SLOT.text:SetText("")
							SLOT.border:SetVertexColor(1, 1, 1, 0)
							--SLOT.info:Hide()
						end
					else
						SLOT.text:SetText("")
						SLOT.border:SetVertexColor(1, 1, 1, 0)
						--SLOT.info:Hide()
					end
				else
					SLOT.text:SetText("")
					SLOT.border:SetVertexColor(1, 1, 1, 0)
					--SLOT.info:Hide()
				end
			end
		end)
	end

	MAISetupSortSearchResult()

	if MAIGV( "StanceBar" .. "allclasses" ) == nil then
		MAISV( "StanceBar" .. "allclasses", true )
	end
	if MAIGV( "StanceBar" .. "allclassesplus" ) == nil then
		MAISV( "StanceBar" .. "allclassesplus", false )
	end

	local dragframe = nil
	local dragspellid1 = 0
	local dragspellid2 = 0

	local stanceid = 1
	function MAIAddStanceButton(spell1, spell2, hr, allclassesplus, nl)
		local spellid1 = spell1.spellid
		local art1 = spell1.art
		local db = spell1.db

		local spellid2 = spell2.spellid or spell1.spellid
		local art2 = spell2.art or spell1.art

		if spellid1 == nil and art1 == nil then
			MAINL = MAINL + 1
		else
			if spellid1 == 687 then -- WARLOCK ARMOR
				if MAIIsSpellKnown(706, "MAIAddStanceButton WARLOCK") then
					spellid1 = 706 -- UPGRADE ARMOR
				end
			end
			if spellid1 == 168 then -- MAGE ARMOR
				if MAIIsSpellKnown(7302, "MAIAddStanceButton MAGE") then
					spellid1 = 7302 -- UPGRADE ARMOR
				end
			end

			if MAIGV( "StanceBar" .. "Enabled" ) and MAIGV( "StanceBar" .. "allclasses" ) then
				local spellname1, _, texture1 = GetSpellInfo(spellid1)
				local spellname2, _, texture2 = GetSpellInfo(spellid2)
				
				local b = CreateFrame("CheckButton", "MAIStanceButton" .. stanceid, MAIStanceBar, "SecureActionButtonTemplate") --"SecureActionButtonTemplate")--"ActionBarButtonTemplate")
				b.spellid1 = spellid1
				b.spellid2 = spellid2
				b.art1 = art1
				b.art2 = art2
				b.db = db
				b.hr = hr
				b.nl = nl
				b.allclassesplus = allclassesplus or false
				b:SetWidth(30)
				b:SetHeight(30)

				b:SetAttribute("*type1", "spell")
				b:SetAttribute("spell1", spellname1)
				b:SetAttribute("*type2", "spell")
				b:SetAttribute("spell2", spellname2)

				b:RegisterForClicks("AnyUp")

				function b:SetSpell(sid1, sid2)
					local name1, _, texture1 = GetSpellInfo(sid1)
					local name2, _, texture2 = GetSpellInfo(sid2)
					b.Icon:SetTexture(texture1)
					b.spellid1 = sid1
					b.spellid2 = sid2

					b:SetAttribute("spell1", name1)
					b:SetAttribute("spell2", name2)
					
					local sbsid1 = 0
					local i = 1
					while true do
						local spellName, _, spellID = GetSpellBookItemName(i, BOOKTYPE_SPELL)
						if spellName and spellName == name1 and spellID and MAIIsSpellKnown( spellID, "SetSpell #1" ) then --strfind(spellName, spellname) then
							sbsid1 = spellID
						elseif (not spellName) then
							break
						end
						i = i + 1
					end
					b.sbsid1 = sbsid1

					local sbsid2 = 0
					i = 1
					while true do
						local spellName, _, spellID = GetSpellBookItemName(i, BOOKTYPE_SPELL)
						if spellName and spellName == name2 and spellID and MAIIsSpellKnown( spellID, "SetSpell #2" ) then --strfind(spellName, spellname) then
							sbsid2 = spellID
						elseif (not spellName) then
							break
						end
						i = i + 1
					end
					b.sbsid2 = sbsid2

					b.db[1] = sid1
					b.db[2] = sid2
				end

				b:RegisterForDrag("LeftButton")
				b:SetScript("OnDragStart", function(self, ...)
					if ( LOCK_ACTIONBAR ~= "1" or IsModifiedClick("PICKUPACTION") ) then
						dragspellid1 = self.spellid1
						dragspellid2 = self.spellid2
						dragframe = self
						PickupSpell(self.spellid1)
						self.Icon:SetTexture(nil)
					end
				end)
				b:SetScript("OnReceiveDrag", function(self, ...)
					if self ~= dragframe and dragspellid1 and dragframe and self.art == dragframe.art then
						-- change drag
						dragframe:SetSpell(self.spellid1, self.spellid2)

						-- change target
						self:SetSpell(dragspellid1, dragspellid2)

						dragframe = nil
						dragspellid1 = nil
						dragspellid2 = nil

						-- reset mouse
						ClearCursor()
					elseif dragframe then
						if self.art then
							print("|cFFFF0000" .. "WRONG SLOT (", self.art , ")")
						end
						dragframe:SetSpell(dragspellid1, dragspellid2)

						dragframe = nil
						dragspellid1 = nil
						dragspellid2 = nil
					end
				end)
				b:HookScript("OnUpdate", function(self)
					if IsMouseButtonDown("RightButton") or IsMouseButtonDown("LeftButton") then
						if dragframe == self then
							C_Timer.After(0.01, function()
								if dragframe == self and not GetCursorInfo() then
									dragframe:SetSpell(dragspellid1, dragspellid2)

									dragframe = nil
									dragspellid1 = nil
									dragspellid2 = nil
								end
							end)
						end
					end
				end)

				b.Icon = b:CreateTexture(nil, "BACKGROUND")
				--b.Icon:SetDrawLayer("BACKGROUND", 7)
				b.Icon:SetSize(30, 30)
				b.Icon:SetPoint("CENTER", 0, 0)
				b.Icon:SetTexture(texture)
				local br = 0.056
				b.Icon:SetTexCoord(br, 1 - br, br, 1 - br)

				b.InnerGlow = b:CreateTexture(nil, "ARTWORK")
				--b.InnerGlow:SetDrawLayer("ARTWORK", 6)
				b.InnerGlow:SetSize(36, 36)
				b.InnerGlow:SetPoint("CENTER", -0.5, 0)
				b.InnerGlow:SetAtlas( "bags-newitem", false )--"Interface/SpellActivationOverlay/IconAlert")
				b.InnerGlow:SetBlendMode("ADD")
				b.InnerGlow:SetAlpha(0.0)

				b.cooldown = CreateFrame("Cooldown", "MAIStanceButton" .. stanceid .. "Cooldown", b, "CooldownFrameTemplate")
				b.cooldown:SetSize(18, 18)
				b.cooldown:SetAllPoints(b)
				b.cooldown:SetHideCountdownNumbers(false)
				b.cooldown:SetReverse(true)

				b.NormalTexture2 = b:CreateTexture(nil, "ARTWORK")
				--b.NormalTexture2:SetDrawLayer("ARTWORK", 7)
				b.NormalTexture2:SetSize(54, 54)
				b.NormalTexture2:SetPoint("CENTER", 0, 0)
				b.NormalTexture2:SetTexture("Interface/Buttons/UI-Quickslot2")
				MAIRegisterUIColor(b.NormalTexture2)

				b.text = b:CreateFontString(nil, "ARTWORK")
				b.text:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
				b.text:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
				b.text:SetText("")

				b.spellstate = false

				function b:MAIThink()
					if MAIIsSpellKnown(spellid1, "MAIThink") and MAIGV( "StanceBar" .. "allclasses" ) and (not b.allclassesplus or (b.allclassesplus and MAIGV( "StanceBar" .. "allclassesplus" ) )) then
 						local spellname1, _, texture1 = GetSpellInfo(b.spellid1)
						local spellname2, _, texture2 = GetSpellInfo(b.spellid2)
						local start, dura = b.start, b.dura

						local sbsid1 = 0
						local sbsid2 = 0

						local i = 1
						while true do
							local spellName, test, spellID = GetSpellBookItemName(i, BOOKTYPE_SPELL)
							if spellName and spellName == spellname1 and spellID and MAIIsSpellKnown( spellID, "SetSpell #3" ) then --strfind(spellName, spellname) then
								sbsid1 = spellID
							elseif (not spellName) then
								break
							end
							i = i + 1
						end
						b.sbsid1 = sbsid1

						if spellname2 then
							i = 1
							while true do
								local spellName, test, spellID = GetSpellBookItemName(i, BOOKTYPE_SPELL)
								if spellName and spellName == spellname2 and spellID and MAIIsSpellKnown( spellID, "SetSpell #4" ) then --strfind(spellName, spellname) then
									sbsid2 = spellID
								elseif (not spellName) then
									break
								end
								i = i + 1
							end
							b.sbsid2 = sbsid2
						end

						spellname1, _, texture1 = GetSpellInfo(b.sbsid1)
						spellname2, _, texture2 = GetSpellInfo(b.sbsid2)
						
						local hasbuff = false
						for i = 1, 40 do
							local name, t2, t3, t4, duration, expirationTime, t7, t8, t9, spe = UnitBuff("PLAYER", i)
							if name ~= nil and name == spellname2 and sbsid2 == spe then
								hasbuff = 1
								start = expirationTime - duration
								dura = duration
								b.Icon:SetTexture(texture2)
								break
							elseif name == nil then
								break
							end
						end
						if not hasbuff then
							for i = 1, 40 do
								local name, t2, t3, t4, duration, expirationTime, t7, t8, t9, spe = UnitBuff("PLAYER", i)
								if name ~= nil and name == spellname1 and sbsid1 == spe then
									hasbuff = 1
									start = expirationTime - duration
									dura = duration
									b.Icon:SetTexture(texture1)
									break
								elseif name == nil then
									break
								end
							end
						end
						if not hasbuff then
							b.Icon:SetTexture(texture1)
						end

						if spellname1 and UnitExists("PET") and UnitCreatureFamily("PET") then
							if string.find(spellname1, UnitCreatureFamily("PET")) then
								hasbuff = 1
							end
						end

						for i = 1, 4 do
							local haveTotem, totemName, startTime, duration = GetTotemInfo(i)
							if haveTotem and totemName and spellname1 and string.find(totemName, spellname1) then
								start = startTime
								dura = duration
								hasbuff = 2
								break
							end
						end

						if MAIBUILD ~= "RETAIL" then
							if b.soulstone and GetItemCount(6265) then -- soulstone
								b.text:SetText(GetItemCount(6265))
							elseif b.hellstone then
								b.text:SetText(GetItemCount(5565))
							end
						end

						if start and dura then
							b.cooldown:SetReverse(true)
							CooldownFrame_Set(b.cooldown, start, dura, true )
						else
							start, dura = GetSpellCooldown(b.sbsid1)
							if start then
								b.cooldown:SetReverse(false)
								CooldownFrame_Set(b.cooldown, start, dura, true )
							else
								CooldownFrame_Clear(b.cooldown)
							end
						end
						
						local isUsable, notEnoughMana = IsUsableSpell(b.sbsid1)
						if ( isUsable ) then
							b.Icon:SetVertexColor(1.0, 1.0, 1.0);
						elseif ( notEnoughMana ) then
							b.Icon:SetVertexColor(0.5, 0.5, 1.0);
						else
							b.Icon:SetVertexColor(0.4, 0.4, 0.4);
						end

						if b.InnerGlow then
							if hasbuff == 2 then
								b.InnerGlow:SetAlpha(1.0)
							elseif hasbuff == 1 then
								b.InnerGlow:SetAlpha(1.0)
								--b.Icon:SetTexture(136116)
							else
								b.InnerGlow:SetAlpha(0.0)
							end
						end
						if not InCombatLockdown() then
							b:Show()
						end
					else
						if not InCombatLockdown() then
							b:Hide()
						end
					end

					if b.spellstate ~= MAIIsSpellKnown(spellid1, "spellstate 2.1") then
						b.spellstate = MAIIsSpellKnown(spellid1, "spellstate 2.2")
						MAIUpdateStanceBarSize()
					end

					C_Timer.After(0.1, b.MAIThink)
				end
				b:MAIThink()

				b:SetScript("OnEnter", function(self, ...)
					local spellname1, _, texture1 = GetSpellInfo(b.spellid1)
					GameTooltip:SetOwner(self, "ANCHOR_TOP")
					local spellbookid = 0
					local i = 1
					while true do
						local spell, spellSub, spellid = GetSpellBookItemName(i, BOOKTYPE_SPELL)
						if spellid and spellid == b.spellid1 then
							spellbookid = i
						elseif (not spell) then
							break
						end
						i = i + 1
					end
					if MAIIsSpellKnown(spellid1, "OnEnter") and spellbookid > 0 then
						GameTooltip:SetSpellBookItem(spellbookid, BOOKTYPE_SPELL);
						GameTooltip:Show()
					end
				end)
				b:SetScript("OnLeave", function(self, ...)
					GameTooltip:Hide()
				end)

				stanceid = stanceid + 1

				return b
			end
			return nil
		end
	end
	local localizedClass, englishClass, classIndex = UnitClass("PLAYER")
	if MAIGV( "CLASSES" ) == nil then
		MAISV( "CLASSES", {} )
	else
		for classname, classtab in pairs( MAIGV( "CLASSES" ) ) do
			if type( classtab ) == "table" then
				for index, classdb in pairs( classtab ) do
					for id, spelltab in pairs( classdb ) do
						if spelltab[1] == nil then
							if spelltab[2] and spelltab[2] ~= "fake" then
								print("[MAI] |cFFFF0000" .. classname .. "-DB is broken, resetting it.")
								MAIGV( "CLASSES" )[classname] = {} 
								MAIGV( "CLASSES" )[classname .. "VERSION"] = 0
							end
						end
					end
				end
			end
		end
	end
	if englishClass == "MAGE" then
		if MAIGV( "CLASSES" )["MAGE"] == nil then
			MAIGV( "CLASSES" )["MAGE"] = {}
		end
		MAIGV( "CLASSES" )["MAGEVERSION"] = MAIGV( "CLASSES" )["MAGEVERSION"] or 0
		if MAIGV( "CLASSES" )["MAGEVERSION"] ~= 6 then
			MAIGV( "CLASSES" )["MAGEVERSION"] = 6

			MAIGV( "CLASSES" )["MAGE"][1] = {}
			MAIGV( "CLASSES" )["MAGE"][1][1] = {1459, "buff", nil, 23028, "buffbetter", nil} -- Arkane Intelligenz, Brillanz
			MAIGV( "CLASSES" )["MAGE"][1][2] = {168, "buff"} -- Frostrüstung
			MAIGV( "CLASSES" )["MAGE"][1][3] = {6117, "buff"} -- Mage Armor, Magische Rüstung

			MAIGV( "CLASSES" )["MAGE"][2] = {}
			MAIGV( "CLASSES" )["MAGE"][2][1] = {604, "buffshort"} -- Magie dämpfen
			MAIGV( "CLASSES" )["MAGE"][2][2] = {1008, "buffshort"} -- Magie verstärken

			MAIGV( "CLASSES" )["MAGE"][3] = {}
			MAIGV( "CLASSES" )["MAGE"][3][1] = {5504, "food"} -- Trinken herstellen
			MAIGV( "CLASSES" )["MAGE"][3][2] = {587, "food"} -- Essen herstellen
			MAIGV( "CLASSES" )["MAGE"][3][3] = {43987, "food"} -- Tischlein deck dich
			--MAIGV( "CLASSES" )["MAGE"][3][4] = {759, "food"} -- Manaachat herstellen -- BROKEN, not same names
			
			MAIGV( "CLASSES" )["MAGE"][4] = {}
			MAIGV( "CLASSES" )["MAGE"][4][1] = {543, "buffempower", true} -- Feuerzauberschutz
			MAIGV( "CLASSES" )["MAGE"][4][2] = {6143, "buffempower", true} -- Frostzauberschutz

			MAIGV( "CLASSES" )["MAGE"][5] = {}
			MAIGV( "CLASSES" )["MAGE"][5][1] = {1463, "shield", true} -- Manaschild
			MAIGV( "CLASSES" )["MAGE"][5][2] = {11426, "shield", true} -- Eisbarriere
			MAIGV( "CLASSES" )["MAGE"][5][3] = {30482, "shield", true} -- Glühende Rüstung
		end

		local oldi = 0
		for i, v in pairs( MAIGV( "CLASSES" )["MAGE"] ) do
			local hr = false
			for x, tab in pairs(v) do
				hr = false
				if i ~= oldi and MAIIsSpellKnown(tab[1], "MAGE") then
					oldi = i
					hr = true
				end
				-- spell1, spell2, hr, allclassesplus, nl
				MAIAddStanceButton(
					{
						["spellid"] = tab[1],
						["art"] = tab[2],
						["db"] = MAIGV( "CLASSES" )["MAGE"][i][x]
					},{
						["spellid"] = tab[4],
						["art"] = tab[5],
					},
					hr,
					tab[3]
				)
			end
		end

		MAIUpdateStanceBarSize()
		StanceBar:Show()
	elseif englishClass == "HUNTER" then
		if MAIGV( "CLASSES" )["HUNTER"] == nil then
			MAIGV( "CLASSES" )["HUNTER"] = {}
		end
		MAIGV( "CLASSES" )["HUNTERVERSION"] = MAIGV( "CLASSES" )["HUNTERVERSION"] or 0
		if MAIGV( "CLASSES" )["HUNTERVERSION"] ~= 3 then
			MAIGV( "CLASSES" )["HUNTERVERSION"] = 3

			MAIGV( "CLASSES" )["HUNTER"][1] = {}
			MAIGV( "CLASSES" )["HUNTER"][1][1] = {13163, "aspect"} -- Affen
			MAIGV( "CLASSES" )["HUNTER"][1][2] = {13165, "aspect"} -- Falken
			MAIGV( "CLASSES" )["HUNTER"][1][3] = {5118, "aspect"} -- Geparden
			MAIGV( "CLASSES" )["HUNTER"][1][4] = {13159, "aspect"} -- Rudels
			MAIGV( "CLASSES" )["HUNTER"][1][5] = {13161, "aspect"} -- Wildtiers
			MAIGV( "CLASSES" )["HUNTER"][1][6] = {20043, "aspect"} -- Nature
			MAIGV( "CLASSES" )["HUNTER"][1][7] = {34074, "aspect"} -- Viper
			MAIGV( "CLASSES" )["HUNTER"][1][8] = {186257, "aspect", true} -- [RETAIL] Geparden
			MAIGV( "CLASSES" )["HUNTER"][1][9] = {186265, "aspect", true} -- [RETAIL] Schildkröte
			MAIGV( "CLASSES" )["HUNTER"][1][10] = {193530, "aspect", true} -- [RETAIL] Wildnis
			MAIGV( "CLASSES" )["HUNTER"][1][11] = {186289, "aspect", true} -- [RETAIL] Adlers

			MAIGV( "CLASSES" )["HUNTER"][2] = {}
			MAIGV( "CLASSES" )["HUNTER"][2][1] = {19506, "hunteraura"} -- Aura des Volltreffers

			MAIGV( "CLASSES" )["HUNTER"][3] = {}
			MAIGV( "CLASSES" )["HUNTER"][3][1] = {13795, "trap", true} -- Feuerbrandfalle
			MAIGV( "CLASSES" )["HUNTER"][3][2] = {13813, "trap", true} -- Sprengfalle
			MAIGV( "CLASSES" )["HUNTER"][3][3] = {1499, "trap", true} -- Eiskältefalle
			MAIGV( "CLASSES" )["HUNTER"][3][4] = {13809, "trap", true} -- Frostfalle
			MAIGV( "CLASSES" )["HUNTER"][3][5] = {34600, "trap", true} -- Schlangenfalle

			--MAIMakeStanceButton(1494, true ), true )) -- Wildtiere
			--MAIMakeStanceButton(19883, nil, true )) -- Humanoid
			--MAIMakeStanceButton(19884, nil, true )) -- Untote
			--MAIMakeStanceButton(19885, nil, true )) -- Verborgenes
			--MAIMakeStanceButton(19880, nil, true )) -- Elementare
			--MAIMakeStanceButton(19878, nil, true )) -- Dämonen
			--MAIMakeStanceButton(19882, nil, true )) -- Riesen
			--MAIMakeStanceButton(19879, nil, true )) -- Drachkin
		end

		local oldi = 0
		for i, v in pairs(MAIGV( "CLASSES" )["HUNTER"] ) do
			local hr = false
			for x, tab in pairs(v) do
				hr = false
				
				if i ~= oldi and tab[1] and MAIIsSpellKnown(tab[1], "HUNTER") then
					oldi = i
					hr = true
				end
				-- spell1, spell2, hr, allclassesplus, nl
				MAIAddStanceButton(
					{
						["spellid"] = tab[1],
						["art"] = tab[2],
						["db"] = MAIGV( "CLASSES" )["HUNTER"][i][x]
					},
					{
						
					},
					hr,
					tab[3]
				)
			end
		end

		MAIUpdateStanceBarSize()
		StanceBar:Show()
	elseif englishClass == "SHAMAN" then
		if MAIGV( "CLASSES" )["SHAMAN"] == nil then
			MAIGV( "CLASSES" )["SHAMAN"] = {}
		end
		MAIGV( "CLASSES" )["SHAMANVERSION"] = MAIGV( "CLASSES" )["SHAMANVERSION"] or 0
		if MAIGV( "CLASSES" )["SHAMANVERSION"] ~= 6 then
			MAIGV( "CLASSES" )["SHAMANVERSION"] = 6

			MAIGV( "CLASSES" )["SHAMAN"][5] = {}
			MAIGV( "CLASSES" )["SHAMAN"][5][1] = {36936, "totem"} -- Ruf der Totems

			MAIGV( "CLASSES" )["SHAMAN"][4] = {}
			MAIGV( "CLASSES" )["SHAMAN"][4][1] = {3599, "fire"} -- Verbrennung
			MAIGV( "CLASSES" )["SHAMAN"][4][2] = {1535, "fire"} -- Feuernova
			MAIGV( "CLASSES" )["SHAMAN"][4][3] = {8190, "fire"} -- glühenden Magmas
			MAIGV( "CLASSES" )["SHAMAN"][4][4] = {8227, "fire"} -- Flammenzunge
			MAIGV( "CLASSES" )["SHAMAN"][4][5] = {8181, "fire"} -- Frostwiderstands
			MAIGV( "CLASSES" )["SHAMAN"][4][6] = {2894, "fire"} -- Feuerelementars
			MAIGV( "CLASSES" )["SHAMAN"][4][7] = {198067, "fire"} -- [RETAIL] Feuerelementars
			MAIGV( "CLASSES" )["SHAMAN"][4][8] = {30706, "fire"} -- [TBC][Talent] Totem des Ingrimms

			MAIGV( "CLASSES" )["SHAMAN"][3] = {}
			MAIGV( "CLASSES" )["SHAMAN"][3][1] = {8071, "earth"} -- Steinhaut
			MAIGV( "CLASSES" )["SHAMAN"][3][2] = {2484, "earth"} -- Erdbindung
			MAIGV( "CLASSES" )["SHAMAN"][3][3] = {5730, "earth"} -- Steinklaue
			MAIGV( "CLASSES" )["SHAMAN"][3][4] = {8075, "earth"} -- Erdstärke
			MAIGV( "CLASSES" )["SHAMAN"][3][5] = {8143, "earth"} -- Erdstoßes
			MAIGV( "CLASSES" )["SHAMAN"][3][6] = {2062, "earth"} -- Erdelementars
			MAIGV( "CLASSES" )["SHAMAN"][3][7] = {198103, "earth"} -- [RETAIL] Erdelementars
			
			MAIGV( "CLASSES" )["SHAMAN"][2] = {}
			MAIGV( "CLASSES" )["SHAMAN"][2][1] = {5394, "water"} -- heilenden Flusses
			MAIGV( "CLASSES" )["SHAMAN"][2][2] = {5675, "water"} -- Manaquelle
			MAIGV( "CLASSES" )["SHAMAN"][2][3] = {16190, "water"} -- [TBC][TALENT] Manaquelle
			MAIGV( "CLASSES" )["SHAMAN"][2][4] = {8170, "water"} -- Krankheitsreinigung
			MAIGV( "CLASSES" )["SHAMAN"][2][5] = {8166, "water"} -- Giftreinigung
			MAIGV( "CLASSES" )["SHAMAN"][2][6] = {8184, "water"} -- Feuerwiderstands
			MAIGV( "CLASSES" )["SHAMAN"][2][7] = {16191, "water"} -- [RETAIL] Manaflut
			MAIGV( "CLASSES" )["SHAMAN"][2][8] = {108280, "water"} -- [RETAIL] Heilungsflut

			MAIGV( "CLASSES" )["SHAMAN"][1] = {}
			MAIGV( "CLASSES" )["SHAMAN"][1][1] = {25908, "air"} -- beruhigenden Winde
			MAIGV( "CLASSES" )["SHAMAN"][1][2] = {8835, "air"} -- luftgleichen Anmut
			MAIGV( "CLASSES" )["SHAMAN"][1][3] = {8512, "air"} -- Windzorns
			MAIGV( "CLASSES" )["SHAMAN"][1][4] = {8177, "air"} -- Erdung
			MAIGV( "CLASSES" )["SHAMAN"][1][5] = {6495, "air"} -- Wachens
			MAIGV( "CLASSES" )["SHAMAN"][1][6] = {15107, "air"} -- Windmauer
			MAIGV( "CLASSES" )["SHAMAN"][1][7] = {10595, "air"} -- Natzrwiderstands
			MAIGV( "CLASSES" )["SHAMAN"][1][8] = {3738, "air"} -- stürmischen Zorns
			MAIGV( "CLASSES" )["SHAMAN"][1][9] = {192058, "air"} -- [RETAIL] Energiespeicherung
			MAIGV( "CLASSES" )["SHAMAN"][1][10] = {98008, "air"} -- [RETAIL] Geisterbindung
		end

		if MultiCastActionBarFrame == nil then
			local oldi = 0
			for i, v in pairs(MAIGV( "CLASSES" )["SHAMAN"] ) do
				local nl = false
				for x, totem in pairs(v) do
					nl = false
					if i ~= oldi and MAIIsSpellKnown(totem[1], "SHAMAN") then
						oldi = i
						nl = true
					end
					-- spell1, spell2, hr, allclassesplus, nl
					MAIAddStanceButton(
						{
							["spellid"] = totem[1],
							["art"] = totem[2],
							["db"] = MAIGV( "CLASSES" )["SHAMAN"][i][x]
						},
						{
							
						},
						nil,
						nil,
						nl
					)
				end
			end

			MAIUpdateStanceBarSize()
			StanceBar:Show()
		end
	elseif englishClass == "WARLOCK" then
		if MAIGV( "CLASSES" )["WARLOCK"] == nil then
			MAIGV( "CLASSES" )["WARLOCK"] = {}
		end
		MAIGV( "CLASSES" )["WARLOCKVERSION"] = MAIGV( "CLASSES" )["WARLOCKVERSION"] or 0
		if MAIGV( "CLASSES" )["WARLOCKVERSION"] ~= 4 then
			MAIGV( "CLASSES" )["WARLOCKVERSION"] = 3

			MAIGV( "CLASSES" )["WARLOCK"][1] = {}
			MAIGV( "CLASSES" )["WARLOCK"][1][1] = {688, "daemon"} -- Wichtel
			MAIGV( "CLASSES" )["WARLOCK"][1][2] = {697, "daemon"} -- Leerwandler
			MAIGV( "CLASSES" )["WARLOCK"][1][3] = {712, "daemon"} -- Sukkubus
			MAIGV( "CLASSES" )["WARLOCK"][1][4] = {366222, "daemon"} -- Sukkubus, Retail
			MAIGV( "CLASSES" )["WARLOCK"][1][5] = {691, "daemon"} -- Teufelsjäger
			MAIGV( "CLASSES" )["WARLOCK"][1][6] = {1122, "daemon"} -- Inferno
			MAIGV( "CLASSES" )["WARLOCK"][1][7] = {30146, "daemon"} -- Teufelswache

			MAIGV( "CLASSES" )["WARLOCK"][2] = {}
			MAIGV( "CLASSES" )["WARLOCK"][2][1] = {1098, "control"} -- Dämonensklave

			MAIGV( "CLASSES" )["WARLOCK"][3] = {}
			MAIGV( "CLASSES" )["WARLOCK"][3][1] = {29893, "spellitem"} -- Ritual of Souls
			MAIGV( "CLASSES" )["WARLOCK"][3][2] = {6201, "spellitem"} -- Gesundheitsstein
			MAIGV( "CLASSES" )["WARLOCK"][3][3] = {693, "spellitem"} -- Seelenstein
			MAIGV( "CLASSES" )["WARLOCK"][3][4] = {6366, "spellitem"} -- Feuerstein
			MAIGV( "CLASSES" )["WARLOCK"][3][5] = {2362, "spellitem"} -- Zauberstein

			MAIGV( "CLASSES" )["WARLOCK"][4] = {}
			MAIGV( "CLASSES" )["WARLOCK"][4][1] = {698, "teleport"} -- Ritual der Beschwörung

			MAIGV( "CLASSES" )["WARLOCK"][5] = {}
			MAIGV( "CLASSES" )["WARLOCK"][5][1] = {687, "buff", true} -- Dämonenrüstung
			MAIGV( "CLASSES" )["WARLOCK"][5][2] = {28176, "buff", true} -- Dämonenrüstung
			MAIGV( "CLASSES" )["WARLOCK"][5][3] = {5697, "buff", true} -- Unendlicher Atem
			MAIGV( "CLASSES" )["WARLOCK"][5][4] = {132, "buff", true} -- Unsichtbarkeit entdecken
		end

		local oldi = 0
		for i, v in pairs( MAIGV( "CLASSES" )["WARLOCK"] ) do
			local hr = false
			for x, tab in pairs(v) do
				hr = false
				if i ~= oldi and MAIIsSpellKnown(tab[1], "WARLOCK") then
					oldi = i
					hr = true
				end
				local b = MAIAddStanceButton(
					{
						["spellid"] = tab[1],
						["art"] = tab[2],
						["db"] = MAIGV( "CLASSES" )["WARLOCK"][i][x]
					},
					{
						
					},
					hr,
					tab[3]
				)
				if b then
					if tab[1] == 1122 then
						b.hellstone = true
					elseif b and i < 6 then
						b.soulstone = true
					end
				end
			end
		end

		MAIUpdateStanceBarSize()
		StanceBar:Show()
	elseif englishClass == "PALADIN" then
		if MAIGV( "CLASSES" )["PALADIN"] == nil then
			MAIGV( "CLASSES" )["PALADIN"] = {}
		end
		MAIGV( "CLASSES" )["PALADINVERSION"] = MAIGV( "CLASSES" )["PALADINVERSION"] or 0
		if MAIGV( "CLASSES" )["PALADINVERSION"] ~= 5 then
			MAIGV( "CLASSES" )["PALADINVERSION"] = 5

			MAIGV( "CLASSES" )["PALADIN"][1] = {}
			MAIGV( "CLASSES" )["PALADIN"][1][1] = {nil, "fake"} -- FAKE (Aura leiste)

			MAIGV( "CLASSES" )["PALADIN"][2] = {}
			MAIGV( "CLASSES" )["PALADIN"][2][1] = {19740, "buffnormal", nil, 25782, "buffbetter", nil} -- Segen der Macht
			MAIGV( "CLASSES" )["PALADIN"][2][2] = {19742, "buffnormal", nil, 25894, "buffbetter", nil} -- Segen der Weisheit
			MAIGV( "CLASSES" )["PALADIN"][2][3] = {19977, "buffnormal", nil, 25890, "buffbetter", nil} -- Segen des Lichts
			MAIGV( "CLASSES" )["PALADIN"][2][4] = {1038, "buffnormal", nil, 25895, "buffbetter", nil} -- Segen der Rettung
			MAIGV( "CLASSES" )["PALADIN"][2][5] = {20911, "buffnormal", nil, 25899, "buffbetter", nil} -- Segen des Refugiums
			MAIGV( "CLASSES" )["PALADIN"][2][6] = {20217, "buffnormal", nil, 25898, "buffbetter", nil} -- Segen der Könige
			MAIGV( "CLASSES" )["PALADIN"][2][7] = {1044, "buffnormal", true} -- Segen der Freiheit
			MAIGV( "CLASSES" )["PALADIN"][2][8] = {1022, "buffnormal", true} -- Segen des Schutzes
			MAIGV( "CLASSES" )["PALADIN"][2][9] = {6940, "buffnormal", true} -- Segen der Opferung
			
			MAIGV( "CLASSES" )["PALADIN"][3] = {}
		end

		local oldi = 0
		for i, v in pairs( MAIGV( "CLASSES" )["PALADIN"] ) do
			local nl = false
			for x, buff in pairs(v) do
				nl = false
				if i ~= oldi and buff[1] and MAIIsSpellKnown(buff[1], "PALADIN") then
					oldi = i
					nl = true
				end
				MAIAddStanceButton(
					{
						["spellid"] = buff[1],
						["art"] = buff[2],
						["db"] = MAIGV( "CLASSES" )["PALADIN"][i][x]
					},
					{
						["spellid"] = buff[4],
						["art"] = buff[5]
					},
					nil,
					buff[3],
					nl
				)
			end
		end

		MAIUpdateStanceBarSize()
		StanceBar:Show()
	end

	MAISetupLFG()

	if MAIBUILD ~= "RETAIL" then
		MAISkinFrame( "WorldMapFrame.BorderFrame", { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 } )

		MAISkinFrame( "PaperDollFrame", { 1, 2, 3, 4 } )
		MAISkinFrame( "PetPaperDollFrame", { 1, 2, 3, 4 } )
		MAISkinFrame( "CharacterFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "CharacterFrameTab2", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "CharacterFrameTab3", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "CharacterFrameTab4", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "CharacterFrameTab5", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "ReputationFrame", { 1, 2, 3, 4 } )
		MAISkinFrame( "ReputationListScrollFrame", { 1, 2, 3 } )
		MAISkinFrame( "SkillFrame", { 1, 2, 3, 4,5,6 } )
		MAISkinFrame( "SkillFrameExpandButtonFrame", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "SkillListScrollFrame", { 1, 2, 3 } )
		MAISkinFrame( "SkillDetailScrollFrame", { 1, 2, 3 } )
		MAISkinFrame( "HonorFrame", { 1, 2, 3, 4, 6, 7, 8, 9, 10 } )
		MAISkinFrame( "PVPFrame", { 1, 2, 3, 4, 5 } ) -- TBC

		MAISkinFrame( "SpellBookFrame", { 2, 3, 4, 5 } )
		for i = 1, 16 do
			MAISkinFrame( "SpellButton" .. i, { 1} )
		end
		for i = 1, 6 do
			MAISkinFrame( "SpellBookSkillLineTab" .. i, { 1 } )
		end
		for i = 1, 2 do
			MAISkinFrame( "SpellBookFrameTabButton" .. i, { 2, 3, 4 } )
		end

		MAISkinFrame( "PlayerTalentFrame", { 2, 3, 4, 5, 11, 12, 13 }, true )
		MAISkinFrame( "PlayerTalentFrameTab1", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "PlayerTalentFrameTab2", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "PlayerTalentFrameTab3", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "PlayerTalentFrameScrollFrame", { 1, 2, 3 }, true )

		MAISkinFrame( "QuestLogFrame", { 3, 4, 5, 6, 8, 9, 10, 12, 13 } )--{ 1, 2, 7, 11 } )
		MAISkinFrame( "QuestLogScrollFrame", { 1, 2, 3 } )
		if QuestLogFrame then
			QuestLogFrame.texture = QuestLogFrame:CreateTexture( nil, "OVERLAY", nil, 7 )
			QuestLogFrame.texture:SetTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\QuestBG" )
			QuestLogFrame.texture:SetWidth( 514 )
			QuestLogFrame.texture:SetPoint( "TOPLEFT", QuestLogDetailScrollFrame, "TOPLEFT", 0, 0 )
			local h = 400
			if IsAddOnLoaded("WideQuestLog") then
				h = 560
				QuestLogFrame.texture:SetPoint( "TOPLEFT", QuestLogDetailScrollFrame, "TOPLEFT", -12, 3 )
				QuestLogFrame.texture:SetWidth( 540 )
			end
			QuestLogFrame.texture:SetHeight( h )
		end
		MAISkinFrame( "QuestLogCollapseAllButton", { 7, 8, 9 } )

		MAISkinFrame( "FriendsFrame", { 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17 } )
		MAISkinFrame( "FriendsFrameFriendsScrollFrame", { 1, 2, 3 } )
		MAISkinFrame( "FriendsFrameInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "FriendsTabHeaderTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsTabHeaderTab2", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsFrameTab2", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsFrameTab3", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsFrameTab4", { 1, 2, 3, 4, 5, 6 } )

		MAISkinFrame( "WhoFrameListInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "WhoListScrollFrame", { 1, 2, 3 } )
		MAISkinFrame( "WhoFrameEditBoxInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )

		MAISkinFrame( "LFGParentFrame", { 2 } )
		MAISkinFrame( "LFGParentFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "LFGParentFrameTab2", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "LFMFrameInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )

		MAISkinFrame( "GameMenuFrame", { 1, 3, 4, 5, 6, 7, 8, 9, 10, 11 } )

		MAISkinFrame( "MerchantFrame", { 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 22, 23, 24 } )
		MAISkinFrame( "MerchantFrameInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "MerchantBuyBackItem", { 1, 2 } )
		MAISkinFrame( "MerchantMoneyBg", { 1, 2, 3 } )
		MAISkinFrame( "MerchantMoneyInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "MerchantFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "MerchantFrameTab2", { 1, 2, 3, 4, 5, 6 } )

		MAISkinFrame( "MailFrame", { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 } )
		MAISkinFrame( "MailFrameInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "InboxFrame", { 1 } )
		for i = 1, 30 do
			MAISkinFrame( "SendMailAttachment" .. i, { 1, 2, 3, 4, 5 } )
		end
		MAISkinFrame( "SendMailFrame", { 2, 3, 4, 5, 6, 7 } )
		MAISkinFrame( "SendMailMoneyInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "SendMailMoneyBg", { 1, 2, 3 } )
		MAISkinFrame( "MailFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "MailFrameTab2", { 1, 2, 3, 4, 5, 6 } )

		MAISkinFrame( "OpenMailFrame", { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 24, 25 } )
		MAISkinFrame( "OpenMailFrameInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "OpenMailScrollFrame", { 1, 2 } )

		MAISkinFrame( "BankFrame", { 2 } )

		MAISkinFrame( "GossipFrameGreetingPanel", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "GossipGreetingScrollFrame", { 1, 2, 3 } )
		if MAIGV( "FrameColorEnabled", true ) then
			GossipFrameGreetingPanel.texture = GossipFrameGreetingPanel:CreateTexture( nil, "OVERLAY", nil, 7 )
			GossipFrameGreetingPanel.texture:SetTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\QuestBG" )
			GossipFrameGreetingPanel.texture:SetSize( 514, 517 )
			GossipFrameGreetingPanel.texture:SetPoint( "TOPLEFT", GossipFrameGreetingPanel, "TOPLEFT", 22, -78 )
		end

		MAISkinFrame( "QuestFrameRewardPanel", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "QuestRewardScrollFrame", { 1, 2, 3 } )
		if MAIGV( "FrameColorEnabled", true ) then
			QuestFrameRewardPanel.texture = QuestFrameRewardPanel:CreateTexture( nil, "OVERLAY", nil, 7 )
			QuestFrameRewardPanel.texture:SetTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\QuestBG" )
			QuestFrameRewardPanel.texture:SetSize( 514, 517 )
			QuestFrameRewardPanel.texture:SetPoint( "TOPLEFT", QuestFrameRewardPanel, "TOPLEFT", 22, -78 )
		end
		MAISkinFrame( "QuestFrameDetailPanel", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "QuestDetailScrollFrame", { 1, 2, 3 } )
		if MAIGV( "FrameColorEnabled", true ) then
			QuestFrameDetailPanel.texture = QuestFrameDetailPanel:CreateTexture( nil, "OVERLAY", nil, 7 )
			QuestFrameDetailPanel.texture:SetTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\QuestBG" )
			QuestFrameDetailPanel.texture:SetSize( 514, 517 )
			QuestFrameDetailPanel.texture:SetPoint( "TOPLEFT", QuestFrameDetailPanel, "TOPLEFT", 22, -78 )
		end

		MAISkinFrame( "QuestFrameProgressPanel", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "QuestProgressScrollFrame", { 1, 2, 3 } )
		if MAIGV( "FrameColorEnabled", true ) then
			QuestFrameProgressPanel.texture = QuestFrameProgressPanel:CreateTexture( nil, "OVERLAY", nil, 7 )
			QuestFrameProgressPanel.texture:SetTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\QuestBG" )
			QuestFrameProgressPanel.texture:SetSize( 514, 517 )
			QuestFrameProgressPanel.texture:SetPoint( "TOPLEFT", QuestFrameProgressPanel, "TOPLEFT", 22, -78 )
		end

		MAISkinFrame( "QuestFrameGreetingPanel", { 1, 2, 3, 4, 10 } )
		MAISkinFrame( "QuestGreetingScrollFrame", { 1, 2, 3 } )
		if MAIGV( "FrameColorEnabled", true ) then
			QuestFrameGreetingPanel.texture = QuestFrameGreetingPanel:CreateTexture( nil, "OVERLAY", nil, 7 )
			QuestFrameGreetingPanel.texture:SetTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\QuestBG" )
			QuestFrameGreetingPanel.texture:SetSize( 514, 517 )
			QuestFrameGreetingPanel.texture:SetPoint( "TOPLEFT", QuestFrameGreetingPanel, "TOPLEFT", 22, -78 )
		end

		MAISkinFrame( "ClassTrainerFrame", { 2, 3, 4, 5, 8, 9 }, true )
		MAISkinFrame( "ClassTrainerExpandButtonFrame", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "ClassTrainerListScrollFrame", { 1, 2, 3 }, true )

		MAISkinFrame( "LootFrame", { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 } )
		MAISkinFrame( "LootFrameInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )

		MAISkinFrame( "AuctionFrame", { 2, 3, 4, 5, 6, 7  }, true )
		MAISkinFrame( "BrowseBidButton", { 6 }, true )
		MAISkinFrame( "BrowseBuyoutButton", { 6 }, true )
		MAISkinFrame( "BrowseCloseButton", { 6 }, true )
		MAISkinFrame( "BidBidButton", { 6 }, true )
		MAISkinFrame( "BidBuyoutButton", { 6 }, true )
		MAISkinFrame( "BidCloseButton", { 6 }, true )
		MAISkinFrame( "AuctionFrameTab1", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "AuctionFrameTab2", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "AuctionFrameTab3", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "AuctionFrameTab4", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "AuctionFrameTab5", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "AuctionFrameTab6", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "AuctionFrameTab7", { 1, 2, 3, 4, 5, 6 }, true )

		MAISkinFrame( "ItemTextFrame", { 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "ItemTextScrollFrame", { 1, 2, 3 } )
		if MAIGV( "FrameColorEnabled", true ) then
			ItemTextFrame.texture = ItemTextFrame:CreateTexture( nil, "OVERLAY", nil, 7 )
			ItemTextFrame.texture:SetTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\QuestBG" )
			ItemTextFrame.texture:SetSize( 514, 517 )
			ItemTextFrame.texture:SetPoint( "TOPLEFT", ItemTextFrame, "TOPLEFT", 22, -78 )
		end

		MAISkinFrame( "TradeSkillFrame", { 2, 3, 4, 5 }, true )
		MAISkinFrame( "TradeSkillListScrollFrame", { 1, 2, 3 }, true )
		MAISkinFrame( "TradeSkillExpandButtonFrame", { 1, 2, 3, 4, 5, 6 }, true )	
	else
		MAISkinFrame( "WorldMapFrameBg", { 1 } )
		MAISkinFrame( "WorldMapFrame.BorderFrame", { 1 } )
		MAISkinFrame( "WorldMapFrame.BorderFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "WorldMapFrame.NavBar", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "QuestScrollFrame.ScrollBar", { 1, 2, 3, 4 } )

		MAISkinFrame( "CharacterFrame", { 1, 2 } )
		MAISkinFrame( "CharacterFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "PaperDollSidebarTabs", { 1, 2 } )
		MAISkinFrame( "PaperDollSidebarTab1", { 1 } )
		MAISkinFrame( "PaperDollSidebarTab2", { 1 } )
		MAISkinFrame( "PaperDollSidebarTab3", { 1 } )
		MAISkinFrame( "CharacterFrameInsetRight", { 1 } )
		MAISkinFrame( "CharacterFrameInsetRight.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "CharacterStatsPane", { 1 } )
		MAISkinFrame( "CharacterFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "CharacterFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "CharacterFrameTab2", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "CharacterFrameTab3", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "CharacterFrameTab4", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "CharacterFrameInset", { 1 } )
		MAISkinFrame( "CharacterModelFrame", { 6, 7, 8, 9, 10, 11, 12, 13, 14 } )
		for i, v in pairs( MAICharSlots ) do
			MAISkinFrame( "Character" .. v, { 16, 17 } )
		end
		MAISkinFrame( "ReputationListScrollFrame", { 1, 2 } )

		MAISkinFrame( "SpellBookFrame", { 1, 2, 6, 7 }, false )
		MAISkinFrame( "SpellBookFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "SpellBookFrameInset", { 1 } )
		MAISkinFrame( "SpellBookFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "SpellBookFrameTabButton1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "SpellBookFrameTabButton2", { 1, 2, 3, 4, 5, 6 } )
		for i = 1, 6 do
			MAISkinFrame( "SpellBookSkillLineTab" .. i, { 1 } )
		end

		MAISkinFrame( "PlayerTalentFrame", { 1, 2 }, true )
		MAISkinFrame( "PlayerTalentFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 }, true )
		MAISkinFrame( "PlayerTalentFrameBg", nil, true )
		MAISkinFrame( "PlayerTalentFrameInset", { 1 }, true )
		MAISkinFrame( "PlayerTalentFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 }, true )
		MAISkinFrame( "PlayerTalentFrameSpecialization", { 1, 2, 3, 4, 5 ,6 }, true )
		MAISkinFrame( "PlayerTalentFrameTab1", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "PlayerTalentFrameTab2", { 1, 2, 3, 4, 5, 6 }, true )
		MAISkinFrame( "PlayerTalentFrameTab3", { 1, 2, 3, 4, 5, 6 }, true )
		--MAISkinFrame( "PlayerTalentFrameScrollFrame", { 1, 2, 3 }, true )

		MAISkinFrame( "PVEFrame", { 1, 2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } )
		MAISkinFrame( "PVEFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "PVEFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "PVEFrameTab2", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "PVEFrameTab3", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "PVEFrameInset", { 1 } )
		MAISkinFrame( "PVEFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "PVEFrameLeftInset", { 1 } )
		MAISkinFrame( "PVEFrameLeftInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )

		MAISkinFrame( "FriendsFrame", { 1, 2, 3, 5 } )
		MAISkinFrame( "FriendsFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "FriendsFrameInset", { 1 } )
		MAISkinFrame( "FriendsFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "FriendsListFrameScrollFrame.Slider", { 1, 2, 3,4 } )
		MAISkinFrame( "FriendsTabHeaderTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsTabHeaderTab2", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsTabHeaderTab3", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsFrameTab2", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsFrameTab3", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "FriendsFrameTab4", { 1, 2, 3, 4, 5, 6 } )

		MAISkinFrame( "WhoListScrollFrame.Slider", { 1, 2, 3, 4 } )
		MAISkinFrame( "WhoFrameListInset", { 1 } )
		MAISkinFrame( "WhoFrameListInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "WhoFrameEditBoxInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "WhoFrameEditBoxInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )

		MAISkinFrame( "GameMenuFrame.Header", { 1, 2, 3 } )
		MAISkinFrame( "GameMenuFrame.Border", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )

		MAISkinFrame( "MailFrame", { 1, 2, 3, 4, 5 } )
		MAISkinFrame( "MailFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "MailFrameInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "MailFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "InboxFrame", { 1 } )
		for i = 1, 30 do
			MAISkinFrame( "SendMailAttachment" .. i, { 1, 2, 3, 4, 5 } )
		end
		MAISkinFrame( "SendMailFrame", { 2, 3, 4, 5, 6, 7 } )
		MAISkinFrame( "SendMailMoneyInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "SendMailMoneyBg", { 1, 2, 3 } )
		MAISkinFrame( "MailFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "MailFrameTab2", { 1, 2, 3, 4, 5, 6 } )

		MAISkinFrame( "OpenMailFrame", { 1, 2, 3, 4, 5, 12, 13 } )
		MAISkinFrame( "OpenMailFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "OpenMailFrameInset", { 1, 2, 3, 4, 5, 6, 7, 8, 9 } )
		MAISkinFrame( "OpenMailFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "OpenMailScrollFrame", { 1, 2 } )

		MAISkinFrame( "BankFrame", { 2 } )
		MAISkinFrame( "BankFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "BankFrameInset", { 2 } )
		MAISkinFrame( "BankFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "BankFrameTab1", { 1, 2, 3, 4, 5, 6 }  )
		MAISkinFrame( "BankFrameTab2", { 1, 2, 3, 4, 5, 6 }  )

		MAISkinFrame( "GossipFrame", { 1, 2 } )
		MAISkinFrame( "GossipFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "GossipFrameInset", { 1 } )
		MAISkinFrame( "GossipFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "GossipGreetingScrollFrame", { 1, 2, 3 } )

		MAISkinFrame( "QuestFrame", { 1, 2 } )
		MAISkinFrame( "QuestFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "QuestProgressScrollFrame", { 1, 2, 3 } )
		MAISkinFrame( "QuestDetailScrollFrame", { 1, 2, 3 } )
		MAISkinFrame( "QuestRewardScrollFrame", { 1, 2, 3 } )
		MAISkinFrame( "QuestGreetingScrollFrame", { 1, 2, 3 } )
		
		MAISkinFrame( "LootFrame", { 1, 2, 3, 4, 5 } )
		MAISkinFrame( "LootFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "LootFrameInset", { 1 } )
		MAISkinFrame( "LootFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		
		MAISkinFrame( "ItemTextFrame", { 1, 2, 3 } )
		MAISkinFrame( "ItemTextFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "ItemTextFrameInset", { 1 } )
		MAISkinFrame( "ItemTextFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "ItemTextScrollFrameScrollBar", { 2, 3, 4 } )

		MAISkinFrame( "MerchantFrame", { 1, 2, 4, 5, 6, 7, 10, 11, 12 } )
		MAISkinFrame( "MerchantFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "MerchantFrameInset", { 1 } )
		MAISkinFrame( "MerchantFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 } )
		MAISkinFrame( "MerchantBuyBackItem", { 1, 2 } )
		MAISkinFrame( "MerchantMoneyBg", { 1, 2, 3 } )
		MAISkinFrame( "MerchantMoneyInset" )
		MAISkinFrame( "MerchantFrameTab1", { 1, 2, 3, 4, 5, 6 } )
		MAISkinFrame( "MerchantFrameTab2", { 1, 2, 3, 4, 5, 6 } )

		MAISkinFrame( "BackpackTokenFrame", { 1 } ) -- backpack unten

		MAISkinFrame( "TradeSkillFrame", { 1, 2, 5, 6, 7, 8 }, true )
		MAISkinFrame( "TradeSkillFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 }, true )
		MAISkinFrame( "TradeSkillFrameInset", { 1 }, true )
		MAISkinFrame( "TradeSkillFrameInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 }, true )
		MAISkinFrame( "TradeSkillFrame.RecipeList.scrollBar", { 1, 2, 3, 4 }, true )
		MAISkinFrame( "TradeSkillFrame.RecipeInset", { 1 }, true )
		MAISkinFrame( "TradeSkillFrame.RecipeInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 }, true )
		MAISkinFrame( "TradeSkillFrame.DetailsFrame", { 1 }, true )
		MAISkinFrame( "TradeSkillFrame.DetailsFrame.ScrollBar", { 1, 2, 3, 4 }, true )
		MAISkinFrame( "TradeSkillFrame.DetailInset", { 1 }, true )
		MAISkinFrame( "TradeSkillFrame.DetailInset.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 }, true )
		MAISkinFrame( "TradeSkillExpandButtonFrame", { 1, 2, 3, 4, 5, 6 }, true )	
	end

	--[[MAISkinFrame( "InspectFrame", { 1, 2 }, true )
	MAISkinFrame( "InspectFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 }, true )
	MAISkinFrame( "InspectPaperDollFrame", { 1, 2 }, true )
	MAISkinFrame( "InspectPaperDollFrame.NineSlice", { 1, 2, 3, 4, 5, 6, 7, 8 }, true )
	]]
	
	for i = 1, 13 do
		MAISkinFrame( "ContainerFrame" .. i, { 2, 3, 4, 5 } )
	end

	for id = 1, 4 do
		local pftexture = _G["PartyMemberFrame" .. id .. "Texture"]
		if pftexture then
			MAIRegisterUIColor(pftexture)
		end
	end
end

local MAIPREFIX = "D4MAI"
local MAICHECKEDVERSION = false
local function OnEvent(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, version, _, target = ...
		if prefix == MAIPREFIX then
			local name = MAIUnitName("PLAYER")

			if target == name then --self? -> exit
				return
			end

			if version == MAIVERSION then -- if targetversion < as selfversion
				C_ChatInfo.SendAddonMessage(MAIPREFIX, MAIVERSION, "WHISPER", target) -- send to the target selfversion
			else
				if MAICHECKEDVERSION == false then -- check only once, against spam
					MAICHECKEDVERSION = true
					
					MAIMSG("There is a new version available (v" .. version .. ")")
				end
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		local isInitialLogin, isReloadingUi = ...
		if isInitialLogin or isReloadingUi then
			C_ChatInfo.RegisterAddonMessagePrefix(MAIPREFIX)

			if IsInRaid(LE_PARTY_CATEGORY_HOME) then
				C_ChatInfo.SendAddonMessage(MAIPREFIX, MAIVERSION, "RAID")
			elseif IsInRaid(LE_PARTY_CATEGORY_INSTANCE) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
				C_ChatInfo.SendAddonMessage(MAIPREFIX, MAIVERSION, "INSTANCE_CHAT")
			elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
				C_ChatInfo.SendAddonMessage(MAIPREFIX, MAIVERSION, "PARTY")
			end

			if GetGuildInfo("player") then
				C_ChatInfo.SendAddonMessage(MAIPREFIX, MAIVERSION, "GUILD")
			end
			if MAIBUILD == "RETAIL" then
				for i = 1, 5 do
					local id, name = GetChannelName(i)
					if name ~= nil and (strlower(name) == "lfg" or strlower(name) == "world") then
						C_ChatInfo.SendAddonMessage(MAIPREFIX, MAIVERSION, "CHANNEL", id)
					end
				end
			end
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)



local function RemoveBadWords(self, event, msg, author, ...)
	msg = strlower(msg)

	if MAIGV( "blockwords" ) and MAIGV( "blockwords" ) ~= "" and MAIGV( "blockwords" ) ~= " " then
		for i, v in pairs({string.split(",", MAIGV( "blockwords" ) )}) do
			if v ~= "" and msg:find(strlower(v)) then
				return true
			end
		end
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", RemoveBadWords)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", RemoveBadWords)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", RemoveBadWords)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", RemoveBadWords)



function MAIAddRole(tab, role)
	if tab[role] == nil then
		tab[role] = {}
		tab[role] = 0
	end
	tab[role] = tab[role] + 1
end

function MAISetupSortSearchResult()
	if LFGListUtil_SortSearchResults then
		if MAIGV( "maismartfilter" ) == nil then
			MAISV( "maismartfilter", true )
		end

		local lfgfilter = CreateFrame( "FRAME", "MAILFGFilter")
		lfgfilter:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
		hooksecurefunc("LFGListUtil_SortSearchResults", function ( results )
			if not LFGListFrame.SearchPanel:IsShown() then
				return
			end

			local text = LFGListFrame.SearchPanel.SearchBox:GetText()
			if text == "" then -- ERROR when removing this line
				return
			end

			local rTab = {}
			rTab["TANK"] = 0
			rTab["HEALER"] = 0
			rTab["DAMAGER"] = 0
			local prole = UnitGroupRolesAssigned("PLAYER")
			if prole == "NONE" then
				prole= GetSpecializationRole(GetSpecialization())
			end
			MAIAddRole(rTab, prole)
			for i = 1, 4 do
				MAIAddRole(rTab, UnitGroupRolesAssigned("PARTY" .. i))
			end
			
			local accepted = {}
			local numAccepted = 0
			local numResults = #results

			for i = 1, numResults do
				local accept = true
				local id = results[i]
				local info = C_LFGList.GetSearchResultInfo(id)
				if info then
					local roles = C_LFGList.GetSearchResultMemberCounts(id);
					if roles then
						local rtank = roles.TANK_REMAINING
						local rheal = roles.HEALER_REMAINING
						local rdama = roles.DAMAGER_REMAINING
						if rtank > 0 or rheal > 0 or rdama > 0 then
							local tank = roles.TANK
							local heal = roles.HEALER
							local dama = roles.DAMAGER

							local btank = (tank + rTab["TANK"] <= 1) -- OLD
							local bheal = (heal + rTab["HEALER"] <= 1) -- OLD
							local bdama = (dama + rTab["DAMAGER"] <= 3) -- OLD

							btank = rTab["TANK"] <= rtank
							bheal = rTab["HEALER"] <= rheal
							bdama = rTab["DAMAGER"] <= rdama
							
							if btank and bheal and bdama then
								-- good
							else
								-- bad
								accept = false
							end
						end
					end
					
					if (not MAIGV( "nochanges" ) and MAIGV( "maismartfilter" )) and accept then
						numAccepted = numAccepted + 1
						accepted[i] = true
					else
						accepted[i] = false
					end
				end
			end

			if not MAIGV( "nochanges" ) and MAIGV( "maismartfilter" ) and numAccepted ~= numResults then
				for i, v in pairs( results ) do
					if not accepted[i] then
						table.remove( results, i )
					end
				end
				LFGListFrame.SearchPanel.totalResults = #results
				return true
			end
		end)
		--lfgfilter:SetScript("OnEvent", LFGFilterWrong)
	end
end



-- Share UnitXp
local XPPREFIX = "D4XP"
local XPAPIPREFIX = "D4XPAPI"

function MAIUnitXP(unit)
	local target = MAIUnitName(unit)
	if UnitIsUnit( unit, "player" ) then
		return UnitXP( "player" )
	end
	if MAILoaded and MAIGV( "XPTAB" ) and MAIGV( "XPTAB" )[target] and MAIGV( "XPTAB" )[target]["XP"] then
		return tonumber( MAIGV( "XPTAB" )[target]["XP"] )
	end
	return 0
end

function MAIUnitXPMax(unit)
	local target = MAIUnitName(unit)
	if UnitIsUnit( unit, "player" ) then
		return UnitXPMax( "player" )
	end
	if MAILoaded and MAIGV( "XPTAB" ) and MAIGV( "XPTAB" )[target] and MAIGV( "XPTAB" )[target]["XPMAX"] then
		return tonumber( MAIGV( "XPTAB" )[target]["XPMAX"] )
	end
	return 1
end

function MAIFormatValue(val)
	if val<1000 then return ("%.0f"):format(val)
	elseif val<1000000 then return ("%.1fk"):format(val/1000)
	elseif val<1000000000 then return ("%.1fm"):format(val/1000000)
	elseif val<1000000000000 then return ("%.1fb"):format(val/1000000000)
	else return ("%.1ft"):format(val/1000000000000) end
end

function MAIUpdatePartyXPAPI()
	if MAILoaded then
		for i = 1, 4 do
			local target = MAIUnitName("PARTY" .. i)
			if MAIGV( "XPTAB" )[target] == nil then
				MAIGV( "XPTAB" )[target] = {}
			end
		end

		local message = "Ping"
		if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			C_ChatInfo.SendAddonMessage(XPAPIPREFIX, message, "INSTANCE_CHAT")
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
			C_ChatInfo.SendAddonMessage(XPAPIPREFIX, message, "PARTY")
		end
	end
end

local maixpready = false
local function OnEventXP(self, event, ...)
	if MAILoaded then
		if event == "CHAT_MSG_ADDON" then
		local prefix, values, channel, target = ...
		if prefix == XPPREFIX and MAIGV( "XPTAB" ) then -- new xp values
			local xp, xpmax = string.split(";", values)
			if MAIGV( "XPTAB" )[target] == nil then
				MAIGV( "XPTAB" )[target] = {}
			end
			MAIGV( "XPTAB" )[target]["XP"] = xp
			MAIGV( "XPTAB" )[target]["XPMAX"] = xpmax
			MAIGV( "XPTAB" )[target]["useapi"] = true -- it uses the api
		elseif prefix == XPAPIPREFIX then
			if values == "Ping" then -- PING
				local message = "Pong" -- "answer to ping"
				if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
					C_ChatInfo.SendAddonMessage(XPAPIPREFIX, message, "INSTANCE_CHAT")
				elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
					C_ChatInfo.SendAddonMessage(XPAPIPREFIX, message, "PARTY")
				end
			else -- PONG
				if MAIGV( "XPTAB" )[target] == nil then
					MAIGV( "XPTAB" )[target] = {}
				end
				MAIGV( "XPTAB" )[target]["useapi"] = true -- received answer
			end
		end
		elseif event == "PLAYER_ENTERING_WORLD" then
			local isInitialLogin, isReloadingUi = ...
			if isInitialLogin or isReloadingUi then
				C_ChatInfo.RegisterAddonMessagePrefix(XPPREFIX)
				C_ChatInfo.RegisterAddonMessagePrefix(XPAPIPREFIX)

				if MAIGV( "XPTAB" ) == nil then
					MAISV( "XPTAB", {} )
				end

				for i = 1, 4 do
					local PartyFrame = _G["PartyMemberFrame" .. i]
					local PartyFrameTexture = _G["PartyMemberFrame" .. i .. "Texture"]
					local PartyPortrait = _G["PartyMemberFrame" .. i .. "Portrait"]
					local ManaBar = _G["PartyMemberFrame" .. i .. "ManaBar"]
					local Portrait = _G["PartyMemberFrame" .. i .. "Portrait"]
					if false then
						PartyFrame.Hide = PartyFrame.Show
						PartyFrame:Show()
					end
					for id = 1, 4 do
						local debuff = _G["PartyMemberFrame" .. i .. "Debuff" .. id]
						local parent = _G["PartyMemberFrame" .. i .. "Debuff" .. id - 1]
						if parent == nil then
							parent = PartyFrame				
						end
						if debuff then
							hooksecurefunc(debuff, "SetPoint", function(self)
								if self.maisetpoint then return end
								self.maisetpoint = true
								
								self:ClearAllPoints()
								if parent == PartyFrame then
									self:SetPoint( "LEFT", parent, "RIGHT", -4, 0 )
								else
									self:SetPoint( "LEFT", parent, "RIGHT", 4, 0 )
								end
			
								self.maisetpoint = false
							end)
							debuff:SetPoint( "LEFT", parent, "RIGHT", 0, 0 )
						end
					end

					if PartyFrame then
						local sw = ManaBar:GetWidth() - 1
						local sh = ManaBar:GetHeight() * 1.5
						local PartyFrameXPBar = CreateFrame( "Frame", "PartyFrameXPBar" .. i )
						PartyFrameXPBar:SetParent(PartyFrame)
						PartyFrameXPBar:SetSize(sw, sh)
						PartyFrameXPBar:SetPoint("TOP", ManaBar, "BOTTOM", 0, -2)
						PartyFrameXPBar:SetFrameStrata("HIGH")

						PartyFrameXPBar.textureBar = PartyFrameXPBar:CreateTexture(nil, "BACKGROUND")
						PartyFrameXPBar.textureBar:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
						PartyFrameXPBar.textureBar:SetSize(10, sh)
						PartyFrameXPBar.textureBar:SetPoint("LEFT", PartyFrameXPBar, "LEFT", 0, 0)
						PartyFrameXPBar.textureBar:SetColorTexture(0.25, 0.5, 1.0, 1.0)
				
						PartyFrameXPBar.textureBorder = PartyFrameXPBar:CreateTexture(nil, "BORDER")
						PartyFrameXPBar.textureBorder:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
						PartyFrameXPBar.textureBorder:SetSize(sw + 5, sh + 5)
						PartyFrameXPBar.textureBorder:SetPoint("CENTER", PartyFrameXPBar, "CENTER", 0, 0)
						
						MAIRegisterUIColor( PartyFrameXPBar.textureBorder )

						PartyFrameXPBar.XPC = PartyFrameXPBar:CreateFontString(nil, "ARTWORK", "TextStatusBarText") 
						PartyFrameXPBar.XPC:SetFont(STANDARD_TEXT_FONT, 10, "")
						PartyFrameXPBar.XPC:SetShadowOffset(1, -1)
						PartyFrameXPBar.XPC:SetAlpha(0.5)
						PartyFrameXPBar.XPC:SetPoint("CENTER", PartyFrameXPBar, "CENTER", 2, 0)
						PartyFrameXPBar.XPC:SetText( string.format( "%0.1f", math.random( 0, 1000 ) / 1000 * 100 ) .. "%" )

						PartyFrameXPBar.XPL = PartyFrameXPBar:CreateFontString(nil, "ARTWORK", "TextStatusBarText") 
						PartyFrameXPBar.XPL:SetFont(STANDARD_TEXT_FONT, 10, "")
						PartyFrameXPBar.XPL:SetShadowOffset(1, -1)
						PartyFrameXPBar.XPL:SetAlpha(0.5)
						PartyFrameXPBar.XPL:SetPoint("LEFT", PartyFrameXPBar, "LEFT", 2, 0)
						PartyFrameXPBar.XPL:SetText( string.format( "%0.1f", math.random( 0, 1000 ) / 1000 * 100 ) .. "%" )

						PartyFrameXPBar.XPR = PartyFrameXPBar:CreateFontString(nil, "ARTWORK", "TextStatusBarText") 
						PartyFrameXPBar.XPR:SetFont(STANDARD_TEXT_FONT, 10, "")
						PartyFrameXPBar.XPR:SetShadowOffset(1, -1)
						PartyFrameXPBar.XPR:SetAlpha(0.5)
						PartyFrameXPBar.XPR:SetPoint("RIGHT", PartyFrameXPBar, "RIGHT", 2, 0)
						PartyFrameXPBar.XPR:SetText( string.format( "%0.1f", math.random( 0, 1000 ) / 1000 * 100 ) .. "%" )

						PartyFrameXPBar.textureLvlBg = PartyFrameXPBar:CreateTexture(nil, "OVERLAY")
						PartyFrameXPBar.textureLvlBg:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
						PartyFrameXPBar.textureLvlBg:SetSize(42, 42)
						PartyFrameXPBar.textureLvlBg:SetPoint("CENTER", PartyPortrait, "BOTTOMLEFT", 8, -8)
						
						MAIRegisterUIColor(PartyFrameXPBar.textureLvlBg)

						PartyFrameXPBar.levelText = PartyFrameXPBar:CreateFontString(nil, "OVERLAY") 
						PartyFrameXPBar.levelText:SetFont(STANDARD_TEXT_FONT, 9, "")
						PartyFrameXPBar.levelText:SetShadowOffset(1, -1)
						PartyFrameXPBar.levelText:SetPoint( "CENTER", PartyFrameXPBar.textureLvlBg, "CENTER", -9, 9 )
						PartyFrameXPBar.levelText:SetText( "" .. math.random( 1, 59 ) )
						local c = GetQuestDifficultyColor( PartyFrameXPBar.levelText:GetText() )
						PartyFrameXPBar.levelText:SetTextColor( c.r, c.g, c.b, 1 )

						if MAIGV( "nochanges" ) == nil then
							MAISV( "nochanges", false )
						end

						function PartyFrameXPBar.think()
							if UnitExists("PARTY" .. i) and UnitLevel("PARTY" .. i) < MAIGetMaxLevel() then
								PartyFrameXPBar:Show()

								local c = GetQuestDifficultyColor( UnitLevel("PARTY" .. i) )
								PartyFrameXPBar.levelText:SetText( UnitLevel("PARTY" .. i) )
								PartyFrameXPBar.levelText:SetTextColor( c.r, c.g, c.b, 1 )

								local xp = MAIUnitXP( "PARTY" .. i, 0 )
								local xpmax = MAIUnitXPMax( "PARTY" .. i, 1 )
								if ( xp > 0 or xpmax > 1 ) and not MAIGV( "nochanges" ) then
									local per = xp / xpmax
									PartyFrameXPBar.textureBar:SetWidth( per * PartyFrameXPBar:GetWidth() - 4 )
					
									if GetCVar( "statusTextDisplay" ) == "PERCENT" then
										PartyFrameXPBar.XPC:SetText( string.format("%.0f", xp / xpmax * 100 ) .. "%" )
										PartyFrameXPBar.XPL:SetText( "" )
										PartyFrameXPBar.XPR:SetText( "" )
									elseif GetCVar( "statusTextDisplay" ) == "NUMERIC" then
										PartyFrameXPBar.XPC:SetText( string.format("%s/%s", MAINN( xp ), MAINN( xpmax ) ) )
										PartyFrameXPBar.XPL:SetText( "" )
										PartyFrameXPBar.XPR:SetText( "" )
									elseif GetCVar( "statusTextDisplay" ) == "BOTH" then
										PartyFrameXPBar.XPC:SetText( "" )
										PartyFrameXPBar.XPL:SetText( string.format("%.0f", xp / xpmax * 100 ) .. "%" )
										PartyFrameXPBar.XPR:SetText( string.format("%s", MAINN( xp ) ) )
									else
										PartyFrameXPBar.XPC:SetText( "" )
										PartyFrameXPBar.XPL:SetText( "" )
										PartyFrameXPBar.XPR:SetText( "" )
									end

									PartyFrameXPBar.textureBar:SetAlpha( 1 )
									PartyFrameXPBar.textureBorder:SetAlpha( 1 )
								else
									PartyFrameXPBar.XPC:SetText( "" )
									PartyFrameXPBar.XPL:SetText( "" )
									PartyFrameXPBar.XPR:SetText( "" )
									--PartyFrameXPBar.XPValue:SetText( "" )

									PartyFrameXPBar.textureBar:SetAlpha( 0 )
									PartyFrameXPBar.textureBorder:SetAlpha( 0 )
								end
							else
								PartyFrameXPBar:Hide()
							end

							C_Timer.After(0.1, PartyFrameXPBar.think)
						end
						PartyFrameXPBar.think()
					end
				end

				maixpready = true
			end
		end

		if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_XP_UPDATE" then
			if maixpready then
				if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
					MAIUpdatePartyXPAPI() -- "connect to the party members"
				end
				local message = UnitXP("PLAYER") .. ";" .. UnitXPMax("PLAYER") -- send xp

				if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
					C_ChatInfo.SendAddonMessage(XPPREFIX, message, "INSTANCE_CHAT")
				elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
					C_ChatInfo.SendAddonMessage(XPPREFIX, message, "PARTY")
				end
			end
		end
	end
end
local frameXP = CreateFrame("Frame")
frameXP:RegisterEvent("CHAT_MSG_ADDON")
frameXP:RegisterEvent("PLAYER_ENTERING_WORLD")
frameXP:RegisterEvent("GROUP_ROSTER_UPDATE")
frameXP:RegisterEvent("PLAYER_XP_UPDATE")
frameXP:SetScript("OnEvent", OnEventXP)
