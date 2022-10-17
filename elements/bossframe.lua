
local MAIBossList = CreateFrame( "FRAME", "MAIBossList", UIParent)
MAIBossList:SetSize(120, 64 + 4 * 98)
MAIBossList:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 100, 100)

function MAISetupBossFrame()
    for i = 1, 5 do
        local bf = _G["Boss" .. i .. "TargetFrame"]
        bf:SetParent(MAIBossList)
    end

    Boss1TargetFrame.OldSetPoint = Boss1TargetFrame.SetPoint
    function Boss1TargetFrame:SetPoint(...)
        -- FAKE
    end
    Boss1TargetFrame.OldClearAllPoints = Boss1TargetFrame.ClearAllPoints
    function Boss1TargetFrame:ClearAllPoints()
        -- FAKE
    end

    Boss1TargetFrame:OldClearAllPoints()
    Boss1TargetFrame:OldSetPoint("TOPLEFT", MAIBossList, "TOPLEFT", 0, 0)

	--[[
		hooksecurefunc( Boss1TargetFrame, "Hide", function( self )
			if self.mahide then return end
			self.mahide = true
			self:Show()
			self.mahide = false
		end )
		Boss1TargetFrame:Show()
	]]
end
