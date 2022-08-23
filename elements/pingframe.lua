
PingFrame = CreateFrame( "FRAME", "PingFrame", UIParent)
PingFrame:SetSize(100, 30)
PingFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -20)

PingFrame.pinghome = PingFrame:CreateFontString(nil, "ARTWORK")
PingFrame.pinghome:SetSize(0, 15)
PingFrame.pinghome:SetFont(STANDARD_TEXT_FONT, 10, "")
PingFrame.pinghome:SetText("")
PingFrame.pinghome:SetShadowOffset(1, -1)

PingFrame.pingworld = PingFrame:CreateFontString(nil, "ARTWORK")
PingFrame.pingworld:SetSize(0, 15)
PingFrame.pingworld:SetFont(STANDARD_TEXT_FONT, 10, "")
PingFrame.pingworld:SetText("")
PingFrame.pingworld:SetShadowOffset(1, -1)

PingFrame.pinghome:SetPoint("CENTER", PingFrame, "CENTER", 0, 5)
PingFrame.pingworld:SetPoint("CENTER", PingFrame, "CENTER", 0, -5)

function MAISetupPingFrame()
    function MAIPingThink()
        local mover = _G["PingFrameMover"]

        if mover then
            local down, up, lagHome, lagWorld = GetNetStats();

            PingFrame.pinghome:SetText(getglobal("SPELL_TARGET_TYPE6_DESC") .. ": " .. lagHome .. "ms")
            PingFrame.pingworld:SetText(getglobal("WORLD") .. ": " .. lagWorld .. "ms")

            local point, _ , relativePoint = mover:GetPoint()

            if PingFrame.point ~= point then
                PingFrame.point = point

                local dist = 8
				if MAIBUILD == "RETAIL" then
					dist = 8
				end

                PingFrame.pinghome:ClearAllPoints()
                PingFrame.pingworld:ClearAllPoints()
                if string.find(point, "RIGHT") then
                    PingFrame.pinghome:SetPoint("RIGHT", PingFrame, "RIGHT", -dist, 5)
                    PingFrame.pingworld:SetPoint("RIGHT", PingFrame, "RIGHT", -dist, -5)
                    PingFrame.pinghome:SetJustifyH("RIGHT")
                    PingFrame.pingworld:SetJustifyH("RIGHT")
                elseif string.find(point, "LEFT") then
                    PingFrame.pinghome:SetPoint("LEFT", PingFrame, "LEFT", dist, 5)
                    PingFrame.pingworld:SetPoint("LEFT", PingFrame, "LEFT", dist, -5)
                    PingFrame.pinghome:SetJustifyH("LEFT")
                    PingFrame.pingworld:SetJustifyH("LEFT")
                else
                    PingFrame.pinghome:SetPoint("CENTER", PingFrame, "CENTER", 0, 5)
                    PingFrame.pingworld:SetPoint("CENTER", PingFrame, "CENTER", 0, -5)
                    PingFrame.pinghome:SetJustifyH("CENTER")
                    PingFrame.pingworld:SetJustifyH("CENTER")
                end
            end
            C_Timer.After(1, MAIPingThink)
        else
            C_Timer.After(2, MAIPingThink)
        end
    end
    MAIPingThink()
end
