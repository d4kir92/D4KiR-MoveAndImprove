local f = CreateFrame("FRAME")
f.update = 0.1

function MAISetupCastingBar()
	hooksecurefunc(CastingBarFrame.Border, "Show", function(self, ...)
        if MAIGV( "CastingBarFrame" .. "hideartwork" ) then
            self:Hide()
        end
    end)
    if MAIGV( "CastingBarFrame" .. "hideartwork" ) then
        CastingBarFrame.Border:Hide()
    end

	if MAIGV( "CastingBarFrame" .. "improvements" ) and not MAIGV( "nochanges" ) then
		CastingBarFrame.Flash:SetParent(MAIHIDDEN)

		CastingBarFrame.Text:SetFont(STANDARD_TEXT_FONT, 10, "")
		CastingBarFrame.Text:ClearAllPoints()
		CastingBarFrame.Text:SetPoint("CENTER", CastingBarFrame, "CENTER", 0, 0)

		CastingBarFrame:SetHeight(24)
		CastingBarFrame.Spark:SetHeight(24)
		CastingBarFrame.Border:SetHeight(96)
		CastingBarFrame.Border:ClearAllPoints()
		CastingBarFrame.Border:SetPoint("CENTER", CastingBarFrame, "CENTER", 0, 0)

		CastingBarFrame.icon = CastingBarFrame:CreateTexture(nil, "ARTWORK")
		CastingBarFrame.icon:SetSize(24, 24)
		CastingBarFrame.icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", 0, 0)
		CastingBarFrame.icon:SetTexCoord(FLATBORDER, 1 - FLATBORDER, FLATBORDER, 1 - FLATBORDER)

		CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
		CastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT, 10, "")
		CastingBarFrame.timer:SetPoint("CENTER", CastingBarFrame, "RIGHT", 12, 0)

		f:HookScript("OnUpdate", function(self, elapsed)
			if CastingBarFrame.timer ~= nil then
				if self.update and self.update < elapsed then
					local name, text, texture = nil, nil, nil
					if UnitCastingInfo ~= nil then
						name, text, texture = UnitCastingInfo("PLAYER")
					end
					if name == nil and UnitChannelInfo ~= nil then
						name, text, texture = UnitChannelInfo("PLAYER")
					end
					if CastingInfo ~= nil then
						name, text, texture = CastingInfo()
					end
					if name == nil and ChannelInfo ~= nil then
						name, text, texture = ChannelInfo()
					end
					
					if MAIBUILD ~= "RETAIL" and texture == 136235 then
						texture = 136243 -- 136192
					end
					if CastingBarFrame.icon ~= nil and CastingBarFrame.icon:GetTexture() ~= texture then
						CastingBarFrame.icon:SetTexture(texture)
					end

					if CastingBarFrame.casting then
						CastingBarFrame.timer:SetText(format("%2.1f", max(CastingBarFrame.maxValue - CastingBarFrame.value, 0)))
					elseif CastingBarFrame.channeling then
						CastingBarFrame.timer:SetText(format("%.1f", max(CastingBarFrame.value, 0)))
					else
						CastingBarFrame.timer:SetText("")
					end
					self.update = 0.1
				else
					self.update = self.update - elapsed
				end
			end
		end)
	end
end
