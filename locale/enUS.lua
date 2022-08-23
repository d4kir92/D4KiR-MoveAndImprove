-- enUS English

LANG_MAI = LANG_MAI or {}

local engcount = 0
function MAITableToChat( tab )
	local categoryOrder = { }
	for k, v in pairs( tab ) do
		if tab[string.lower(k)] == nil then
			tab[string.lower(k)] = v
			tab[k] = nil
		end
		tinsert( categoryOrder, string.lower(k) )
	end
	table.sort(categoryOrder)
	local newtab = {}
	for i, v in pairs( categoryOrder ) do
		newtab[i] = {
			["key"] = v,
			["value"] = tab[v],
		}
	end

	local count = 0
	for i, v in pairs( newtab ) do
		count = count + 1
		print("[\"" .. v.key .. "\"] = \"" .. tostring( v.value ) .. "\",")
	end
	print( "Size: " .. count .. "/" .. engcount )
end

function MAIUpdateLanguageTab( tab )
	for i, v in pairs( tab ) do
		LANG_MAI[i] = v
	end
end

function MAILang_enUS()
	local tab = {
		["actionbar"] = "Action Bar",
		["actionbars"] = "Action Bars",
		["add"] = "Add",
		["addprofile"] = "Add Profile",
		["alerts"] = "Alerts",
		["all"] = "All",
		["animapowers"] = "Anima Powers",
		["archeologydigsiteprogressbar"] = "Archeology Digsite Progress Bar",
		["autoselectfaction"] = "Auto Select Faction",
		["bar"] = "Bar",
		["battlefieldmap"] = "Battlefield map",
		["blockwords"] = "Blockwords",
		["bossframe"] = "Boss Frame",
		["buffframe"] = "Buff Frame",
		["castingbar"] = "Casting Bar",
		["chatclassicons"] = "Chat Class Icons",
		["chatitemicons"] = "Chat Item Icons",
		["chatraceicons"] = "Chat Race Icons",
		["chatshortchannels"] = "Chat Short Channels",
		["count"] = "Quantity",
		["cry"] = "Cry",
		["current"] = "Current",
		["debuffframe"] = "Debuff Frame",
		["draghelp"] = "If you want to drag it, use SHIFT + left click",
		["elements"] = "Elements",
		["elementscolor"] = "Elements Color",
		["extraaction"] = "Extra Action",
		["focusframe"] = "Focus Frame",
		["frame"] = "frame",
		["frames"] = "frames",
		["framescolor"] = "Frames color",
		["frametransparency"] = "Frame Transparency",
		["grouplootframe1"] = "Group Loot Frame",
		["gryphonleft"] = "Gryphon (Left)",
		["gryphonright"] = "Gryphon (Right)",
		["hidden"] = "Hidden",
		["hideartwork"] = "Hide Artwork",
		["ilevel"] = "Item Level",
		["ilvl"] = "Item Level",
		["improvements"] = "Improvements",
		["incombat"] = "In Combat",
		["inheritfrom"] = "Inherit From",
		["invehicle"] = "In Vehicle",
		["invisible"] = "Invisible",
		["lock"] = "Lock",
		["locked"] = "Locked",
		["maimoneybar"] = "Money Bar",
		["micromenu"] = "Micro Menu",
		["minimapbuttons"] = "Minimap Buttons",
		["minimapicon"] = "Minimap Icon",
		["missingxp"] = "Missing XP",
		["move"] = "Move",
		["moveall"] = "Move all",
		["moveframes"] = "Move Frames",
		["movenothing"] = "Move nothing",
		["nochanges"] = "No Changes",
		["notmove"] = "Not Move",
		["oncursor"] = "Show near Cursor",
		["outofcombat"] = "Out of Combat",
		["petactionbar"] = "Pet Action Bar",
		["petframe"] = "Pet Frame",
		["playerframe"] = "Player Frame",
		["position"] = "Position",
		["profile"] = "Profile",
		["profiles"] = "Profiles",
		["pvpcapturestatus"] = "PvP Flag Capture Status",
		["questlog"] = "Questlog",
		["remove"] = "Remove",
		["removeprofile"] = "Remove Profile",
		["repbar"] = "Reputation Bar",
		["rows"] = "Rows",
		["scale"] = "Scale",
		["scaleframes"] = "Scale Frames",
		["share"] = "Share",
		["showcountryflag"] = "Show Country Flag",
		["showilvl"] = "Show Item Level",
		["skills"] = "Skills",
		["snaptogrid"] = "Snap to Grid",
		["spacing"] = "Spacing",
		["stancebar"] = "Stance Bar",
		["statusbar"] = "Status Bar",
		["talkinghead"] = "Talking Head",
		["targetframe"] = "Target Frame",
		["targetframetot"] = "Target Of Target",
		["temporaryenchantframe"] = "Temporary Weapon Enchants",
		["timer"] = "Timer",
		["tooltip"] = "Tooltip",
		["uicolor"] = "Ui Color",
		["uiwidget"] = "Ui Widget",
		["uiwidgetbelowminimap"] = "Widget below Minimap",
		["uiwidgettopcenter"] = "Widget in TopCenter",
		["unlock"] = "Unlock",
		["unlocked"] = "Unlocked",
		["vehicleseats"] = "Vehicle Seats",
		["visible"] = "Visible",
		["worldtextscale"] = "World Text Scale",
		["xpbar"] = "XP Bar",
		["zoneability"] = "Zone Ability",
		["zonetext"] = "Zone Text",
		["zoomout"] = "Zoom out"
	}

	MAIUpdateLanguageTab( tab )

	-- GLOBALS
	LANG_MAI.sellprice = SELL_PRICE

	if engcount == 0 then
		for i, v in pairs( LANG_MAI ) do
			engcount = engcount + 1
		end
	end
end
