local MAI_BUFFS_PER_ROW = 8
local MAI_BUFF_ROW_SPACING = 15
local MAI_BUFF_BUTTON_HEIGHT = 30

local DIRB = "LEFT"
local HORB = "TOP"
local DIRD = "LEFT"
local HORD = "TOP"

local MAIBPOINT = "TOPRIGHT"
local MAIDPOINT = "TOPRIGHT"

local once = false

local oldenchants = -1
local enchants = 0

local maibuffs = {}
local maidebuffs = {}

local maidebuffstab = {}

local buffsetup = false

MAIBuffFrame = CreateFrame( "FRAME", "MAIBuffFrame", UIParent)
MAIBuffFrame:SetSize(60, 60)
MAIBuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -300, -10)

MAIDebuffFrame = CreateFrame( "FRAME", "MAIDebuffFrame", MAIBuffFrame)
MAIDebuffFrame:SetSize(60, 60)
MAIDebuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -300, -210)



function MAIZoomBuffs(id)
	if MAIGV( "MAIBuffFrame" .. "Enabled" ) and MAIGV( "MAIBuffFrame" .. "improvements" ) and not MAIGV( "nochanges" ) then
		local border = _G["BuffButton" .. id .. "Border"]
		local icon = _G["BuffButton" .. id .. "Icon"]

		if border == nil and _G["BuffButton" .. id] ~= nil then
			_G["BuffButton" .. id .. "Border"] = _G["BuffButton" .. id]:CreateTexture(nil, "ARTWORK")
			border = _G["BuffButton" .. id .. "Border"]
			border:SetTexture("Interface\\AddOns\\D4KiR MoveAndImprove\\media\\border")
			border:SetAllPoints(_G["BuffButton" .. id])
		end

		if border ~= nil and border.hooked == nil then
			border.hooked = true
			
			hooksecurefunc(border, "SetVertexColor", function(self, ...)
				if self.setvertexcolor then return end
				self.setvertexcolor = true
				if MAIGV( "UIColorEnabled", true ) then
					self:SetVertexColor(MAIGetUIColor())
				end
				self.setvertexcolor = false
			end)
			MAIRegisterUIColor(border)
		end

		if icon ~= nil and icon.hooked == nil then
			icon.hooked = true

			hooksecurefunc(icon, "SetTexCoord", function(self, ...)
				if self.settexcoord then return end
				self.settexcoord = true

				local br = FLATBORDER
				self:SetTexCoord(br, 1 - br, br, 1 - br)

				self.settexcoord = false
			end)
			icon:SetTexCoord(0, 1, 0, 1)
		end
	end
end

function MAIBuffDirection()
	HORB = "TOP"
	HORD = "TOP"
	MAIBPOINT = "CENTER"
	MAIDPOINT = "CENTER"

	if _G["MAIBuffFrame" .. "Mover"] then
		local point = _G["MAIBuffFrame" .. "Mover"]:GetPoint()
		if point == nil then return end -- Error
		if point == "TOPLEFT" or point == "LEFT" or point == "BOTTOMLEFT" then
			DIRB = "RIGHT"
		else
			DIRB = "LEFT"
		end
		if point == "BOTTOMLEFT" or point == "BOTTOM" or point == "BOTTOMRIGHT" then
			HORB = "BOTTOM"
		elseif point == "LEFT" or point == "CENTER" or point == "RIGHT" then
			HORB = "CENTER"
		end
	end

	if _G["MAIDebuffFrame" .. "Mover"] then
		local point = _G["MAIDebuffFrame" .. "Mover"]:GetPoint()
		if point == nil then return end -- Error
		if point == "TOPLEFT" or point == "LEFT" or point == "BOTTOMLEFT" then
			DIRD = "RIGHT"
		else
			DIRD = "LEFT"
		end
		if point == "BOTTOMLEFT" or point == "BOTTOM" or point == "BOTTOMRIGHT" then
			HORD = "BOTTOM"
		elseif point == "LEFT" or point == "CENTER" or point == "RIGHT" then
			HORD = "CENTER"
		end
	else
		local point = _G["MAIBuffFrame" .. "Mover"]:GetPoint()
		if point == nil then return end -- Error
		if point == "TOPLEFT" or point == "LEFT" or point == "BOTTOMLEFT" then
			DIRD = "RIGHT"
		else
			DIRD = "LEFT"
		end
		if point == "BOTTOMLEFT" or point == "BOTTOM" or point == "BOTTOMRIGHT" then
			HORD = "BOTTOM"
		elseif point == "LEFT" or point == "CENTER" or point == "RIGHT" then
			HORD = "CENTER"
		end
	end

	if HORB ~= "CENTER" then
		if DIRB == "LEFT" then
			MAIBPOINT = HORB .. "RIGHT"
		elseif DIRB == "RIGHT" then
			MAIBPOINT = HORB .. "LEFT"
		end
	else
		if DIRB == "LEFT" then
			MAIBPOINT = "RIGHT"
		elseif DIRB == "RIGHT" then
			MAIBPOINT = "LEFT"
		end
	end

	if HORD ~= "CENTER" then
		if DIRD == "LEFT" then
			MAIDPOINT = HORD .. "RIGHT"
		elseif DIRD == "RIGHT" then
			MAIDPOINT = HORD .. "LEFT"
		end
	else
		if DIRD == "LEFT" then
			MAIDPOINT = "RIGHT"
		elseif DIRD == "RIGHT" then
			MAIDPOINT = "LEFT"
		end
	end
end

function MAIPositionDebuffs(rows)
	if MAILoaded and MAIGV( "MAIDebuffFrame" .. "Enabled" ) then
		return
	end

	local _rows = rows + 1
	local dist = _rows * (36 + MAI_BUFF_ROW_SPACING)
	MAIDebuffFrame:ClearAllPoints()
	if HORB == "BOTTOM" then
		MAIDebuffFrame:SetPoint(MAIDPOINT, MAIBuffFrame, MAIDPOINT, 0, dist)
	else
		MAIDebuffFrame:SetPoint(MAIDPOINT, MAIBuffFrame, MAIDPOINT, 0, -dist)
	end
end

function MAIUpdateBuffs()
	if not buffsetup then
		return
	end

	if MAIDebuffFrameMover == nil then
		MAICheckBuffRows()
	end
	
	if MAIBuffFrameMover and MAIBuffFrameMover.hookedbuffs == nil then
		MAIBuffFrameMover.hookedbuffs = true
		hooksecurefunc(MAIBuffFrameMover, "SetPoint", function()
			MAIBuffDirection()
			MAICheckEnchants()
			if MAIDebuffFrameMover == nil then
				MAICheckBuffRows()
			end
		end)
		MAIBuffFrameMover:SetPoint(MAIBuffFrameMover:GetPoint())
		MAIBuffDirection()
	end

	if MAIDebuffFrameMover and MAIDebuffFrameMover.hookeddebuffs == nil then
		MAIDebuffFrameMover.hookeddebuffs = true
		hooksecurefunc(MAIDebuffFrameMover, "SetPoint", function()
			MAIBuffDirection()
			MAICheckEnchants()
		end)
		MAIDebuffFrameMover:SetPoint(MAIDebuffFrameMover:GetPoint())
		MAIBuffDirection()
	end
	
	local retry = false

	local buff, previousBuff, aboveBuff, index
	local numBuffs = 0
	local numAuraRows = 0
	
	local slack = enchants

	for i = 1, 32 do
		local index = i
		local buff = _G["BuffButton" .. index]
		if buff == nil then
			retry = true
			break
		else
			numBuffs = numBuffs + 1
			
			if TemporaryEnchantFrameMover then
				index = numBuffs
			else
				index = numBuffs + slack
			end

			if ( (index > 1) and (mod(index, MAI_BUFFS_PER_ROW) == 1) ) then
				-- New row
				numAuraRows = numAuraRows + 1
				if HORB == "BOTTOM" then
					buff.t1 = "BOTTOMRIGHT"
					buff.t2 = aboveBuff
					buff.t3 = "TOPRIGHT"
					buff.t4 = 0
					buff.t5 = MAI_BUFF_ROW_SPACING
				else
					buff.t1 = "TOPRIGHT"
					buff.t2 = aboveBuff
					buff.t3 = "BOTTOMRIGHT"
					buff.t4 = 0
					buff.t5 = -MAI_BUFF_ROW_SPACING
				end
				aboveBuff = buff
			elseif ( index == 1 ) then
				-- first btn
				numAuraRows = 1

				if DIRB == "LEFT" then
					if HORB == "BOTTOM" then
						buff.t1 = "BOTTOMRIGHT"
						buff.t2 = MAIBuffFrame
						buff.t3 = "BOTTOMRIGHT"
						buff.t4 = 0
						buff.t5 = 0
					elseif HORB == "CENTER" then
						buff.t1 = "RIGHT"
						buff.t2 = MAIBuffFrame
						buff.t3 = "RIGHT"
						buff.t4 = 0
						buff.t5 = 0
					else
						buff.t1 = "TOPRIGHT"
						buff.t2 = MAIBuffFrame
						buff.t3 = "TOPRIGHT"
						buff.t4 = 0
						buff.t5 = 0
					end
				else
					if HORB == "BOTTOM" then
						buff.t1 = "BOTTOMLEFT"
						buff.t2 = MAIBuffFrame
						buff.t3 = "BOTTOMLEFT"
						buff.t4 = 0
						buff.t5 = 0
					elseif HORB == "CENTER" then
						buff.t1 = "LEFT"
						buff.t2 = MAIBuffFrame
						buff.t3 = "LEFT"
						buff.t4 = 0
						buff.t5 = 0
					else
						buff.t1 = "TOPLEFT"
						buff.t2 = MAIBuffFrame
						buff.t3 = "TOPLEFT"
						buff.t4 = 0
						buff.t5 = 0
					end
				end
				aboveBuff = buff
			else
				if ( numBuffs == 1 ) then
					if ( enchants > 0 and TemporaryEnchantFrameMover == nil) then
						local parent = TempEnchant1
						if enchants == 1 then
							parent = TempEnchant1
						elseif enchants == 2 then
							parent = TempEnchant2
						elseif enchants == 3 then
							parent = TempEnchant3
						end

						if DIRB == "LEFT" then
							buff.t1 = "TOPRIGHT"
							buff.t2 = parent
							buff.t3 = "TOPRIGHT"
							buff.t4 = -(buff:GetHeight() + MAIGV( "MAIBuffFrame" .. "spacing" ))
							buff.t5 = 0
						else
							buff.t1 = "TOPLEFT"
							buff.t2 = parent
							buff.t3 = "TOPLEFT"
							buff.t4 = (buff:GetHeight() + MAIGV( "MAIBuffFrame" .. "spacing" ))
							buff.t5 = 0
						end
						aboveBuff = TempEnchant1;
					else
						buff.t1 = "TOPLEFT"
						buff.t2 = MAIBuffFrame
						buff.t3 = "TOPLEFT"
						buff.t4 = 0
						buff.t5 = 0
					end
				else
					if DIRB == "LEFT" then
						buff.t1 = "RIGHT"
						buff.t2 = previousBuff
						buff.t3 = "LEFT"
						buff.t4 = -MAIGV( "MAIBuffFrame" .. "spacing" )
						buff.t5 = 0
					else
						buff.t1 = "LEFT"
						buff.t2 = previousBuff
						buff.t3 = "RIGHT"
						buff.t4 = MAIGV( "MAIBuffFrame" .. "spacing" )
						buff.t5 = 0
					end
				end
			end

			if not tContains(maibuffs, i) then
				tinsert(maibuffs, i)
				if ( buff.parent ~= MAIBuffFrame ) then
					buff.count:SetFontObject(NumberFontNormal)
					buff:SetParent(MAIBuffFrame)
				end
				hooksecurefunc(buff, "SetPoint", function(self, ...)
					if self.setpoint then return end
					self.setpoint = true
					if self.t1 then
						buff:ClearAllPoints()
						buff:SetPoint(self.t1, self.t2, self.t3, self.t4, self.t5)
					end

					self.setpoint = false
				end)

				buff:SetPoint("CENTER")
			elseif buff.enchants ~= enchants then
				buff:SetPoint("CENTER")
			end

			previousBuff = buff
		end
	end
	
	local oldd = nil
	for i = 1, 16 do
		local debuff = _G["DebuffButton" .. i]
		
		if not previousBuff then
			previousBuff = MAIBuffFrame
		end

		if debuff then
			local _, _, _, ofsx, _ = debuff:GetPoint()
			local _, _, _, _, ofsy = previousBuff:GetPoint()
						
			if HORD == "BOTTOM" then
				if ofsy > 0 then
					ofsy = -ofsy
				end
			end

			local rows = 0
			local coun = 0
			for i = 1, 32 do
				if UnitBuff("player", i) ~= nil then
					coun = i
				end
			end
			if coun > 8 then
				rows = 2
			elseif coun > 0 then
				rows = 1
			end

			local dist = (rows + 1) * (MAI_BUFF_BUTTON_HEIGHT + MAI_BUFF_ROW_SPACING)
			ofsy = -dist

			local px = 0
			if DIRD == "LEFT" then
				px = -5
			elseif DIRD == "RIGHT" then
				px = 5
			end
			local py = 0
			if HORD == "TOP" then
				py = -5
			elseif HORD == "BOTTOM" then
				py = 5
			end
			
			maidebuffstab[i] = maidebuffstab[i] or {}
			if i == 1 then
				maidebuffstab[i].t1 = MAIDPOINT
				maidebuffstab[i].t2 = MAIDebuffFrame
				maidebuffstab[i].t3 = MAIDPOINT
				if _G["MAIDebuffFrame" .. "Mover"] then
					maidebuffstab[i].t4 = px
					maidebuffstab[i].t5 = py
				else
					maidebuffstab[i].t4 = 0
					maidebuffstab[i].t5 = 0
				end
			else
				if DIRD == "LEFT" then
					maidebuffstab[i].t1 = "RIGHT"
					maidebuffstab[i].t2 = oldd
					maidebuffstab[i].t3 = "LEFT"
					maidebuffstab[i].t4 = -MAIGV( "MAIBuffFrame" .. "spacing" )
					maidebuffstab[i].t5 = 0
				else
					maidebuffstab[i].t1 = "LEFT"
					maidebuffstab[i].t2 = oldd
					maidebuffstab[i].t3 = "RIGHT"
					maidebuffstab[i].t4 = MAIGV( "MAIBuffFrame" .. "spacing" )
					maidebuffstab[i].t5 = 0
				end
			end

			if not tContains(maidebuffs, i) then
				tinsert(maidebuffs, i)

				debuff:SetParent(MAIDebuffFrame)

				hooksecurefunc(debuff, "SetPoint", function(self, ...)
					if self.setpoint then return end
					self.setpoint = true
					if maidebuffstab[i] then
						if maidebuffstab[i].t1 then
							self:ClearAllPoints()
							self:SetPoint(maidebuffstab[i].t1, maidebuffstab[i].t2, maidebuffstab[i].t3, maidebuffstab[i].t4, maidebuffstab[i].t5)
						end
					end

					self.setpoint = false
				end)

				debuff:SetPoint(debuff:GetPoint())
			end

			oldd = debuff
		else
			retry = true
		end
	end

	-- Masque
	local MSQ = LibStub("Masque", true)
	if MSQ then
		if once == false then
			once = true
			MSQ:Register("Buffs",
			function()

			end,
			{})

			MAIMasqueBuffs = MSQ:Group("MAI Blizzard Buffs")
		end
	
		for i = 1, 32 do
			local btn = _G["BuffButton" .. i]
			if btn then
				if not btn.MasqueButtonData then
					btn.MasqueButtonData = {
						Button = btn,
						Icon = _G["BuffButton" .. "IconTexture"],
					}
					MAIMasqueBuffs:AddButton(btn, btn.MasqueButtonData, "Item")
				end
			end
			
			local btn2 = _G["DebuffButton" .. i]
			if btn2 then
				if not btn2.MasqueButtonData then
					btn2.MasqueButtonData = {
						Button = btn2,
						Icon = _G["DebuffButton" .. "IconTexture"],
					}
					MAIMasqueBuffs:AddButton(btn2, btn2.MasqueButtonData, "Item")
				end
			end
		end

		for i = 1, 2 do
			local btn = _G["TempEnchant" .. i]
			if btn then
				if not btn.MasqueButtonData then
					btn.MasqueButtonData = {
						Button = btn,
						Icon = _G["TempEnchant" .. i .. "IconTexture"],
					}
					MAIMasqueBuffs:AddButton(btn, btn.MasqueButtonData, "Item")
				end
			end
		end
	else
		for id = 1, 32 do
			MAIZoomBuffs(id)
		end
	end
end

function MAICheckEnchants()
	local enchant1, _, _, _, enchant2, _, _, _, enchant3, _, _, _ = GetWeaponEnchantInfo()
	local _enchants = 0
	if enchant1 then
		_enchants = 1
	end
	if enchant2 then
		_enchants = 2
	end
	enchants = _enchants

	if MAIBuffFrameMover and MAIBuffFrameMover.enchanthooked == nil then
		MAIBuffFrameMover.enchanthooked = true
		hooksecurefunc(MAIBuffFrameMover, "SetPoint", function(self, ...)
			if oldenchants ~= enchants then
				oldenchants = enchants

				if not TemporaryEnchantFrameMover then
					hooksecurefunc( TemporaryEnchantFrame, "SetPoint", function(self, ...)
						if self.maisetpointe then return end
						self.maisetpointe = true
						local t1, t2, t3, t4, t5 = MAIBuffFrameMover:GetPoint()
						self:ClearAllPoints()
						self:SetPoint(t1, t2, t3, t4, t5)
						self.maisetpointe = false
					end )
					TemporaryEnchantFrame:SetPoint(TemporaryEnchantFrame:GetPoint())

					hooksecurefunc( TemporaryEnchantFrame, "SetSize", function(self, ...)
						if self.maisetsize then return end
						self.maisetsize = true
						self:SetSize( 30, 30 )
						self.maisetsize = false
					end )
					TemporaryEnchantFrame:SetSize( 30, 30 )

					hooksecurefunc( TemporaryEnchantFrame, "SetWidth", function(self, ...)
						if self.maisetwidth then return end
						self.maisetwidth = true
						self:SetWidth( 30 )
						self.maisetwidth = false
					end )
					TemporaryEnchantFrame:SetWidth( 30 )

					hooksecurefunc( TemporaryEnchantFrame, "SetHeight", function(self, ...)
						if self.maisetheight then return end
						self.maisetheight = true
						self:SetHeight( 30 )
						self.maisetheight = false
					end )
					TemporaryEnchantFrame:SetHeight( 30 )

					DIRT = DIRB
				else
					local t1, t2, t3, t4, t5 = TemporaryEnchantFrameMover:GetPoint()
					
					DIRT = "LEFT"
					if t1 == "TOPLEFT" or t1 == "LEFT" or t1 == "BOTTOM LEFT" then
						DIRT = "RIGHT"
					end
				end
				
				if TempEnchant1 ~= nil then
					TempEnchant1:ClearAllPoints()
					if DIRT == "LEFT" then
						TempEnchant1:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", 0, 0)
					else
						TempEnchant1:SetPoint("TOPLEFT", TemporaryEnchantFrame, "TOPLEFT", 0, 0)
					end
				end
				if TempEnchant2 ~= nil then
					TempEnchant2:ClearAllPoints()
					if DIRT == "LEFT" then
						TempEnchant2:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", -(TempEnchant1:GetWidth() + MAIGV( "MAIBuffFrame" .. "spacing" )), 0)
					else
						TempEnchant2:SetPoint("TOPLEFT", TemporaryEnchantFrame, "TOPLEFT", TempEnchant1:GetWidth() + MAIGV( "MAIBuffFrame" .. "spacing" ), 0)
					end
				end
				if TempEnchant3 ~= nil then
					TempEnchant3:ClearAllPoints()
					if DIRT == "LEFT" then
						TempEnchant3:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", -(TempEnchant2:GetWidth() + MAIGV( "MAIBuffFrame" .. "spacing" )) * 2, 0)
					else
						TempEnchant3:SetPoint("TOPLEFT", TemporaryEnchantFrame, "TOPLEFT", TempEnchant2:GetWidth() + MAIGV( "MAIBuffFrame" .. "spacing" ) * 2, 0)
					end
				end

				MAIUpdateBuffs()
			end

			TemporaryEnchantFrame:SetPoint(TemporaryEnchantFrame:GetPoint())
		end)
		MAIBuffFrameMover:SetPoint(MAIBuffFrameMover:GetPoint())
	end
	
	if MAIGV( "MAIBuffFrame" .. "Enabled" ) and MAIGV( "MAIBuffFrame" .. "improvements" ) and not MAIGV( "nochanges" ) then
		for id = 1, 3 do
			local border = _G["TempEnchant" .. id .. "Border"]
			local icon = _G["TempEnchant" .. id .. "Icon"]

			if border == nil and _G["TempEnchant" .. id] ~= nil then
				_G["TempEnchant" .. id .. "Border"] = _G["TempEnchant" .. id]:CreateTexture(nil, "ARTWORK")
				border = _G["TempEnchant" .. id .. "Border"]
				border:SetTexture("Interface\\AddOns\\D4KiR MoveAndImprove\\media\\border")
				border:SetAllPoints(_G["TempEnchant" .. id])
			end

			if border ~= nil and border.hooked == nil then
				border.hooked = true

				hooksecurefunc(border, "SetVertexColor", function(self, ...)
					if self.setvertexcolor then return end
					self.setvertexcolor = true
					if MAIGV( "UIColorEnabled", true ) then
						self:SetVertexColor(MAIGetUIColor())
					end
					self.setvertexcolor = false
				end)
				MAIRegisterUIColor(border)
			end

			if icon ~= nil and icon.hooked == nil then
				icon.hooked = true

				hooksecurefunc(icon, "SetTexCoord", function(self, ...)
					if self.settexcoord then return end
					self.settexcoord = true

					local br = FLATBORDER
					self:SetTexCoord(br, 1 - br, br, 1 - br)

					self.settexcoord = false
				end)
				icon:SetTexCoord(0, 1, 0, 1)
			end
		end
	end
end

local f = CreateFrame( "FRAME", "buffthinker", UIParent)
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f.row = -1
function MAICheckBuffRows()
	local count = 0
	for i = 1, 32 do
		if _G["BuffButton" .. i] and _G["BuffButton" .. i]:IsShown() then
			count = count + 1
		end
	end

	if count == 0 then
		count = 1
	end

	count = count - 1

	local row = count / 8 - count / 8 % 1
	row = row + 1

	if f.row ~= row then
		f.row = row
		MAIPositionDebuffs(f.row)
	end
end

function f:OnEvent(event, unit, ...)
	if unit == "player" then
		if event == "UNIT_INVENTORY_CHANGED" then
			MAICheckEnchants()
		end
		if MAIGV( "MAIBuffFrameEnabled" ) and buffsetup then
			MAIUpdateBuffs()
		end
	end
end
f:SetScript("OnEvent", f.OnEvent)

function MAISetupDebuffFrame()
	MAIUpdateBuffs()

	hooksecurefunc(MAIDebuffFrameMover, "SetPoint", function(self, ...)
		f.row = 0
		MAIBuffDirection()
		MAICheckEnchants()
		MAIUpdateBuffs()
	end)
end

function MAISetupBuffFrame()
	if ConvertSecondsToUnits == nil then -- if function not exists
		function ConvertSecondsToUnits(timestamp)
			timestamp = math.max(timestamp, 0);
			local days = math.floor(timestamp / SECONDS_PER_DAY);
			timestamp = timestamp - (days * SECONDS_PER_DAY);
			local hours = math.floor(timestamp / SECONDS_PER_HOUR);
			timestamp = timestamp - (hours * SECONDS_PER_HOUR);
			local minutes = math.floor(timestamp / SECONDS_PER_MIN);
			timestamp = timestamp - (minutes * SECONDS_PER_MIN);
			local seconds = math.floor(timestamp);
			local milliseconds = timestamp - seconds;
			return {
				days=days,
				hours=hours,
				minutes=minutes,
				seconds=seconds,
				milliseconds=milliseconds,
			}
		end
	end

	if MAIGV( "MAIBuffFrame" .. "spacing" ) == nil then
		MAISV( "MAIBuffFrame" .. "spacing", 2 )
	end

	hooksecurefunc(MAIBuffFrameMover, "SetPoint", function(self, ...)
		f.row = 0
		MAIBuffDirection()
		MAICheckEnchants()
		MAIUpdateBuffs()
	end)
	MAIBuffFrameMover:SetPoint(MAIBuffFrameMover:GetPoint())

	if MAIGV( "MAIBuffFrame" .. "accuratetime" ) == nil then
		MAISV( "MAIBuffFrame" .. "accuratetime", true )
	end

	if MAIGV( "MAIBuffFrame" .. "accuratetime" ) then
		hooksecurefunc("AuraButton_UpdateDuration", function(buff, duration)
			local buffname = buff:GetName()
			if buff.setfont == nil then
				buff.setfont = true
				local fontFamily, fontSize, fontFlags = _G[buffname .. "Duration"]:GetFont()
				_G[buffname .. "Duration"]:SetFont(fontFamily, 8, fontFlags)
			end

			buff.dura = duration

			local bd = _G[buffname .. "Duration"]
			if buff.hooked == nil then
				buff.hooked = true
				bd.OldSetFormattedText = bd.SetFormattedText
				function bd:SetFormattedText(text)
					-- nothing
				end

				function buff.think()
					bd = _G[buffname .. "Duration"]
					local duration = buff.dura
					if duration then
						local ts = ConvertSecondsToUnits(duration)
						if duration >= 60 then
							local minutes = ts.hours * 60 + ts.minutes
							if ts.seconds < 10 then
								ts.seconds = 0 .. ts.seconds
							end
							bd:OldSetFormattedText(minutes .. ":" .. ts.seconds)
						else
							bd:OldSetFormattedText(format(SECOND_ONELETTER_ABBR, ts.seconds))
						end
					end
					C_Timer.After(0.1, buff.think)
				end
				buff.think()
			end
		end)
	end

	buffsetup = true

	if MAIDEBUG then
		MAIBuffFrame.texture = MAIBuffFrame:CreateTexture(nil, "BACKGROUND")
		MAIBuffFrame.texture:SetAllPoints(MAIBuffFrame)
		MAIBuffFrame.texture:SetColorTexture(0, 1, 0, 0.5)

		MAIDebuffFrame.texture = MAIDebuffFrame:CreateTexture(nil, "BACKGROUND")
		MAIDebuffFrame.texture:SetAllPoints(MAIDebuffFrame)
		MAIDebuffFrame.texture:SetColorTexture(1, 0, 0, 0.5)

		TemporaryEnchantFrame.texture = TemporaryEnchantFrame:CreateTexture(nil, "BACKGROUND")
		TemporaryEnchantFrame.texture:SetAllPoints(TemporaryEnchantFrame)
		TemporaryEnchantFrame.texture:SetColorTexture(0, 0, 1, 0.5)

		TempEnchant1.texture = TempEnchant1:CreateTexture(nil, "OVERLAY")
		TempEnchant1.texture:SetAllPoints(TempEnchant1)
		TempEnchant1.texture:SetColorTexture(1, 1, 0, 0.75)

		TempEnchant2.texture = TempEnchant2:CreateTexture(nil, "OVERLAY")
		TempEnchant2.texture:SetAllPoints(TempEnchant2)
		TempEnchant2.texture:SetColorTexture(1, 1, 0, 0.75)

		TempEnchant3.texture = TempEnchant3:CreateTexture(nil, "OVERLAY")
		TempEnchant3.texture:SetAllPoints(TempEnchant3)
		TempEnchant3.texture:SetColorTexture(1, 1, 0, 0.75)
	end
end
