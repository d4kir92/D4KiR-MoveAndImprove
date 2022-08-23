
function MAISetupMirrorTimer1()
    hooksecurefunc(MirrorTimer1Border, "Show", function(self, ...)
        if MAIGV( "MirrorTimer1" .. "hideartwork" ) then
            self:Hide()
        end
    end)
    if MAIGV( "MirrorTimer1" .. "hideartwork" ) then
        MirrorTimer1Border:Hide()
    end
end