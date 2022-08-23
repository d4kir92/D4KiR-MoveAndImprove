
function MAIChatOnlyBig( str )
	local res = string.gsub(str, "[^%u-]", "" )

	if #res > 3 then -- shorten
		res = string.sub( res, 1, 3 )
	end
	if #str <= 3 then -- 1-3 => upper
		res = string.upper( res )
	end

	if #res <= 0 then -- no upper?
		if #str <= 3 then
			res = string.upper( str )
		else
			res = string.gsub(str, "[^%l-]", "" )
			res = string.sub( res, 1, 1 )
			res = string.upper( res )
			--res = MAIChatOnlyBig( res )
		end
	end

	if string.find( res, "-", string.len( res ), true ) then
		res = string.gsub(str, "[^%u]", "" )
	end

	return res
end

local races = {}
if MAIBUILD == "CLASSIC" then
	races["Troll2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:128:192:64:128|t"
	races["NightElf3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:192:256:128:192|t"
	races["Human2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:0:64:0:64|t"
	races["Gnome3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:128:192:128:192|t"
	races["NightElf2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:192:256:0:64|t"
	races["Gnome2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:128:192:0:64|t"
	races["Orc2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:192:256:64:128|t"
	races["Human3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:0:64:128:192|t"
	races["Orc3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:192:256:192:256|t"
	races["Tauren3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:0:64:192:256|t"
	races["Troll3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:128:192:192:256|t"
	races["Scourge3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:64:128:192:256|t"
	races["Dwarf3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:64:128:128:192|t"
	races["Scourge2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:64:128:64:128|t"
	races["Tauren2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:0:64:64:128|t"
	races["Dwarf2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:256:256:64:128:0:64|t"
elseif MAIBUILD == "TBC" then
	races["Troll2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:128:192:64:128|t"
	races["Scourge2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:64:128:64:128|t"
	races["Tauren3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:0:64:192:256|t"
	races["Troll3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:128:192:192:256|t"
	races["Scourge3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:64:128:192:256|t"
	races["BloodElf3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:256:320:192:256|t"
	races["Draenei3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:256:320:128:192|t"
	races["NightElf3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:192:256:128:192|t"
	races["Gnome3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:128:192:128:192|t"
	races["NightElf2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:192:256:0:64|t"
	races["Gnome2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:128:192:0:64|t"
	races["BloodElf2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:256:320:64:128|t"
	races["Orc3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:192:256:192:256|t"
	races["Human2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:0:64:0:64|t"
	races["Tauren2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:0:64:64:128|t"
	races["Human3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:0:64:128:192|t"
	races["Dwarf3"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:64:128:128:192|t"
	races["Draenei2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:256:320:0:64|t"
	races["Orc2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:192:256:64:128|t"
	races["Dwarf2"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races:0:0:0:0:512:256:64:128:0:64|t"
elseif MAIBUILD == "RETAIL" then
	races["DarkIronDwarf2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:390:456:910:976|t"
	races["KulTiran2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1894:1960:0:66|t"
	races["Mechagnome3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:328:394|t"
	races["Vulpera2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:724:790|t"
	races["Scourge3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:394:460|t"
	races["VoidElf3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:526:592|t"
	races["Worgen2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:856:922|t"
	races["DarkIronDwarf3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:260:326:910:976|t"
	races["NightElf3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:592:658|t"
	races["Gnome3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1300:1366:0:66|t"
	races["Dwarf2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:910:976:910:976|t"
	races["Gnome2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1366:1432:0:66|t"
	races["Orc3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:724:790|t"
	races["ZandalariTroll2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1172:1238:130:196|t"
	races["Tauren2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:196:262|t"
	races["MagharOrc2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:262:328|t"
	races["Troll2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:328:394|t"
	races["Scourge2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:460:526|t"
	races["MagharOrc3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:196:262|t"
	races["Tauren3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:130:196|t"
	races["Goblin2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1498:1564:0:66|t"
	races["BloodElf3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:0:66:910:976|t"
	races["BloodElf2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:130:196:910:976|t"
	races["Human3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1696:1762:0:66|t"
	races["Human2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1762:1828:0:66|t"
	races["LightforgedDraenei2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:130:196|t"
	races["LightforgedDraenei3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1960:2026:0:66|t"
	races["HighmountainTauren2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1630:1696:0:66|t"
	races["Nightborne2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:526:592|t"
	races["Pandaren3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:856:922|t"
	races["Draenei3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:520:586:910:976|t"
	races["VoidElf2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:592:658|t"
	races["Nightborne3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:460:526|t"
	races["Worgen3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:790:856|t"
	races["NightElf2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:658:724|t"
	races["Goblin3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1432:1498:0:66|t"
	races["Orc2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:790:856|t"
	races["Mechagnome2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:394:460|t"
	races["Troll3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:262:328|t"
	races["ZandalariTroll3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:922:988|t"
	races["Vulpera3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1106:1172:658:724|t"
	races["KulTiran3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1828:1894:0:66|t"
	races["Dwarf3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:780:846:910:976|t"
	races["Draenei2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:650:716:910:976|t"
	races["HighmountainTauren3"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1564:1630:0:66|t"
	races["Pandaren2"] = "|TInterface\\Glues\\CharacterCreate\\CharacterCreateIcons:0:0:0:0:2048:1024:1040:1106:922:988|t"
end

local classes = {}
classes["WARRIOR"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:0:64:0:64|t" 
classes["MAGE"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:64:128:0:64|t" 
classes["ROGUE"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:128:192:0:64|t" 
classes["DRUID"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:192:256:0:64|t" 
classes["HUNTER"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:0:64:64:128|t" 
classes["SHAMAN"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:64:128:64:128|t" 
classes["PRIEST"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:128:192:64:128|t" 
classes["WARLOCK"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:192:256:64:128|t" 
classes["PALADIN"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:0:64:128:192|t" 
classes["DEATHKNIGHT"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:64:128:128:192|t" 
classes["MONK"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:128:192:128:192|t" 
classes["DEMONHUNTER"] = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:0:0:0:0:256:256:192:256:128:192|t" 

local PLYCache = {}
local function MAIGetGUID( name )
	return PLYCache[name]
end

function MAIResetMsg( msg )
	msg = string.gsub(msg, "(|Z)", "|X", 1)
	msg = string.gsub(msg, "(|z)", "|x", 1)
	return msg
end

function MAIChatAddItemIcons( msg, c )
	msg = string.gsub(msg, "(|H)", "|Z", 1)
	msg = string.gsub(msg, "(|h)", "|y", 1)
	msg = string.gsub(msg, "(|h)", "|z", 1)

	local itemString = select(3, strfind(msg, "|Z(.+)|z"))

	if itemString then
		local type = select( 1, string.split( ":", itemString ) )
		local id = select( 2, string.split( ":", itemString ) )

		if type == "item" then
			itemTexture = GetItemIcon(id)
			if itemTexture then
				if MAIGV( "ChatFrame1" .. "chatitemicons", true ) and not MAIGV( "nochanges" ) then
					msg = string.gsub(msg, "(|Z)", "|T" .. itemTexture .. ":0|t" .. "|X", 1)
					msg = string.gsub(msg, "(|z)", "|x", 1)

					return MAIChatAddItemIcons( msg, c + 1 )
				else
					msg = MAIResetMsg( msg )
				end
			else
				msg = MAIResetMsg( msg )
			end
		elseif type == "player" or type == "playerCommunity" or type == "playerGM" then
			local guid = MAIGetGUID( id )
			if guid then
				local _, engClass, _, engRace, gender, name, realm = GetPlayerInfoByGUID( guid )
				if engClass and engRace and gender and races[engRace .. gender] and classes[engClass] then
					local res = ""
					if MAIGV( "ChatFrame1" .. "chatraceicons", true ) and not MAIGV( "nochanges" ) then
						res = res .. races[engRace .. gender]
					end
					if MAIGV( "ChatFrame1" .. "chatclassicons", true ) and not MAIGV( "nochanges" ) then
						res = res .. classes[engClass]
					end
					local r, g, b, hex = 0, 0, 0, "FFFFFFFF"
					if GetClassColor then
						r, g, b, hex = GetClassColor(engClass)
					end
					if ( string.find( msg, name .. "-" .. realm, 1, true ) or string.find( msg, name, 1, true ) ) and MAIBUILD ~= "RETAIL" and MAIGV( "ChatFrame1" .. "chatshortchannels", true ) then
						msg = string.gsub(msg, "(|Z)", res .. "[|c" .. hex .. "|X", 1)
						msg = string.gsub(msg, "(%[" .. name .. "%])", name, 1)
						msg = string.gsub(msg, "(|z)", "|r]|x", 1)
					else
						if MAIBUILD ~= "RETAIL" and MAIGV( "ChatFrame1" .. "chatshortchannels", true ) then
							msg = string.gsub(msg, "(|Z)", res .. "|c" .. hex .. "|X", 1)
							msg = string.gsub(msg, "(|z)", "|r|x", 1)
						else
							msg = string.gsub(msg, "(|Z)", res .. "|X", 1)
							msg = string.gsub(msg, "(|z)", "|x", 1)
						end
					end

					return MAIChatAddItemIcons( msg, c + 1 )
				else
					msg = MAIResetMsg( msg )
				end
			else
				-- NPC TALK
				msg = MAIResetMsg( msg )
			end
		elseif type == "ccpCustomLink" then
			msg = MAIResetMsg( msg )
		elseif type == "BNplayer" or type == "BNplayerCommunity" then
			msg = MAIResetMsg( msg )
		else
			--MAIMSG( "SEND TO DEV => UNKNOWN CHAT TYPE: " .. tostring( type ) )
			msg = MAIResetMsg( msg )
		end
	end

	msg = string.gsub(msg, "(|X)", "|H")
	msg = string.gsub(msg, "(|y)", "|h")
	msg = string.gsub(msg, "(|x)", "|h")

	return msg
end



-- Item Icons
function MAIIconsFilter( self, event, msg, author, ... )
	local guid = select( 10, ... )
	if author and guid then
		PLYCache[author] = guid
	end
	return false, MAIChatAddItemIcons( msg, 1 ), author, ...
end

for type in next, getmetatable(ChatTypeInfo).__index do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_" .. type, MAIIconsFilter)
end



-- Class/Race Icons
local function MAIAddLinks(str)
	return MAIChatAddItemIcons( str, 1 )
end

local function MAIHookFunc( key )
	local org = _G[key]
	_G[key] = function( ... )
		return MAIAddLinks( org( ... ) ) 
	end
end
MAIHookFunc("GetBNPlayerCommunityLink") 
MAIHookFunc("GetBNPlayerLink") 
MAIHookFunc("GetGMLink") 
MAIHookFunc("GetPlayerCommunityLink") 
MAIHookFunc("GetPlayerLink") 



-- Change
local oldstrs = {}
function MAIUpdateChatChannels()
	local c = 1
	for i, v in pairs(_G) do
		if type(v) == "string" and string.find(i, "CHAT_", 1, true) and string.find(i, "_GET", 1, true) then
			c = c + 1
			local lang = string.sub( i, 6 )
			lang = string.sub( lang, 1, string.len( lang ) - 4 )
			if _G[lang] then
				if oldstrs[i] == nil then
					oldstrs[i] = _G[i]
				end

				if MAIGV("ChatFrame1" .. "chatshortchannels") and not MAIGV( "nochanges" ) then
					if lang == "CHANNEL" then
						_G[i] = "%s: "
					else
						_G[i] = "[" .. MAIChatOnlyBig( _G[lang] ) .. "] %s: "
					end
				elseif oldstrs[i] then
					_G[i] = oldstrs[i]
				end
			end
		end
	end
end

function ChatFrame_ResolvePrefixedChannelName( communityChannel )
	local prefix, communityChannel = communityChannel:match("(%d+. )(.*)");
	if MAIGV("ChatFrame1" .. "chatshortchannels") and not MAIGV( "nochanges" ) then
		return MAIChatOnlyBig( communityChannel )
	else
		return prefix..ChatFrame_ResolveChannelName(communityChannel);
	end
end
