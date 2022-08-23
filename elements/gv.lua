
-- Great Vault
GV = CreateFrame("Button", "GV", UIParent)
GV:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -240, 0)
GV.texture = GV:CreateTexture(nil, "BACKGROUND")
GV.texture:SetAllPoints(GV)
GV.texture:SetAtlas("mythicplus-greatvault-complete") --mythicplus-greatvault-collect", TextureKitConstants.UseAtlasSize);
GV:Hide()
function MAISetupGV()
    if MAIBUILD == "RETAIL" then
        GV:SetSize(40, 40)
		GV:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		GV:SetScript("OnClick", function()
			LoadAddOn("Blizzard_WeeklyRewards")
			if WeeklyRewardsFrame:IsShown() then
				WeeklyRewardsFrame:Hide()
			else
				WeeklyRewardsFrame:Show()
			end
		end)
		GV:Show()

		function GV.Think()
			local maxlevel = MAIGetMaxLevel()
			
			if UnitLevel("PLAYER") == maxlevel then
				GV:Show()
			else
				--GV:Hide()
			end

			C_Timer.After(1, GV.Think)
		end
		GV.Think()
	end
end