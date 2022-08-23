
local oldcou = -1

StanceBar = CreateFrame( "FRAME", "StanceBar", UIParent)
StanceBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 100)

function UpdateStanceBarSize()
	local cou = 0
	if GetNumShapeshiftForms() > 0 then
		cou = GetNumShapeshiftForms()
	else
		cou = NUM_STANCE_SLOTS
	end

	StanceBar:SetSize(StanceButton1:GetWidth() * cou, StanceButton1:GetHeight())
	StanceBar:SetPoint("CENTER", UIParent, "CENTER")
	for i = 1, 9 do
		local stancebtn = _G["StanceButton" .. i]
		stancebtn:SetParent(StanceBar)
		
		if MAIGV( "StanceBar" .. "hide" ) and _G["StanceButton" .. i .. "Cooldown"] then
			_G["StanceButton" .. i .. "Cooldown"]:SetDrawBling(false)
		end

		if i == 1 then
			hooksecurefunc(stancebtn, "SetPoint", function(self, ...)
				if self.setpoint then return end
				self.setpoint = true
				self:ClearAllPoints()
				self:SetPoint("TOPLEFT", StanceBar, "TOPLEFT", (i - 1) * self:GetWidth(), 0)
				self.setpoint = false
			end)
		end
		stancebtn:SetPoint("LEFT", StanceBar, "LEFT", (i - 1) * stancebtn:GetWidth(), 0)

		if cou == 10 then
			stancebtn:SetParent(MAIHIDDEN)
		else
			stancebtn:SetParent(StanceBar)
		end
	end

	MAIUpdateActionButton()
end

function MAISBThink()
	local cou = 0
	if GetNumShapeshiftForms() > 0 then
		cou = GetNumShapeshiftForms()
	else
		cou = NUM_STANCE_SLOTS
	end
	if cou ~= oldcou then
		oldcou = cou
		UpdateStanceBarSize()
	end

	C_Timer.After(0.1, MAISBThink)
end

function MAISetupStanceBar()
	if StanceBarFrame then
		StanceBarLeft:SetTexture(nil)
		StanceBarMiddle:SetTexture(nil)
		StanceBarRight:SetTexture(nil)
	end

	MAISBThink()

	MAIUpdateActionButton()
end
