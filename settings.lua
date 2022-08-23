-- By D4KiR

MAIBUILD = "CLASSIC"
if select(4, GetBuildInfo()) > 90000 then
	MAIBUILD = "RETAIL"
elseif select(4, GetBuildInfo()) > 29999 then
	MAIBUILD = "WRATH"
elseif select(4, GetBuildInfo()) > 19999 then
	MAIBUILD = "TBC"
end

MAIHIDDEN = CreateFrame( "FRAME", "MAIHIDDEN", UIParent)
MAIHIDDEN:SetSize(50, 50)
MAIHIDDEN:Hide()

MAILoaded = MAILoaded or false

MAITAB = MAITAB or {}
MAITABPC = MAITABPC or {}

function MAIGetMaxLevel()
	local maxlevel = 60
	if MAIBUILD == "TBC" then
		maxlevel = 70
	end
	if GetMaxLevelForPlayerExpansion ~= nil then
		maxlevel = GetMaxLevelForPlayerExpansion()
	end
	return maxlevel
end

function MAIUnitName(unit)
	if UnitExists(unit) then
		local name, realm = UnitName(unit)
		if realm and realm ~= "" then
			name = name .. "-" .. realm
		else
			name = name .. "-" .. GetRealmName()
		end
		return name
	else
		return "NOT EXISTS"
	end
end

function MAIMathR(num, dec)
	num = num or 0
	dec = dec or 2

	num = tonumber( string.format("%." .. dec .. "f", num) )
	if num == -0 then
		num = 0
	end
	return num
end

function MAIMathC( val, vmin, vmax )
	if val == nil then
		return 0
	end
	if vmin == nil then
		return 0
	end
	if vmax == nil then
		return 1
	end
	if val < vmin then
		return vmin
	elseif val > vmax then
		return vmax
	else
		return val
	end
end

function MAIStringR(num, dec)
	local d = dec
	if dec == nil then
		d = 2
	end
	return string.format("%." .. d .. "f", num)
end

function MAIDottedNumber(num)
	local revnum = tostring(num):reverse()
	local ret = ""
	for i = 0, strlen(revnum), 4 do
		local first = string.sub(revnum, i, i + 3)
		if first ~= nil then
			if i ~= 0 then
				ret = ret .. "."
			end
			ret = ret .. first
		end
	end
	return ret:reverse()
end

function strEmpty( str )
	if type( str ) == "string" then
		if strtrim( str ) == "" then
			return true
		else
			return false
		end
	end
	return true
end

function MAISCP( pname )
	if pname and pname ~= "" and pname ~= " " then
		MAITABPC["CP"] = pname
	end
end

function MAIGCP()
	if MAITABPC["CP"] == nil then
		MAITABPC["CP"] = "DEFAULT"
	end
	return MAITABPC["CP"]
end

function MAICheckConfig()
	MAITAB["PROFILES"] = MAITAB["PROFILES"] or {}
	MAITAB["PROFILES"]["DEFAULT"] = MAITAB["PROFILES"]["DEFAULT"] or {}
end

function MAILoadConfig()
	MAICheckConfig()

	MAIImportProfiles()
end

function MAISV( key, val )
	if MAITAB and MAITAB["PROFILES"] then
		MAICheckConfig()
		if MAITAB["PROFILES"][MAIGCP()] then
			if key ~= nil then
				MAITAB["PROFILES"][MAIGCP()][key] = val
			else
				MAIMSG( "[SetValue] NO KEY", key, val )
			end
		else
			print("[MAI] |cFFFF0000" .. "Characer using a deleted Profile, switched to DEFAULT.")
			MAISCP( "DEFAULT" )
		end
	else
		MAIMSG("[SetValue] TO EARLY:", key, val)
	end
end

function MAIGV( key, value )
	MAICheckConfig()
	if MAITAB["PROFILES"][MAIGCP()] then
		if MAITAB["PROFILES"][MAIGCP()][key] ~= nil then
			return MAITAB["PROFILES"][MAIGCP()][key]
		else
			return value
		end
	else
		print("[MAI] |cFFFF0000" .. "Characer using a deleted Profile, switched to DEFAULT.")
		MAISCP( "DEFAULT" )
	end
	return nil
end

function MAIWaitForUncombat( event )
	if event == "PLAYER_ENTERING_WORLD" or not InCombatLockdown() then
		MAISetup()
		if MAIGV( "ZoomOut" ) == nil then
			if MAIBUILD == "RETAIL" then
				MAISV( "ZoomOut", 2.6 )
			else
				MAISV( "ZoomOut", 4.0 )
			end
		end
		if MAIGV( "WorldTextScale" ) == nil then
			if MAIBUILD == "RETAIL" then
				MAISV( "WorldTextScale", 1.0 )
			else
				MAISV( "WorldTextScale", 1.0 )
			end
		end
		ConsoleExec( "cameraDistanceMaxZoomFactor " .. MAIGV( "ZoomOut" ) )
		ConsoleExec( "WorldTextScale " .. MAIGV( "WorldTextScale" ) )
	else
		C_Timer.After( 0.1, function()
			MAIWaitForUncombat( event )
		end )
	end
end

local loaded = false
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
function f:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" and not loaded then
		loaded = true

		if MAITAB == nil then
			MAITAB = {}
			MAIMSG("NO DATA FOUND, CREATE DATABASE")
		end

		MAILoadConfig()

		MAILoaded = true

		if MAICreateBars then
			MAICreateBars()
		end

		MAIWaitForUncombat(event)
	end
end
f:SetScript("OnEvent", f.OnEvent)

function MAINN(value, short)
	value = tonumber(value) or value
	if value > 999999999 then
		if short then
			return format("%.0f B", value / 1000000000)
		end
		return format("%.1f B", value / 1000000000)
	elseif value > 999999 then
		if short then
			return format("%.0f M", value / 1000000)
		end
		return format("%.1f M", value / 1000000)
	elseif value > 999 then
		if short then
			return format("%.0f K", value / 1000)
		end
		return format("%.1f K", value / 1000)
	else
		return value
	end
end

function MAIImportProfiles()
	local tab = {
		["ExtraActionButton1sizeh"] = 52,
		["MailFrameScale"] = true,
		["FriendsFrameEnabled"] = true,
		["MirrorTimer1hide"] = false,
		["BagBarEnabled"] = true,
		["PetBarcount"] = 10,
		["ActionBar1improvements"] = true,
		["ActionBar2rows"] = 1,
		["SpellBookFrameScale"] = true,
		["GameTooltipalpha"] = 1,
		["ActionBar6alpha"] = 1,
		["MAIStatusBaralpha2"] = 1,
		["MAIMoneyBarhide"] = false,
		["ActionBar9row"] = 0,
		["ActionBar10row"] = 0,
		["ActionBar7alpha2"] = 1,
		["MAIUIColorG"] = 0.15,
		["EncounterJournalEnabled"] = true,
		["MainMenuBarVehicleLeaveButtonimprovements"] = true,
		["GameTooltipofsy"] = 20,
		["UIWidgetTopCenterContainerFrameEnabled"] = true,
		["BagBaralpha"] = 1,
		["ActionBar6count"] = 12,
		["CastingBarFramealpha"] = 1,
		["PlayerPowerBarAltofsx"] = 0,
		["MainMenuBarVehicleLeaveButtonpoint"] = "BOTTOM",
		["TargetFramesizeh"] = 60,
		["StanceBarEnabled"] = true,
		["ActionBar8scale"] = 1,
		["WorldTextScale"] = 2,
		["ActionBar8sizew"] = 60,
		["AlertFrameEnabled"] = true,
		["TargetFramesizew"] = 60,
		["DurabilityFrameimprovements"] = true,
		["UIWidgetBelowMinimapContainerFramescale"] = 1,
		["PetStableFrameEnabled"] = true,
		["MAIMicroButtonsEnabled"] = true,
		["MAIProfilesrelativePoint"] = "CENTER",
		["MAISkillspoint"] = "TOP",
		["TargetFramehide"] = false,
		["MAIBossListpoint"] = "RIGHT",
		["StanceBarhide"] = false,
		["ActionBar3improvements"] = true,
		["ObjectiveTrackerFramealpha2"] = 1,
		["ArenaPrepFramesEnabled"] = false,
		["PetBarpoint"] = "BOTTOM",
		["CLASSES"] = {
			["MAGE"] = {
				{
					{
						1459, -- [1]
						"buff", -- [2]
						[4] = 23028,
						[5] = "buffbetter",
					}, -- [1]
					{
						168, -- [1]
						"buff", -- [2]
					}, -- [2]
					{
						6117, -- [1]
						"buff", -- [2]
					}, -- [3]
				}, -- [1]
				{
					{
						604, -- [1]
						"buffshort", -- [2]
					}, -- [1]
					{
						1008, -- [1]
						"buffshort", -- [2]
					}, -- [2]
				}, -- [2]
				{
					{
						5504, -- [1]
						"food", -- [2]
					}, -- [1]
					{
						587, -- [1]
						"food", -- [2]
					}, -- [2]
					{
						43987, -- [1]
						"food", -- [2]
					}, -- [3]
				}, -- [3]
				{
					{
						543, -- [1]
						"buffempower", -- [2]
						true, -- [3]
					}, -- [1]
					{
						6143, -- [1]
						"buffempower", -- [2]
						true, -- [3]
					}, -- [2]
				}, -- [4]
				{
					{
						1463, -- [1]
						"shield", -- [2]
						true, -- [3]
					}, -- [1]
					{
						11426, -- [1]
						"shield", -- [2]
						true, -- [3]
					}, -- [2]
					{
						30482, -- [1]
						"shield", -- [2]
						true, -- [3]
					}, -- [3]
				}, -- [5]
			},
			["MAGEVERSION"] = 6,
		},
		["ZoneAbilityFramealpha2"] = 1,
		["UIWidgetTopCenterContainerFramesizew"] = 140,
		["MainMenuBarVehicleLeaveButtonsizew"] = 60,
		["TargetFramemove"] = true,
		["InterfaceOptionsFrameEnabled"] = true,
		["AchievementFrameScale"] = true,
		["MAIBuffFrameEnabled"] = true,
		["GroupLootFrame1ofsx"] = -440,
		["ActionBar4ofsx"] = -52,
		["CharacterFrameEnabled"] = true,
		["PlayerChoiceToggleButtonsizeh"] = 60,
		["PlayerFrameshowtotemtimer"] = false,
		["CastingBarFramehideartwork"] = true,
		["MAISkillsofsx"] = -600,
		["MAIMoneyBarsizew"] = 60,
		["minimapbuttonsmove"] = true,
		["UIErrorsFramehideartwork"] = true,
		["UIErrorsFramehide"] = false,
		["ExtraActionButton1move"] = true,
		["ObjectiveTrackerFramealpha"] = 1,
		["GameTooltiphideartwork"] = true,
		["PlayerPowerBarAlthideartwork"] = true,
		["AlertFramerelativePoint"] = "CENTER",
		["PlayerFrameofsx"] = -120,
		["ObjectiveTrackerFrameimprovements"] = true,
		["VehicleSeatIndicatorsizew"] = 60,
		["ActionBar6move"] = true,
		["HelpFrameScale"] = true,
		["UIErrorsFrameEnabled"] = true,
		["PlayerFramehideartwork"] = true,
		["PlayerChoiceToggleButtonhideartwork"] = true,
		["MAIMoneyBarscale"] = 1,
		["ActionBar8improvements"] = true,
		["FPSFramesizew"] = 60,
		["ZoomOut"] = 2.6,
		["WardrobeFrameScale"] = true,
		["ZoneAbilityFramehideartwork"] = true,
		["ZoneAbilityFramescale"] = 1,
		["FocusFrameofsy"] = -240,
		["ContainerFrame4Scale"] = false,
		["ActionBar5alpha2"] = 1,
		["DurabilityFramehide"] = false,
		["TalkingHeadFrameofsx"] = 160,
		["ActionBar4alpha2"] = 1,
		["DurabilityFramescale"] = 1,
		["MAIMicroButtonssizew"] = 60,
		["PlayerFramesizeh"] = 60,
		["FocusFramescale"] = 1,
		["GroupLootFrame1scale"] = 1,
		["ActionBar4hidehk"] = false,
		["MAIBuffFrameimprovements"] = true,
		["StanceBarallclassesplus"] = false,
		["FPSFrameEnabled"] = true,
		["ActionBar1hideartwork"] = true,
		["PartyMemberFrame2Enabled"] = false,
		["MainMenuBarVehicleLeaveButtonalpha2"] = 1,
		["ActionBar10hidehk"] = false,
		["MAIMicroButtonsrelativePoint"] = "BOTTOMRIGHT",
		["ActionBar7relativePoint"] = "BOTTOM",
		["ActionBar7hidehk"] = false,
		["ActionBar4improvements"] = true,
		["MinimaprelativePoint"] = "BOTTOM",
		["ChatFrame1hideartwork"] = true,
		["FPSFramealpha2"] = 1,
		["MAIBossListofsy"] = 30,
		["ActionBar4row"] = 11,
		["DurabilityFramepoint"] = "BOTTOMRIGHT",
		["AddonListEnabled"] = true,
		["VehicleSeatIndicatorrelativePoint"] = "BOTTOM",
		["ActionBar8row"] = 1,
		["MAIMoneyBarpoint"] = "BOTTOMRIGHT",
		["ActionBar6ofsx"] = 0,
		["BankFrameEnabled"] = true,
		["StanceBarimprovements"] = true,
		["ActionBar7sizeh"] = 60,
		["CastingBarFramerelativePoint"] = "CENTER",
		["ActionBar7hide"] = false,
		["MAIBuffFramespacing"] = 2,
		["PetBarrelativePoint"] = "BOTTOM",
		["ChatFrame1move"] = true,
		["DurabilityFrameilvl"] = true,
		["FPSFramehideartwork"] = true,
		["MAISkillsscale"] = 1,
		["StanceBarhideartwork"] = true,
		["MAIUIColorR"] = 0.15,
		["ObjectiveTrackerFramehide"] = false,
		["PetBarofsy"] = 150,
		["ActionBar1count"] = 12,
		["PetStableFrameScale"] = true,
		["ActionBar6hideartwork"] = true,
		["ActionBar7count"] = 12,
		["PetBarimprovements"] = true,
		["ExtraActionButton1scale"] = 1,
		["PVEFrameScale"] = true,
		["StanceBarrows"] = 1,
		["AuctionHouseFrameEnabled"] = true,
		["DurabilityFramesizeh"] = 60,
		["GroupLootFrame1sizew"] = 60,
		["GroupLootFrame1ofsy"] = -10,
		["menu"] = false,
		["PetBarEnabled"] = true,
		["ActionBar9hidena"] = false,
		["ActionBar6hide"] = false,
		["FocusFramealpha2"] = 1,
		["Minimappoint"] = "BOTTOM",
		["ObjectiveTrackerFrameofsy"] = -40,
		["ActionBar3hidena"] = false,
		["MAIMicroButtonsscale"] = 1,
		["ActionBar8count"] = 12,
		["ActionBar3point"] = "RIGHT",
		["FocusFrameSpellBarEnabled"] = false,
		["PetStableFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["PetBarhidehk"] = false,
		["MAIBuffFramehide"] = false,
		["BagBaralpha2"] = 1,
		["ActionBar7scale"] = 1,
		["ActionBar1rows"] = 1,
		["ActionBar1ofsy"] = 0,
		["ActionBar2count"] = 12,
		["MainMenuBarVehicleLeaveButtonEnabled"] = true,
		["ExtraActionButton1improvements"] = true,
		["ActionBar4scale"] = 1,
		["PlayerPowerBarAltEnabled"] = true,
		["MAIMicroButtonsmove"] = true,
		["MAIMENUofsx"] = -413,
		["ActionBar3row"] = 11,
		["ActionBar7point"] = "BOTTOM",
		["MAIBossListEnabled"] = true,
		["BagBarscale"] = 1,
		["GVimprovements"] = true,
		["ActionBar1point"] = "BOTTOM",
		["ActionBar7improvements"] = true,
		["PlayerFramescale"] = 1,
		["MainMenuBarVehicleLeaveButtonmove"] = true,
		["AlertFramealpha2"] = 1,
		["ActionBar5alpha"] = 1,
		["MAIMoneyBaralpha"] = 1,
		["Minimapofsx"] = -220,
		["ActionBar6spacing"] = 8,
		["UIWidgetTopCenterContainerFramepoint"] = "TOP",
		["snaptogrid"] = true,
		["ChatFrame1relativePoint"] = "BOTTOMLEFT",
		["scaleframes"] = false,
		["PlayerFramepoint"] = "BOTTOM",
		["ActionBar5hide"] = false,
		["MAIMicroButtonssizeh"] = 60,
		["GameTooltipEnabled"] = true,
		["AlertFrameofsy"] = -80,
		["ActionBar8move"] = true,
		["ActionBar1hide"] = false,
		["MAIBuffFramealpha"] = 1,
		["nochanges"] = false,
		["PingFrameEnabled"] = true,
		["FPSFramemove"] = true,
		["StanceBarrow"] = 0,
		["PlayerPowerBarAltsizew"] = 40,
		["QuestFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["DurabilityFramealpha"] = 1,
		["CharacterFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["ActionBar1ofsx"] = 0,
		["PlayerChoiceToggleButtonofsx"] = -440,
		["GameTooltipalpha2"] = 1,
		["TalkingHeadFramehideartwork"] = true,
		["StanceBarrelativePoint"] = "BOTTOM",
		["FPSFramesizeh"] = 60,
		["BagBarhide"] = false,
		["ActionBar8spacing"] = 8,
		["MAIStatusBarrelativePoint"] = "TOP",
		["MainMenuBarVehicleLeaveButtonsizeh"] = 60,
		["MAISkillsmove"] = true,
		["GameTooltipimprovements"] = true,
		["QuestLogFrameEnabled"] = true,
		["minimapbuttonsrelativePoint"] = "TOPLEFT",
		["ActionBar7hidena"] = false,
		["FocusFramemove"] = true,
		["ActionBar4spacing"] = 8,
		["ActionBar1hidehk"] = false,
		["CommunitiesFrameEnabled"] = true,
		["ActionBar1alpha"] = 1,
		["DurabilityFrameofsx"] = -70,
		["MAIBossListsizeh"] = 60,
		["TemporaryEnchantFrameEnabled"] = false,
		["ContainerFrame1Scale"] = false,
		["AlertFramepoint"] = "CENTER",
		["MAIBuffFramesizeh"] = 60,
		["ActionBar1hidena"] = false,
		["ActionBar6sizeh"] = 60,
		["ActionBar4point"] = "RIGHT",
		["BagBarrelativePoint"] = "BOTTOMRIGHT",
		["ActionBar1Enabled"] = true,
		["MAIMicroButtonsspacing"] = -4,
		["DurabilityFrameEnabled"] = true,
		["ExtraActionButton1point"] = "CENTER",
		["PetBarspacing"] = 4,
		["Minimapform"] = "paper2",
		["PlayerFramegroupindicator"] = true,
		["GarrisonLandingPageEnabled"] = true,
		["ActionBar5sizeh"] = 60,
		["ActionBar1alpha2"] = 1,
		["VehicleSeatIndicatorhide"] = false,
		["TalkingHeadFramehide"] = true,
		["CovenantSanctumFrameEnabled"] = true,
		["FocusFramesizew"] = 60,
		["Minimaphideminimapbuttons"] = true,
		["EncounterJournalScale"] = true,
		["AuctionHouseFrameScale"] = true,
		["ChatFrame1ofsx"] = 0,
		["DurabilityFramehideartwork"] = true,
		["ActionBar8hidehk"] = false,
		["ActionBar2row"] = 0,
		["MAIMicroButtonsalpha"] = 1,
		["CommunitiesFrameScale"] = true,
		["ActionBar5row"] = 1,
		["KeyBindingFrameScale"] = true,
		["GossipFrameEnabled"] = true,
		["TargetFramescale"] = 1,
		["ActionBar3scale"] = 1,
		["MAIBuffFramerelativePoint"] = "TOPRIGHT",
		["GroupLootFrame1alpha"] = 1,
		["MAIMicroButtonsrow"] = 0,
		["ActionBar7sizew"] = 60,
		["minimapbuttonspoint"] = "TOPLEFT",
		["FPSFramescale"] = 1,
		["TalkingHeadFrameimprovements"] = true,
		["GroupLootFrame1Enabled"] = true,
		["AnimaDiversionFrameScale"] = true,
		["ActionBar5count"] = 12,
		["MAIStatusBarofsx"] = 0,
		["LFGParentFrameEnabled"] = true,
		["ActionBar3sizew"] = 60,
		["FPSFramepoint"] = "TOPLEFT",
		["GVEnabled"] = true,
		["ObjectiveTrackerFramesizeh"] = 600,
		["MirrorTimer1sizeh"] = 26,
		["ActionBar5move"] = true,
		["ActionBar4move"] = true,
		["MainMenuBarVehicleLeaveButtonalpha"] = 1,
		["TargetFrameofsy"] = 190,
		["Minimapsizeh"] = 60,
		["Minimapmove"] = true,
		["PlayerFrameEnabled"] = true,
		["CastingBarFramesizeh"] = 60,
		["MAIMicroButtonshide"] = false,
		["GVofsx"] = 40,
		["GVhide"] = false,
		["PlayerChoiceToggleButtonofsy"] = 120,
		["GroupLootFrame1relativePoint"] = "CENTER",
		["MAIMoneyBarofsx"] = 0,
		["PlayerChoiceToggleButtonsizew"] = 60,
		["SpellBookFrameEnabled"] = true,
		["FocusFramehideartwork"] = true,
		["ContainerFrame2Scale"] = false,
		["MAISkillsofsy"] = 0,
		["FocusFrameofsx"] = 410,
		["ActionBar1sizew"] = 60,
		["ActionBar5rows"] = 2,
		["InterfaceOptionsFrameScale"] = true,
		["UnitFramesEnabled"] = true,
		["ActionBar4hide"] = false,
		["ActionBar8hidena"] = false,
		["ActionBar9Enabled"] = false,
		["MAIBuffFramealpha2"] = 1,
		["ActionBar3alpha2"] = 1,
		["MAIStatusBarsizew"] = 60,
		["XPTAB"] = {
			["NOT EXISTS"] = {
				["useapi"] = false,
			},
		},
		["WorldMapFrameScale"] = true,
		["GVsizew"] = 60,
		["FocusFrameimprovements"] = true,
		["VehicleSeatIndicatoralpha2"] = 1,
		["QuestLogFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["VehicleSeatIndicatorofsx"] = 360,
		["PetBarscale"] = 1,
		["GValpha2"] = 1,
		["VehicleSeatIndicatorofsy"] = 100,
		["TradeSkillFrameEnabled"] = true,
		["MAIMENUrelativePoint"] = "TOP",
		["GameMenuFrameEnabled"] = true,
		["MAIBossListhide"] = false,
		["MirrorTimer1relativePoint"] = "TOP",
		["TargetFramerelativePoint"] = "BOTTOM",
		["MAIBossListscale"] = 1,
		["PlayerPowerBarAltpoint"] = "TOP",
		["ActionBar6hidena"] = false,
		["BagBarofsx"] = 0,
		["MerchantFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["ActionBar8hide"] = false,
		["GameTooltiphide"] = false,
		["CastingBarFramepoint"] = "CENTER",
		["TargetFramehideartwork"] = true,
		["ExtraActionButton1sizew"] = 52,
		["MerchantFrameEnabled"] = true,
		["PlayerFrameofsy"] = 190,
		["ActionBar10spacing"] = 8,
		["MAIStatusBarscale"] = 1,
		["MAISkillshideartwork"] = true,
		["GVofsy"] = -40,
		["ActionBar9rows"] = 1,
		["ContainerFrame1Enabled"] = false,
		["MAIStatusBarsizeh"] = 60,
		["GameTooltipscale"] = 1,
		["MAISkillsalpha2"] = 1,
		["SoulbindViewerScale"] = true,
		["MAISkillsalpha"] = 1,
		["hideunmoved"] = true,
		["GroupLootFrame1sizeh"] = 60,
		["TargetFrameSpellBarEnabled"] = false,
		["PetBarsizew"] = 60,
		["MAIStatusBarshowonlywhenhovered"] = false,
		["ActionBar2Enabled"] = false,
		["UIWidgetBelowMinimapContainerFramepoint"] = "TOP",
		["MAIMicroButtonsofsx"] = 0,
		["LFGParentFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["PartyMemberFrame4Enabled"] = false,
		["UIWidgetTopCenterContainerFramehideartwork"] = true,
		["GarrisonLandingPageScale"] = true,
		["BagBarsizeh"] = 60,
		["MAIMENUMOVING.WorldTextScaleMAIWorldTextScale"] = 2,
		["FocusFrameEnabled"] = true,
		["ActionBar6alpha2"] = 1,
		["BankFrameScale"] = true,
		["PlayerPowerBarAltimprovements"] = true,
		["TargetFrameimprovements"] = true,
		["MAIMENUMOVINGofsy"] = 64,
		["Minimapalpha2"] = 1,
		["HelpFrameEnabled"] = true,
		["ClassTrainerFrameEnabled"] = true,
		["MerchantFrameScale"] = true,
		["VehicleSeatIndicatorhideartwork"] = true,
		["MAIMicroButtonshideartwork"] = true,
		["MAISkillshide"] = false,
		["WeeklyRewardsFrameEnabled"] = true,
		["GroupLootFrame1hide"] = false,
		["CharacterFrameScale"] = true,
		["CastingBarFramemove"] = true,
		["ContainerFrame5Enabled"] = false,
		["FPSFrameofsx"] = 0,
		["ActionBar6relativePoint"] = "BOTTOM",
		["Minimaprange"] = true,
		["PingFramealpha"] = 1,
		["WardrobeFrameEnabled"] = true,
		["ActionBar4alpha"] = 1,
		["MainMenuBarVehicleLeaveButtonofsy"] = 120,
		["MAIProfilesofsy"] = 178,
		["GameTooltipsizeh"] = 60,
		["ObjectiveTrackerFramepoint"] = "RIGHT",
		["ArenaEnemyFramesEnabled"] = false,
		["PingFramerelativePoint"] = "TOPLEFT",
		["VehicleSeatIndicatoralpha"] = 1,
		["BagBarofsy"] = 36,
		["ActionBar2hidena"] = false,
		["InterfaceOptionsFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["MAIStatusBarautoselectfaction"] = true,
		["ActionBar7alpha"] = 1,
		["AddonListScale"] = true,
		["ObjectiveTrackerFramerelativePoint"] = "RIGHT",
		["ActionBar5scale"] = 1,
		["MAIMENUMOVINGpoint"] = "CENTER",
		["MAIBuffFramemove"] = true,
		["UIWidgetTopCenterContainerFramescale"] = 1,
		["ActionBar5spacing"] = 8,
		["MAIDebuffFrameEnabled"] = false,
		["ActionBar10count"] = 12,
		["TradeSkillFrameScale"] = true,
		["DurabilityFramesizew"] = 60,
		["minimapbuttonshideartwork"] = true,
		["ZoneAbilityFramerelativePoint"] = "CENTER",
		["ActionBar5point"] = "BOTTOM",
		["UnitFramesAdvancedEnabled"] = false,
		["KeyBindingFrameEnabled"] = true,
		["ActionBar3rows"] = 12,
		["ActionBar8Enabled"] = true,
		["HelpFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["Minimaphide"] = false,
		["maismartfilter"] = true,
		["PingFramescale"] = 1,
		["ActionBar8point"] = "BOTTOM",
		["MAIBuffFramesizew"] = 60,
		["StanceBarsizeh"] = 60,
		["MirrorTimer1sizew"] = 206,
		["MAIMoneyBarEnabled"] = true,
		["ZoneAbilityFramealpha"] = 1,
		["PVPMatchScoreboardparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["LFGParentFrameScale"] = true,
		["ChatFrame1ofsy"] = 0,
		["PlayerPowerBarAltrelativePoint"] = "TOP",
		["GVpoint"] = "LEFT",
		["PlayerFramemove"] = true,
		["AlertFramescale"] = 1,
		["StanceBarcount"] = 10,
		["UIWidgetBelowMinimapContainerFrameofsx"] = 170,
		["MAISkillsrelativePoint"] = "TOP",
		["Minimapimprovements"] = true,
		["UIWidgetBelowMinimapContainerFramemove"] = true,
		["AnimaDiversionFrameEnabled"] = true,
		["GVscale"] = 1,
		["UIWidgetBelowMinimapContainerFramerelativePoint"] = "TOP",
		["PlayerPowerBarAltscale"] = 1,
		["PlayerPowerBarAltsizeh"] = 40,
		["UIWidgetBelowMinimapContainerFrameofsy"] = -60,
		["UIErrorsFrameimprovements"] = true,
		["ActionBar3hide"] = false,
		["ExtraActionButton1alpha2"] = 1,
		["TalkingHeadFrameofsy"] = 40,
		["FocusFramehide"] = false,
		["ZoneAbilityFramesizew"] = 256,
		["TalkingHeadFramemove"] = true,
		["PVEFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["FocusFramesizeh"] = 60,
		["ActionBar4sizeh"] = 60,
		["ExtraActionButton1Enabled"] = true,
		["BankFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["UIWidgetTopCenterContainerFrameofsx"] = 0,
		["Minimapminimapbuttons"] = true,
		["ActionBar4ofsy"] = 0,
		["ClassTrainerFrameScale"] = true,
		["ActionBar8ofsx"] = -430,
		["BagBarimprovements"] = true,
		["PartyMemberFrame1Enabled"] = false,
		["MAIMicroButtonsofsy"] = 0,
		["UIErrorsFramemove"] = true,
		["ZoneAbilityFrameofsx"] = 540,
		["MAIBuffFramepoint"] = "TOPRIGHT",
		["PVEFrameEnabled"] = true,
		["ActionBar1relativePoint"] = "BOTTOM",
		["PlayerPowerBarAltmove"] = true,
		["StanceBarmove"] = true,
		["UIWidgetTopCenterContainerFrameimprovements"] = true,
		["CastingBarFramescale"] = 1,
		["UIWidgetBelowMinimapContainerFramesizeh"] = 60,
		["ActionBar7ofsx"] = 0,
		["MAIProfilespoint"] = "CENTER",
		["ActionBar8relativePoint"] = "BOTTOM",
		["PetBarmove"] = true,
		["ActionBar5hidena"] = false,
		["MAISkillssizew"] = 60,
		["MirrorTimer1ofsx"] = 0,
		["ActionBar5ofsx"] = 430,
		["ActionBar6ofsy"] = 40,
		["ActionBar3hidehk"] = false,
		["ActionBar4count"] = 12,
		["ContainerFrame2Enabled"] = false,
		["ActionBar9spacing"] = 8,
		["QuestFrameEnabled"] = true,
		["PetBarhideartwork"] = true,
		["AddonListparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["FocusFramepoint"] = "CENTER",
		["MAIMoneyBarrelativePoint"] = "BOTTOMRIGHT",
		["Minimaphideartwork"] = true,
		["AlertFramehideartwork"] = true,
		["MAIBuffFrameaccuratetime"] = true,
		["PlayerChoiceToggleButtonpoint"] = "CENTER",
		["GameTooltipshowcountryflag"] = true,
		["ActionBar6scale"] = 1,
		["ZoneAbilityFramesizeh"] = 128,
		["ExtraActionButton1hideartwork"] = true,
		["minimapbuttonsscale"] = 1,
		["TalkingHeadFramealpha"] = 1,
		["MirrorTimer1alpha2"] = 1,
		["PlayerChoiceToggleButtonalpha"] = 1,
		["PlayerPowerBarAlthide"] = false,
		["minimapbuttonsEnabled"] = true,
		["MinimapEnabled"] = true,
		["DressUpFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["UIWidgetBelowMinimapContainerFramealpha"] = 1,
		["ActionBar1move"] = true,
		["PaperDollFrameshowilvl"] = true,
		["StanceBarsizew"] = 60,
		["DressUpFrameScale"] = true,
		["MAIStatusBarofsy"] = 0,
		["toggler"] = false,
		["PingFramemove"] = true,
		["PingFramesizeh"] = 60,
		["TargetFrameofsx"] = 120,
		["ActionBar2spacing"] = 8,
		["ActionBar3ofsy"] = 0,
		["MAIStatusBarpoint"] = "TOP",
		["MAIBossListrelativePoint"] = "RIGHT",
		["ActionBar1row"] = 0,
		["StanceBarpoint"] = "BOTTOM",
		["MAIMicroButtonscount"] = 9,
		["CastingBarFrameEnabled"] = true,
		["StanceBaralpha"] = 1,
		["MAIBossListhideartwork"] = true,
		["MAIMoneyBaralpha2"] = 1,
		["MAIStatusBarimprovements"] = true,
		["VehicleSeatIndicatorsizeh"] = 60,
		["moveframes"] = true,
		["blockwords"] = "BOOST,BUY GOLD",
		["MAIBossListmove"] = true,
		["TalkingHeadFramealpha2"] = 1,
		["PetBarrow"] = 0,
		["MAIBuffFrameofsy"] = -4,
		["MAIMENUMOVINGofsx"] = 65,
		["MAIMicroButtonsrows"] = 1,
		["ChallengesKeystoneFrameEnabled"] = true,
		["StanceBarofsy"] = 120,
		["GroupLootFrame1alpha2"] = 1,
		["PlayerChoiceToggleButtonimprovements"] = true,
		["ActionBar3Enabled"] = true,
		["CovenantMissionFrameEnabled"] = true,
		["UIErrorsFrameofsy"] = -170,
		["ActionBar1sizeh"] = 60,
		["ChatFrame1point"] = "BOTTOMLEFT",
		["LootFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["CastingBarFramesizew"] = 60,
		["VehicleSeatIndicatorimprovements"] = true,
		["InterfaceEnabled"] = true,
		["ChatFrame1improvements"] = true,
		["ChatFrame1Enabled"] = true,
		["ActionBar3relativePoint"] = "RIGHT",
		["ActionBar4relativePoint"] = "RIGHT",
		["ActionBar4Enabled"] = true,
		["MAIMENUMOVINGrelativePoint"] = "CENTER",
		["GameTooltipmove"] = true,
		["GossipFrameScale"] = true,
		["ActionBar8sizeh"] = 60,
		["MAIBuffFramehideartwork"] = true,
		["TargetFramealpha"] = 1,
		["MailFrameEnabled"] = true,
		["PlayerChoiceToggleButtonscale"] = 1,
		["MAIStatusBarhideartwork"] = true,
		["LootFrameScale"] = true,
		["MAIBuffFramescale"] = 1,
		["MAIMicroButtonsalpha2"] = 1,
		["ActionBar3count"] = 12,
		["PetBarsizeh"] = 60,
		["PingFramehideartwork"] = true,
		["PVPMatchScoreboardEnabled"] = true,
		["ObjectiveTrackerFramehideartwork"] = true,
		["MAIStatusBarwidth"] = 1000,
		["PingFrameofsx"] = 0,
		["ExtraActionButton1ofsy"] = -80,
		["ActionBar8alpha2"] = 1,
		["BagBarhideartwork"] = true,
		["GameTooltiprelativePoint"] = "BOTTOMRIGHT",
		["MAIStatusBarhide"] = false,
		["UIWidgetBelowMinimapContainerFramehideartwork"] = true,
		["ActionBar6improvements"] = true,
		["PetBarhidena"] = false,
		["ActionBar6Enabled"] = true,
		["PlayerFrameimprovements"] = true,
		["MirrorTimer1point"] = "TOP",
		["PlayerTalentFrameScale"] = true,
		["MAIBossListsizew"] = 60,
		["MAIProfilesofsx"] = -58,
		["TalkingHeadFramescale"] = 1,
		["UIWidgetTopCenterContainerFramealpha2"] = 1,
		["WeeklyRewardsFrameScale"] = true,
		["TalkingHeadFrameEnabled"] = true,
		["GameMenuFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["MirrorTimer1move"] = true,
		["FocusFramealpha"] = 1,
		["CastingBarFrameofsy"] = -190,
		["TalkingHeadFramesizew"] = 570,
		["VehicleSeatIndicatormove"] = true,
		["Minimapalpha"] = 1,
		["UIErrorsFramesizew"] = 60,
		["PetBaralpha"] = 1,
		["FriendsFrameScale"] = true,
		["PetFrameEnabled"] = false,
		["AlertFramehide"] = false,
		["ActionBar4hideartwork"] = true,
		["TargetFramealpha2"] = 1,
		["UIWidgetTopCenterContainerFramesizeh"] = 60,
		["MAIMENUMOVING.rMAIUIColorR"] = 0.15,
		["ExtraActionButton1relativePoint"] = "CENTER",
		["BagBarmove"] = true,
		["ChatFrame1hide"] = false,
		["MainMenuBarVehicleLeaveButtonhideartwork"] = true,
		["ZoneAbilityFrameofsy"] = 30,
		["PetBarofsx"] = 0,
		["hidehidden"] = true,
		["ActionBar5sizew"] = 60,
		["MAIBossListimprovements"] = true,
		["TalkingHeadFramesizeh"] = 155,
		["GroupLootFrame1point"] = "CENTER",
		["PlayerTalentFrameEnabled"] = true,
		["PlayerChoiceToggleButtonrelativePoint"] = "CENTER",
		["TargetFrameToTEnabled"] = false,
		["FriendsFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["VehicleSeatIndicatorpoint"] = "BOTTOM",
		["MAIMENUpoint"] = "TOP",
		["PetBarhide"] = false,
		["MirrorTimer1improvements"] = true,
		["FPSFramehide"] = false,
		["ActionBar10hidena"] = false,
		["ActionBar3alpha"] = 1,
		["VehicleSeatIndicatorEnabled"] = true,
		["UIErrorsFrameofsx"] = 0,
		["ActionBar1scale"] = 1,
		["PVPMatchScoreboardScale"] = true,
		["ChatFrame1scale"] = 1,
		["MAIStatusBarmove"] = true,
		["MAIUIColorB"] = 0.15,
		["ObjectiveTrackerFrameEnabled"] = true,
		["ActionBar2hidehk"] = false,
		["AlertFramealpha"] = 1,
		["VideoOptionsFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["ZoneAbilityFrameimprovements"] = true,
		["ObjectiveTrackerFrameofsx"] = -120,
		["MAIMicroButtonspoint"] = "BOTTOMRIGHT",
		["ActionBar5Enabled"] = true,
		["AchievementFrameEnabled"] = true,
		["ExtraActionButton1ofsx"] = 540,
		["ContainerFrame3Scale"] = false,
		["ActionBar8rows"] = 2,
		["minimapbuttonsalpha2"] = 1,
		["Minimapsizew"] = 60,
		["minimapbuttonsimprovements"] = true,
		["PlayerChoiceToggleButtonEnabled"] = true,
		["MAIBossListofsx"] = -410,
		["UIErrorsFramealpha"] = 1,
		["MainMenuBarVehicleLeaveButtonofsx"] = -240,
		["PingFramepoint"] = "TOPLEFT",
		["ActionBar4hidena"] = false,
		["ActionBar6hidehk"] = false,
		["StanceBarhidehk"] = false,
		["UIWidgetTopCenterContainerFramemove"] = true,
		["TalkingHeadFramepoint"] = "LEFT",
		["PlayerFramealpha"] = 1,
		["PlayerPowerBarAltalpha"] = 1,
		["ObjectiveTrackerFramesizew"] = 235,
		["minimapbuttonssizeh"] = 60,
		["AlertFramesizew"] = 60,
		["DressUpFrameEnabled"] = true,
		["AlertFrameofsx"] = -440,
		["MirrorTimer1alpha"] = 1,
		["GVsizeh"] = 60,
		["StanceBarallclasses"] = true,
		["CastingBarFramealpha2"] = 1,
		["minimapbuttonsofsx"] = 180,
		["minimapbuttonshide"] = false,
		["StanceBarhidena"] = false,
		["CastingBarFrameofsx"] = 0,
		["ActionBar7rows"] = 1,
		["ActionBar3sizeh"] = 60,
		["FocusFramerelativePoint"] = "CENTER",
		["ActionBar8ofsy"] = 0,
		["ActionBar5hideartwork"] = true,
		["ActionBar6row"] = 0,
		["Minimapscale"] = 2,
		["ObjectiveTrackerFramemove"] = true,
		["AlertFramesizeh"] = 60,
		["PlayerFramesizew"] = 60,
		["ZoneAbilityFrameEnabled"] = true,
		["DurabilityFramemove"] = true,
		["PingFrameimprovements"] = true,
		["MainMenuBarVehicleLeaveButtonrelativePoint"] = "BOTTOM",
		["UIWidgetBelowMinimapContainerFrameEnabled"] = true,
		["minimapbuttonssizew"] = 180,
		["CovenantSanctumFrameScale"] = true,
		["ActionBarsEnabled"] = true,
		["FPSFrameofsy"] = 0,
		["GroupLootFrame1move"] = true,
		["ActionBar3move"] = true,
		["ChatFrame1alpha2"] = 1,
		["QuickKeybindFrameEnabled"] = true,
		["GValpha"] = 1,
		["PlayerFramehide"] = false,
		["VehicleSeatIndicatorscale"] = 1,
		["ContainerFrame5Scale"] = false,
		["BagBarpoint"] = "BOTTOMRIGHT",
		["minimapbuttonsalpha"] = 1,
		["MAIBossListalpha2"] = 1,
		["ActionBar3ofsx"] = -8,
		["VideoOptionsFrameScale"] = true,
		["PetBarrows"] = 1,
		["ExtraActionButton1alpha"] = 1,
		["UIWidgetBelowMinimapContainerFramehide"] = false,
		["MAIStatusBarEnabled"] = true,
		["DurabilityFramegold"] = true,
		["StanceBaralpha2"] = 1,
		["ActionBar7ofsy"] = 80,
		["MirrorTimer1ofsy"] = -130,
		["GameTooltipsizew"] = 60,
		["MAISkillssizeh"] = 60,
		["mmicon"] = {
			["hide"] = false,
		},
		["UIErrorsFramerelativePoint"] = "TOP",
		["GameMenuFrameScale"] = true,
		["GVmove"] = true,
		["MAIBuffFrameofsx"] = -4,
		["MirrorTimer1scale"] = 1,
		["UIWidgetBelowMinimapContainerFrameimprovements"] = true,
		["FPSFramerelativePoint"] = "TOPLEFT",
		["ActionBar7hideartwork"] = true,
		["MAIBossListalpha"] = 1,
		["ChallengesKeystoneFrameScale"] = true,
		["ActionBar3spacing"] = 8,
		["PingFramehide"] = false,
		["GroupLootFrame1hideartwork"] = true,
		["MAIMENUMOVING.bMAIUIColorB"] = 0.15,
		["ActionBar7move"] = true,
		["PlayerFramerelativePoint"] = "BOTTOM",
		["ChatFrame1sizew"] = 60,
		["PlayerChoiceToggleButtonalpha2"] = 1,
		["AlertFramemove"] = true,
		["AlertFrameimprovements"] = true,
		["CastingBarFrameimprovements"] = true,
		["ActionBar7spacing"] = 8,
		["ExtraActionButton1hide"] = false,
		["ActionBar6point"] = "BOTTOM",
		["MAIStatusBaralpha"] = 1,
		["PingFramesizew"] = 60,
		["PetBaralpha2"] = 1,
		["UIWidgetTopCenterContainerFrameofsy"] = -60,
		["TargetFrameEnabled"] = true,
		["InterfaceAdvancedEnabled"] = true,
		["StanceBarscale"] = 1,
		["ZoneAbilityFramehide"] = false,
		["MAISkillsimprovements"] = true,
		["ActionBar5improvements"] = true,
		["ActionBar9count"] = 12,
		["GameTooltippoint"] = "BOTTOMRIGHT",
		["Minimapofsy"] = 50,
		["ContainerFrame4Enabled"] = false,
		["ActionBar4rows"] = 12,
		["ContainerFrame3Enabled"] = false,
		["SoulbindViewerEnabled"] = true,
		["SpellBookFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["FPSFrameimprovements"] = true,
		["MainMenuBarVehicleLeaveButtonhide"] = false,
		["StanceBarofsx"] = 0,
		["UIWidgetBelowMinimapContainerFramealpha2"] = 1,
		["ActionBar3hideartwork"] = true,
		["GameTooltiponcursor"] = true,
		["PlayerChoiceToggleButtonhide"] = false,
		["PingFrameofsy"] = -20,
		["ActionBar7Enabled"] = true,
		["PingFramealpha2"] = 1,
		["ChatFrame1sizeh"] = 60,
		["UIWidgetTopCenterContainerFramealpha"] = 1,
		["ChatFrame1alpha"] = 1,
		["GroupLootFrame1improvements"] = true,
		["ActionBar7row"] = 0,
		["VideoOptionsFrameEnabled"] = true,
		["PlayerPowerBarAltalpha2"] = 1,
		["MirrorTimer1Enabled"] = true,
		["ActionBar6sizew"] = 60,
		["TargetFramepoint"] = "BOTTOM",
		["CovenantMissionFrameScale"] = true,
		["LootFrameEnabled"] = true,
		["MAIMoneyBarmove"] = true,
		["PlayerFramealpha2"] = 1,
		["CastingBarFramehide"] = false,
		["MAIMoneyBarofsy"] = 90,
		["PlayerPowerBarAltofsy"] = -250,
		["UIErrorsFramealpha2"] = 1,
		["ActionBar5ofsy"] = 0,
		["FPSFramealpha"] = 1,
		["ActionBar8hideartwork"] = true,
		["ZoneAbilityFramepoint"] = "CENTER",
		["WorldMapFrameEnabled"] = true,
		["StanceBarspacing"] = 4,
		["UIWidgetTopCenterContainerFramerelativePoint"] = "TOP",
		["ActionBar1spacing"] = 8,
		["PartyMemberFrame3Enabled"] = false,
		["DurabilityFramerelativePoint"] = "BOTTOMRIGHT",
		["UIErrorsFramesizeh"] = 60,
		["GameTooltipofsx"] = -330,
		["GVrelativePoint"] = "LEFT",
		["DurabilityFrameofsy"] = 140,
		["GVhideartwork"] = true,
		["ActionBar5relativePoint"] = "BOTTOM",
		["UIErrorsFramescale"] = 1,
		["ActionBar10rows"] = 1,
		["GossipFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["MirrorTimer1hideartwork"] = true,
		["MAIMicroButtonsimprovements"] = true,
		["QuestLogFrameScale"] = true,
		["MAIMENUofsy"] = -182,
		["DurabilityFramealpha2"] = 1,
		["MacroFrameEnabled"] = true,
		["UIErrorsFramepoint"] = "TOP",
		["BagBarsizew"] = 60,
		["PlayerChoiceToggleButtonmove"] = true,
		["MacroFrameScale"] = true,
		["TalkingHeadFramerelativePoint"] = "LEFT",
		["MAIMoneyBarsizeh"] = 60,
		["repindex"] = 0,
		["MAIMoneyBarhideartwork"] = true,
		["ActionBar5hidehk"] = false,
		["ObjectiveTrackerFramescale"] = 1,
		["minimapbuttonsofsy"] = 0,
		["ZoneAbilityFramemove"] = true,
		["ActionBar8alpha"] = 1,
		["MainMenuBarVehicleLeaveButtonscale"] = 1,
		["ActionBar6rows"] = 1,
		["QuickKeybindFrameScale"] = true,
		["MAIStatusBarheight"] = 50,
		["UIWidgetBelowMinimapContainerFramesizew"] = 140,
		["QuestFrameScale"] = true,
		["ActionBar4sizew"] = 60,
		["WorldMapFrameparent"] = {
			["variablesLoaded"] = true,
			["firstTimeLoaded"] = 1,
		},
		["MAIMENUMOVING.gMAIUIColorG"] = 0.15,
		["MAIMoneyBarimprovements"] = true,
		["ActionBar9hidehk"] = false,
		["UIWidgetTopCenterContainerFramehide"] = false,
		["MAISkillsEnabled"] = true,
		["Version"] = 1
	}
	if MAITAB["PROFILES"]["D4KiRsUi"] == nil or ( MAITAB["PROFILES"]["D4KiRsUi"]["Version"] and MAITAB["PROFILES"]["D4KiRsUi"]["Version"] < 1 ) then
		MAITAB["PROFILES"]["D4KiRsUi"] = tab
	end
end



function MAICreateDropdown( opts )
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local dropdown_width = 120
    local default_val = opts['defaultVal'] or ''
    local change_func = opts['changeFunc'] or function (dropdown_val) end

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
        dd_title:SetText(item)
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
end
