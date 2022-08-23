
BagBar = CreateFrame( "FRAME", "BagBar", UIParent)
BagBar:SetSize(36, 36)
BagBar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 36)

local bags = {}
if KeyRingButton ~= nil then
	tinsert(bags, "KeyRingButton")
end
for i = 3, 0, -1 do
	tinsert(bags, "CharacterBag" .. i .. "Slot")
end
tinsert(bags, "MainMenuBarBackpackButton")

local once = false
function MAISetupBagBar()
	if MicroButtonAndBagsBar ~= nil and MainMenuBarBackpackButton ~= nil then
		if MicroButtonAndBagsBar.hooked == nil then
			MicroButtonAndBagsBar.hooked = true
			hooksecurefunc(MicroButtonAndBagsBar, "EnableMouse", function(self)
				if self.enablemouse then return end
				self.enablemouse = true
				self:EnableMouse(false)
				self.enablemouse = false
			end)
			MicroButtonAndBagsBar:EnableMouse(false)

			hooksecurefunc(MicroButtonAndBagsBar, "SetScale", function(self)
				if self.setscale then return end
				self.setscale = true
				self:SetScale(0.0001)
				self.setscale = false
			end)
			MicroButtonAndBagsBar:SetScale(0.0001)

			MicroButtonAndBagsBar.MicroBagBar:SetTexture(nil)
		end
	end
	local BagThinker = CreateFrame( "FRAME", "BagThinker", UIParent)



	if CharacterBag0Slot then
		local BAGThink = CreateFrame("FRAME")
		
		local MAIBagSlots = {
			"MainMenuBarBackpackButton",
			"CharacterBag0Slot",
			"CharacterBag1Slot",
			"CharacterBag2Slot",
			"CharacterBag3Slot"
		}

		for i, slot in pairs(MAIBagSlots) do
			local SLOT = _G[slot]
			if SLOT and SLOT.text == nil then
				SLOT.text = SLOT:CreateFontString(nil, "ARTWORK")
				SLOT.text:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
				SLOT.text:SetPoint("TOP", SLOT, "TOP", 0, -3)
				SLOT.text:SetText("")
			end
		end

		function BAGThink.UpdateItemInfos()
			local sum = 0
			for i, slot in pairs(MAIBagSlots) do
				local SLOT = _G[slot]
				local COUNT = _G[slot .. "Count"]
				if SLOT and SLOT.text ~= nil then
					local numberOfFreeSlots = GetContainerNumFreeSlots(i - 1);
					sum = sum + numberOfFreeSlots
					SLOT.text:SetText(numberOfFreeSlots)
					SLOT.maxDisplayCount = 999999
					COUNT:SetText("")
				end
			end
			if MAIGV( "BagBar" .. "onebag" ) and MAIBUILD ~= "RETAIL" then
				for i, slot in pairs(MAIBagSlots) do
					local SLOT = _G[slot]
					if SLOT and SLOT.text ~= nil and i == 1 then
						SLOT.text:SetText(sum)
					else
						break
					end
				end
			end
		end
		BAGThink.UpdateItemInfos()

		BAGThink:RegisterEvent("BAG_UPDATE")
		BAGThink:SetScript("OnEvent", function(self, event, slotid, ...)
			BAGThink.UpdateItemInfos()
		end)
	end



	if MAIGV( "BagBar" .. "onebag" ) then
		if KeyRingButton then
			BagBar:SetSize(MainMenuBarBackpackButton:GetWidth() + KeyRingButton:GetWidth(), MainMenuBarBackpackButton:GetHeight())
		else
			BagBar:SetSize(MainMenuBarBackpackButton:GetWidth(), MainMenuBarBackpackButton:GetHeight())
		end

		MainMenuBarBackpackButton:SetParent(BagBar)
		hooksecurefunc(MainMenuBarBackpackButton, "SetPoint", function(self, ...)
			if self.setpoint then return end
			self.setpoint = true
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", BagBar, "TOPRIGHT", 0, 0)
			self.setpoint = false
		end)
		MainMenuBarBackpackButton:SetPoint("TOPRIGHT", BagBar, "TOPRIGHT", 0, 0)

		if KeyRingButton then
			for i, v in pairs(bags) do
				if v ~= "MainMenuBarBackpackButton" and v ~= "KeyRingButton" then
					_G[v]:Hide()
				end
			end

			KeyRingButton:SetParent(BagBar)
			hooksecurefunc(KeyRingButton, "SetPoint", function(self, ...)
				if self.setpoint then return end
				self.setpoint = true
				self:ClearAllPoints()
				self:SetPoint("TOPLEFT", BagBar, "TOPLEFT", 0, 0)
				self.setpoint = false
			end)
			KeyRingButton:SetPoint("TOPLEFT", BagBar, "TOPLEFT", 0, 0)
		end
	else
		if KeyRingButton then
			BagBar:SetSize(MainMenuBarBackpackButton:GetWidth() * 5 + KeyRingButton:GetWidth(), MainMenuBarBackpackButton:GetHeight())
		else
			BagBar:SetSize(MainMenuBarBackpackButton:GetWidth() * 5, MainMenuBarBackpackButton:GetHeight())
		end

		local x = 0
		for i, v in pairs(bags) do
			local bagbtn = _G[v]
			bagbtn:SetParent(BagBar)
			local sw, sh = MainMenuBarBackpackButton:GetSize()
			if v ~= "MainMenuBarBackpackButton" and v ~= "KeyRingButton" then
				bagbtn:SetSize(sw, sh)
			end
			if v == "KeyRingButton" then
				hooksecurefunc(bagbtn, "SetPoint", function(self, ...)
					if self.setpoint then return end
					self.setpoint = true
					self:ClearAllPoints()
					self:SetPoint("TOPLEFT", BagBar, "TOPLEFT", x, 0)
					self.setpoint = false
				end)
				bagbtn:SetPoint("TOPLEFT", BagBar, "TOPLEFT", x, 0)
				x = x + bagbtn:GetWidth()
			else
				hooksecurefunc(bagbtn, "SetPoint", function(self, ...)
					if self.setpoint then return end
					self.setpoint = true
					self:ClearAllPoints()
					self:SetPoint("TOPLEFT", BagBar, "TOPLEFT", x, 0)
					self.setpoint = false
				end)
				bagbtn:SetPoint("TOPLEFT", BagBar, "TOPLEFT", x, 0)

				x = x + bagbtn:GetWidth()
			end
		end
	end

	for i, v in pairs(bags) do
		local bag = _G[v]
		function bag.Think()
			if _G[v .. "NormalTexture"] ~= nil and _G[v.."NormalTexture"]:IsShown() then
				local sw, sh = _G[v]:GetSize()
				_G[v .. "NormalTexture"]:SetSize(sw * 1.66, sh * 1.66)

				if _G[v].angularFrame ~= nil then
					_G[v].angularFrame:Hide()
				end
			end
			C_Timer.After(0.5, bag.Think)			
		end
		bag.Think()
	end


	for i, v in pairs(bags) do
		if _G[v .. "NormalTexture"] ~= nil then
			local nt = _G[v.."NormalTexture"]
			hooksecurefunc(nt, "SetVertexColor",function(self)
				if self.setvertexcolor then return end
				self.setvertexcolor = true
				if MAIGV( "UIColorEnabled", true ) then
					self:SetVertexColor(MAIGetUIColor())
				end
				self.setvertexcolor = false
			end)
			MAIRegisterUIColor(nt)
			_G[v].IconBorder:SetParent(MAIHIDDEN)
		end
	end

	-- Masque
	if once == false then
		once = true
		local MSQ = LibStub("Masque", true)

		if MSQ then
			local group = MSQ:Group("MAI Blizzard Bags")
			for i, v in pairs(bags) do
				local btn = _G[v]
				if not btn.MasqueButtonData then
					btn.MasqueButtonData = {
						Button = btn,
						Icon = _G[v .. "IconTexture"],
					}
					group:AddButton(btn, btn.MasqueButtonData, "Item")
				end
			end
		end
	end

	if MAIGV( "BagBar" .. "hide" ) then
		for i, v in pairs(bags) do
			local btn = _G[v]
			if btn then
				btn:SetParent(MAIHIDDEN)
			end
		end
	end
end
