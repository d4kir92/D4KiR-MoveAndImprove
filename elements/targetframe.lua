
function MAISetupTargetFrame()
	if TargetFrame and not TargetFrame:IsShown() then
		TargetFrame:Show()
		TargetFrame:Hide()
	end

	MAIRegisterUIColor(TargetFrameTextureFrameTexture)
	MAIRegisterUIColor(TargetFrameToTTextureFrameTexture)
end

function MAISetupTargetFrameToT()
	if TargetFrameToT and not TargetFrameToT:IsShown() then
		TargetFrameToT:Show()
		TargetFrameToT:Hide()
	end
	MAIRegisterUIColor(TargetFrameToTTextureFrameTexture)
end

function MAISetupTargetFrameSpellBar()
	--[[TargetFrameSpellBar.OldSetPoint = TargetFrameSpellBar.SetPoint
	function TargetFrameSpellBar:SetPoint(...)
		--
	end]]

end



-- Fix Blizzard Ui
if TargetFrameHealthBarText == nil and TargetFrameHealthBarTextLeft == nil and TargetFrameHealthBarTextRight == nil and TargetFrameHealthBar.LeftText == nil and TargetFrameHealthBar.RightText == nil then
	TargetFrameTextureFrame:CreateFontString("TargetFrameHealthBarText", "BORDER", "TextStatusBarText")
	TargetFrameHealthBarText:SetPoint("CENTER", TargetFrameTextureFrame, "CENTER", -50, 3)

	TargetFrameTextureFrame:CreateFontString("TargetFrameHealthBarTextLeft", "BORDER", "TextStatusBarText")
	TargetFrameHealthBarTextLeft:SetPoint("LEFT", TargetFrameTextureFrame, "LEFT", 8, 3)

	TargetFrameTextureFrame:CreateFontString("TargetFrameHealthBarTextRight", "BORDER", "TextStatusBarText")
	TargetFrameHealthBarTextRight:SetPoint("RIGHT", TargetFrameTextureFrame, "RIGHT", -110, 3)

	TargetFrameHealthBar.LeftText = TargetFrameHealthBarTextLeft;
	TargetFrameHealthBar.RightText = TargetFrameHealthBarTextRight       

	UnitFrameHealthBar_Initialize("target", TargetFrameHealthBar, TargetFrameHealthBarText, true);
end

if TargetFrameManaBarText == nil and TargetFrameManaBarTextLeft == nil and TargetFrameManaBarTextRight == nil and TargetFrameManaBar.LeftText == nil and TargetFrameManaBar.RightText == nil then
	TargetFrameTextureFrame:CreateFontString("TargetFrameManaBarText", "BORDER", "TextStatusBarText")
	TargetFrameManaBarText:SetPoint("CENTER", TargetFrameTextureFrame, "CENTER", -50, -8)

	TargetFrameTextureFrame:CreateFontString("TargetFrameManaBarTextLeft", "BORDER", "TextStatusBarText")
	TargetFrameManaBarTextLeft:SetPoint("LEFT", TargetFrameTextureFrame, "LEFT", 8, -8)

	TargetFrameTextureFrame:CreateFontString("TargetFrameManaBarTextRight", "BORDER", "TextStatusBarText")
	TargetFrameManaBarTextRight:SetPoint("RIGHT", TargetFrameTextureFrame, "RIGHT", -110, -8)

	TargetFrameManaBar.LeftText = TargetFrameManaBarTextLeft;
	TargetFrameManaBar.RightText = TargetFrameManaBarTextRight;

	UnitFrameManaBar_Initialize("target", TargetFrameManaBar, TargetFrameManaBarText, true);
end
