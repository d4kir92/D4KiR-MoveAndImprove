
GameTooltip:SetSize(60, 60)
GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -130, 120)

function MAISetupGameTooltip()
	if MAIGV( "GameTooltip" .. "oncursor" ) == nil then
		MAISV( "GameTooltip" .. "oncursor", false )
	end

	if not MAIGV( "nochanges" ) and MAIGV( "GameTooltip" .. "improvements" ) then
		_G["GameTooltip" .. "StatusBar"].text = _G["GameTooltip" .. "StatusBar"]:CreateFontString(nil, "ARTWORK")
		_G["GameTooltip" .. "StatusBar"].text:SetFont(STANDARD_TEXT_FONT, 8, "")
		_G["GameTooltip" .. "StatusBar"].text:SetPoint("CENTER", _G["GameTooltip" .. "StatusBar"], "CENTER", 0, 0)
		_G["GameTooltip" .. "StatusBar"].text:SetText("")

		_G["GameTooltip" .. "PowerBar"] = CreateFrame("StatusBar", nil, GameTooltip)
		_G["GameTooltip" .. "PowerBar"]:SetSize(40, 8)
		_G["GameTooltip" .. "PowerBar"]:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 2, -10)
		_G["GameTooltip" .. "PowerBar"]:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -2, -10)
		_G["GameTooltip" .. "PowerBar"]:SetStatusBarTexture([[Interface\TargetingFrame\UI-TargetingFrame-BarFill]])
		_G["GameTooltip" .. "PowerBar"]:SetMinMaxValues( 0, 1 )

		_G["GameTooltip" .. "PowerBar"].text = _G["GameTooltip" .. "PowerBar"]:CreateFontString(nil, "ARTWORK")
		_G["GameTooltip" .. "PowerBar"].text:SetFont(STANDARD_TEXT_FONT, 8, "")
		_G["GameTooltip" .. "PowerBar"].text:SetPoint("CENTER", _G["GameTooltip" .. "PowerBar"], "CENTER", 0, 0)
		_G["GameTooltip" .. "PowerBar"].text:SetText("")

		_G["GameTooltip" .. "PowerBar"]:SetScript("OnUpdate", function(self)
			local unit = "mouseover"
			local powerid, powername = UnitPowerType(unit)
			local color = PowerBarColor[powerid]

			_G["GameTooltip" .. "PowerBar"]:SetStatusBarColor( color.r, color.g, color.b )
			
			if _G["GameTooltip" .. "StatusBar"]:IsShown() then
				if UnitPowerMax(unit) > 0 then
					_G["GameTooltip" .. "PowerBar"]:SetAlpha(1)
					_G["GameTooltip" .. "PowerBar"]:SetValue(UnitPower(unit) / UnitPowerMax(unit))
					_G["GameTooltip" .. "PowerBar"].text:SetText(UnitPower(unit) .. "/" .. UnitPowerMax(unit) .. " (" .. string.format("%0.2f", UnitPower(unit) / UnitPowerMax(unit) * 100 ) .. "%)" )
				else
					_G["GameTooltip" .. "PowerBar"]:SetAlpha(0)
				end
			else
				_G["GameTooltip" .. "PowerBar"]:SetAlpha(0)
			end

			if UnitHealthMax(unit) > 0 then
				_G["GameTooltip" .. "StatusBar"].text:SetText(UnitHealth(unit) .. "/" .. UnitHealthMax(unit) .. " (" .. string.format("%0.2f", UnitHealth(unit) / UnitHealthMax(unit) * 100 ) .. "%)" )
			end
		end)
	end

	--UIPARENT_MANAGED_FRAME_POSITIONS["GameTooltip"] = nil

	if GameTooltip.OldSetPoint == nil then -- Fixes: Action[SetPoint] failed because[SetPoint would result in anchor family connection]
		GameTooltip.OldSetPoint = GameTooltip.SetPoint
		function GameTooltip:SetPoint(...)
			-- FAKE
		end
		GameTooltip.OldClearAllPoints = GameTooltip.ClearAllPoints
		function GameTooltip:ClearAllPoints()
			-- FAKE
		end
	end

	--GameTooltip:SetMovable(true)
	--GameTooltip:SetUserPlaced(true)

	hooksecurefunc(GameTooltip, "SetPoint", function(self, ...)
		if self.setpoint then return end
		self.setpoint = true

		local point, parent, relativePoint, ofsx, ofsy = ...
		
		local uip = parent
		if type(uip) == "table" and uip.GetName then
			uip = uip:GetName()
		end
		if not MAIGV( "nochanges" ) and MAIGV( "GameTooltip" .. "oncursor" ) then
			-- HookScript("OnUpdate")
		else
			if point == "BOTTOMRIGHT" and (type(uip) == "string" and uip == "UIParent") and relativePoint == "BOTTOMRIGHT" then --and MAIMathR(ofsx, 0) == -97 and MAIMathR(ofsy, 0) == 130 then
				GameTooltip.point, GameTooltip.parent, GameTooltip.relativePoint, GameTooltip.ofsx, GameTooltip.ofsy = GameTooltipMover:GetPoint()
				self:OldClearAllPoints()
				self:OldSetPoint(GameTooltip.point, UIParent, GameTooltip.relativePoint, GameTooltip.ofsx, GameTooltip.ofsy)
			else -- if not have parent
				self:OldClearAllPoints()
				self:OldSetPoint(point, parent, relativePoint, ofsx, ofsy)
			end
		end
	
		self.setpoint = false
	end)
	GameTooltip:SetPoint("BOTTOMRIGHT", 0, 0)

	function MAIThinkGameTooltip()
		if not MAIGV( "nochanges" ) and MAIGV( "GameTooltip" .. "oncursor" ) then
			local point, parent, relativePoint, ofsx, ofsy = GameTooltip:GetPoint()
			if parent == nil or parent and parent.GetName and parent:GetName() ~= nil and string.find(strlower(parent:GetName()), "uiparent") then
				local scale = GameTooltip:GetEffectiveScale()
				local mX, mY = GetCursorPosition()
				mX = mX / scale
				mY = mY / scale
				GameTooltip:OldClearAllPoints()
				GameTooltip:OldSetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", mX + 22, mY + 22)
				GameTooltip.default = 1
			end
		end
		C_Timer.After(0.01, MAIThinkGameTooltip)
	end
	MAIThinkGameTooltip()

	if MAIGV( "GameTooltip" .. "improvements" ) and not MAIGV( "nochanges" ) then
		local maiclassids = {
			2, -- weapon
			3, -- gem
			4, -- armor
			6, -- projectile
			8 -- enchant
		}
		local function ItemExpansion(tt)
			local _, itemLink = tt:GetItem()
		
			if not itemLink then
				return
			end
		
			local itemId = tonumber(strmatch(itemLink, 'item:(%d*)'))
			if not itemId then
				return
			end

			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, price, classID, _, _, expacID, _, _ = GetItemInfo( itemId )
			if MAIGV( "GameTooltip" .. "sellprice" ) and price and tt.shownMoneyFrames == nil then
				if price > 0 and GetItemCount and GetCoinTextureString then
					local count = GetItemCount( itemId )
					if count and count > 1 and itemStackCount and AUCTION_BROWSE_UNIT_PRICE_SORT then
						tt:AddDoubleLine( AUCTION_BROWSE_UNIT_PRICE_SORT .. "", GetCoinTextureString( price ) )
						tt:AddDoubleLine( SELL_PRICE .. " (" .. count .. "/" .. itemStackCount .. ")", GetCoinTextureString( price * count ) )
					else
						tt:AddDoubleLine( SELL_PRICE .. ":", GetCoinTextureString( price ) )
					end
				else
					--tt:AddDoubleLine(ITEM_UNSELLABLE)
				end
			end
			local ilvl, _, baseilvl = GetDetailedItemLevelInfo(itemId)
			if MAIGV( "GameTooltip" .. "ilevel" ) and MAIBUILD ~= "RETAIL" and ilvl and tContains(maiclassids, classID) then
				local color = ITEM_QUALITY_COLORS[itemQuality]
				tt:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL .. ": ", color.hex .. ilvl)
			end
			if expacID and MAIGV( "GameTooltip" .. "expansion" ) then
				local textcolor = "|cFFFF1111"
				if expacID >= 8 then
					textcolor = "|cFF11FF11"
				end
				if MAIBUILD == "RETAIL" and expacID < 8 then
					tt:AddDoubleLine( format(ERR_REQUIRES_EXPANSION_S, ""), textcolor .. _G["EXPANSION_NAME" .. expacID] )
				end
			end
		end
		GameTooltip:HookScript("OnTooltipSetItem", ItemExpansion)
	end
end
