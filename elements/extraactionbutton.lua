
function MAISetupExtraActionButton()
    ExtraActionBarFrame:EnableMouse(false)

    hooksecurefunc(ExtraActionButton1.style, "Show", function(self, ...)
        if MAIGV( "ExtraActionButton1" .. "hideartwork" ) then
            self:Hide()
        end
    end)
    if MAIGV( "ExtraActionButton1" .. "hideartwork" ) then
        ExtraActionButton1.style:Hide()
    end
end