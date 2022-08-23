
function MAISetupZoneAbilityFrame()
    hooksecurefunc(ZoneAbilityFrame.Style, "Show", function(self, ...)
        if MAIGV( "ZoneAbilityFrame" .. "hideartwork" ) then
            self:Hide()
        end
    end)
    if MAIGV( "ZoneAbilityFrame" .. "hideartwork" ) then
        ZoneAbilityFrame.Style:Hide()
    end
end