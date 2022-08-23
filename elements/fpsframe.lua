
FPSFrame = CreateFrame( "FRAME", "FPSFrame", UIParent)
FPSFrame:SetSize(100, 20)
FPSFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)

FPSFrame.textfps = FPSFrame:CreateFontString(nil, "ARTWORK")
FPSFrame.textfps:SetSize(0, 15)
FPSFrame.textfps:SetFont(STANDARD_TEXT_FONT, 10, "")
FPSFrame.textfps:SetText("")
FPSFrame.textfps:SetShadowOffset(1, -1)

FPSFrame.textfps:SetPoint("CENTER", FPSFrame, "CENTER", 0, 0)

function MAISetupFPSFrame()
    function MAIFPSThink()
        local mover = _G["FPSFrameMover"]

        if mover then
            local down, up, lagHome, lagWorld = GetNetStats();

            FPSFrame.textfps:SetText(string.format(getglobal("FPS_FORMAT"), GetFramerate()))

            local point, _ , relativePoint = mover:GetPoint()

            if FPSFrame.point ~= point then
                FPSFrame.point = point

                local dist = 10

                FPSFrame.textfps:ClearAllPoints()
                if string.find(point, "RIGHT") then
                    FPSFrame.textfps:SetPoint("RIGHT", FPSFrame, "RIGHT", -dist, 0)
                    FPSFrame.textfps:SetJustifyH("RIGHT")
                elseif string.find(point, "LEFT") then
                    FPSFrame.textfps:SetPoint("LEFT", FPSFrame, "LEFT", dist, 0)
                    FPSFrame.textfps:SetJustifyH("LEFT")
                else
                    FPSFrame.textfps:SetPoint("CENTER", FPSFrame, "CENTER", 0, 0)
                    FPSFrame.textfps:SetJustifyH("CENTER")
                end
            end
            C_Timer.After(0.3, MAIFPSThink)
        else
            C_Timer.After(1, MAIFPSThink)
        end
    end
    MAIFPSThink()
end
