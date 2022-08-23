
function MAISetupFocusFrame()
    if FocusFrame and not FocusFrame:IsShown() then
        FocusFrame:Show()
        FocusFrame:Hide()
    end
    MAIRegisterUIColor(FocusFrameTextureFrameTexture)
end

function MAISetupFocusFrameSpellBar()
	--[[FocusFrameSpellBar.OldSetPoint = FocusFrameSpellBar.SetPoint
	function FocusFrameSpellBar:SetPoint(...)
		--
	end]]
end
