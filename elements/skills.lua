
local sw = 160
local sh = 16

local textc = "|cFF00FF00"
local textw = "|r"

function MAIGetSkillData( name )
	local itemcur = nil
	local itemmax = nil
	local itemname = nil
	if GetSkillLineInfo then
		for i = 1, 60 do
			skillName, _, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
			if skillName then
				if name == string.lower( skillName ) then
					itemcur = skillRank
					itemmax = skillMaxRank
					itemname = skillName
				end
			else
				break
			end
		end
	end
	return itemname, itemcur, itemmax
end

function MAIGetWeaponSkillData( id )
	local itemcur = nil
	local itemmax = nil
	local itemname = nil

	local item = GetInventoryItemLink("player", id )
	if item then
		if item then
			_, _, _, _, _, _, itemSubType = GetItemInfo(item)
			if itemSubType then
				if AUCTION_SUBCATEGORY_ONE_HANDED then
					local s1, e1 = string.find( itemSubType, AUCTION_SUBCATEGORY_ONE_HANDED, 1, true )
					if s1 and e1 then
						local onehanded = string.gsub( AUCTION_SUBCATEGORY_ONE_HANDED, "%-", "_" )
						itemSubType = string.gsub( itemSubType, "%-", "_" )
						
						itemSubType, count = string.gsub( itemSubType, "(" .. onehanded .. ") ", "" ) -- english
						itemSubType, count = string.gsub( itemSubType, "(" .. onehanded .. ")", "" ) -- german
					end
				end
				itemSubType = string.lower( itemSubType )
			end
		end
		itemname, itemcur, itemmax = MAIGetSkillData( itemSubType )
	end

	return itemname, itemcur, itemmax
end

if MAIBUILD ~= "RETAIL" then
	MAISkills = CreateFrame( "FRAME", "MAISkills", UIParent )
	MAISkills:SetPoint( "TOPLEFT", UIParent, "TOPLEFT", 400, 0 )
	MAISkills:SetSize( sw, 6 * sh )
	MAISkills.bars = {}
end

--[[
MAISkills.texture = MAISkills:CreateTexture(nil, "BACKGROUND")
MAISkills.texture:SetAllPoints(MAISkills)
MAISkills.texture:SetColorTexture(0, 1, 0, 0.5)
]]

function MAISkillsThink()
	local jobs = {}

	if GetSkillLineInfo then
		for i = 1, 64 do
			local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType = GetSkillLineInfo(i)
			if skillName then
				if isAbandonable then
					tinsert( jobs, skillName )
				end
			else
				break
			end
		end
	end

	local id = 1
	local jobid = 1
	for i, bar in pairs( MAISkills.bars ) do
		local name, cur, max = bar.func( bar.args )
		if bar.args == "job" then
			if jobs[jobid] then
				name, cur, max = bar.func( string.lower( jobs[jobid] ) )
				jobid = jobid + 1
			end
		end 
		if name and cur and max and cur < max then
			bar:Show()
			bar:SetPoint( "TOPLEFT", MAISkills, "TOPLEFT", 0, - ( id - 1 ) * sh )
			
			if MAIGV( "MAISkills" .. "hideartwork" ) then
				bar.border:Hide()

				bar.bar.sw = sw
				bar.bar:SetSize(sw, sh - 1)
				bar.bar:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
				bar.bg:SetSize(sw, sh - 1)
				bar.bg:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
			else
				bar.border:Show()

				bar.bar.sw = sw - 2
				bar.bar:SetSize(sw - 2, sh - 4)
				bar.bar:SetPoint("LEFT", bar, "LEFT", 1, 0)
				bar.bg:SetSize(sw - 2, sh - 4)
				bar.bg:SetPoint("LEFT", bar, "LEFT", 1, 0)
			end

			bar.text:SetText( name .. " " .. textc .. cur .. textw .. "/" .. textc .. max )
			bar.bar:SetWidth( cur / max * bar.bar.sw )

			id = id + 1
		else
			bar:Hide()
		end
	end

	if MAISkills and MAISkillsMover then
		MAISkills:SetHeight( ( id - 1 ) * sh )
		MAISkillsMover:SetHeight(  ( id - 1 ) * sh)
	end

	C_Timer.After( 0.1, MAISkillsThink )
end

local skillid = 0
function MAIAddStatusBar( func, args )
	skillid = skillid + 1

	if skillid then
		MAISkills.bars[skillid] = CreateFrame( "FRAME", name, MAISkills )

		local bar = MAISkills.bars[skillid]

		bar.func = func
		bar.args = args

		bar:SetSize( sw, sh )
		bar:SetPoint( "TOPLEFT", MAISkills, "TOPLEFT", 0, 0 )

		bar.bg = bar:CreateTexture(nil, "BACKGROUND")
		bar.bg:SetColorTexture( 0.02, 0.02, 0.02, 0.4 )
		bar.bg:SetDrawLayer("BACKGROUND", 0)

		bar.bar = bar:CreateTexture(nil, "BACKGROUND")
		bar.bar.sw = 0
		bar.bar:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
		bar.bar:SetVertexColor( 0.2, 0.2, 1, 1 )
		bar.bar:SetDrawLayer("BACKGROUND", 1)

		bar.text = bar:CreateFontString(nil, "ARTWORK")
		bar.text:SetFont(STANDARD_TEXT_FONT, 9, "")
		bar.text:SetPoint("CENTER", bar, "CENTER", 0, 0)
		bar.text:SetText("LOAD")

		bar.border = bar:CreateTexture(nil, "BORDER")
		bar.border:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
		bar.border:SetSize(sw + 6, sh + 3)
		bar.border:SetPoint("LEFT", bar, "LEFT", -3, 0)
	end
end

function MAISetupSkills()
	local textc = "|cFF00FF00"
	local textw = "|r"

	MAIAddStatusBar( MAIGetWeaponSkillData, 16 )
	MAIAddStatusBar( MAIGetWeaponSkillData, 17 )
	MAIAddStatusBar( MAIGetWeaponSkillData, 18 )
	MAIAddStatusBar( MAIGetSkillData, string.lower( STAT_CATEGORY_DEFENSE ) )

	MAIAddStatusBar( MAIGetSkillData, "job" )
	MAIAddStatusBar( MAIGetSkillData, "job" )
	MAIAddStatusBar( MAIGetSkillData, string.lower( PROFESSIONS_FIRST_AID ) )
	MAIAddStatusBar( MAIGetSkillData, string.lower( PROFESSIONS_COOKING ) )
	MAIAddStatusBar( MAIGetSkillData, string.lower( PROFESSIONS_FISHING ) )

	MAISkillsThink()
end
