
MAIMicroButtons = CreateFrame( "FRAME", "MAIMicroButtons", UIParent)
MAIMicroButtons:SetSize((CharacterMicroButton:GetWidth() - 4) * getn(MICRO_BUTTONS), CharacterMicroButton:GetHeight())
MAIMicroButtons:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
--MAIMicroButtons:SetMovable(true)
--MAIMicroButtons:SetUserPlaced(true)

function MAIUpdateMAIMicroButtons()
	if MAIMicroButtons.once then return end
	MAIMicroButtons.once = true

	if MAIGV( "MAIMicroButtons" .. "Enabled" ) then
		if MAIGV( "MAIMicroButtons" .. "rows" ) == nil then
			MAISV( "MAIMicroButtons" .. "rows", 1 )
		end
		if MAIGV( "MAIMicroButtons" .. "spacing" ) == nil then
			MAISV( "MAIMicroButtons" .. "spacing", -4 )
		end

		local tabLen = getn(MICRO_BUTTONS)
		MAISV( "MAIMicroButtons" .. "count", tabLen )

		if tabLen % 2 ~= 0 then
			--tabLen = tabLen - 1
		end

		local rows = tabLen
		if type( MAIGV( "MAIMicroButtons" .. "rows" ) ) ~= "string" then
			rows = MAIGV( "MAIMicroButtons" .. "rows" )
		end

		local c = tabLen / rows
		local spacing = MAIGV( "MAIMicroButtons" .. "spacing" )
		local w = _G["CharacterMicroButton"]:GetWidth() * c + spacing * (c - 1)
		local h = _G["CharacterMicroButton"]:GetHeight() * (tabLen / c) + spacing * (tabLen / c - 1)
		if MAIBUILD ~= "RETAIL" then
			h = _G["CharacterMicroButton"]:GetHeight() * 0.60 * (tabLen / c) + spacing * (tabLen / c - 1)
		end

		MAIMicroButtons:SetSize(w, h)

		MAISV( "MAIMicroButtons" .. "row", 0 )
		if MAIGV( "MAIMicroButtons" .. "move" ) then
			for i, v in pairs(MICRO_BUTTONS) do
				local microbtn = _G[v]
				microbtn:SetParent(MAIMicroButtons)
				if microbtn.OldSetPoint ~= nil then
					microbtn:SetMovable(true)
					--microbtn:SetUserPlaced(true)
					if (i-1) % (tabLen / rows) == 0 and i ~= 1 then
						MAISV( "MAIMicroButtons" .. "row", MAIGV( "MAIMicroButtons" .. "row" ) + 1 )
						microbtn:OldClearAllPoints()
						local first = MICRO_BUTTONS[1]
						if MAIBUILD ~= "RETAIL" then
							microbtn:OldSetPoint("LEFT", _G[first], "RIGHT", -microbtn:GetWidth(), -(MAIGV( "MAIMicroButtons" .. "row" ) * microbtn:GetHeight() * 0.60 + (MAIGV( "MAIMicroButtons" .. "row" ) ) * MAIGV( "MAIMicroButtons" .. "spacing" ) ))
						else
							microbtn:OldSetPoint("LEFT", _G[first], "RIGHT", -microbtn:GetWidth(), -(MAIGV( "MAIMicroButtons" .. "row" ) * microbtn:GetHeight() + (MAIGV( "MAIMicroButtons" .. "row" ) ) * MAIGV( "MAIMicroButtons" .. "spacing" ) ))
						end
					elseif i ~= 1 then
						microbtn:OldClearAllPoints()
						microbtn:OldSetPoint("LEFT", MICRO_BUTTONS[i - 1], "RIGHT", MAIGV( "MAIMicroButtons" .. "spacing" ), 0)
					end
					microbtn:Show()
				end
			end
		end
	end
	
	if MAIGV( "MAIMicroButtons" .. "hide" ) then
		for i, v in pairs(MICRO_BUTTONS) do
			local btn = _G[v]
			if btn then
				btn:SetParent(MAIHIDDEN)
			end
		end
	end

	MAIMicroButtons.once = false
end

hooksecurefunc(MAIMicroButtons, "SetPoint", function(self, ...)
	MAIUpdateMAIMicroButtons()
end)

hooksecurefunc(MAIMicroButtons, "SetPoint", function(self, ...)
	MAIUpdateMAIMicroButtons()
end)

hooksecurefunc(MAIMicroButtons, "SetSize", function(self, ...)
	MAIUpdateMAIMicroButtons()
end)

hooksecurefunc(_G["CharacterMicroButton"], "SetPoint", function(self, ...)
	MAIUpdateMAIMicroButtons()
end)

hooksecurefunc(_G["CharacterMicroButton"], "SetScale", function(self, ...)
	MAIUpdateMAIMicroButtons()
end)

hooksecurefunc(_G["CharacterMicroButton"], "SetSize", function(self, ...)
	MAIUpdateMAIMicroButtons()
end)



function MAISetupMAIMicroButtons()
	if MAIGV( "MAIMicroButtons" .. "spacing" ) == nil then
		MAISV( "MAIMicroButtons" .. "spacing", -4 )
	end

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
			
			if MicroButtonAndBagsBar.MicroBagBar then
				MicroButtonAndBagsBar.MicroBagBar:SetTexture(nil)
			end
		end
	end
	if MainMenuBarPerformanceBarFrame then
		MainMenuBarPerformanceBarFrame:Hide()
	end

	for i, v in pairs(MICRO_BUTTONS) do
		local btn = _G[v]

		if v == "HelpMicroButton" then -- Support auto hides, dont know why
			hooksecurefunc(btn, "Hide", function(self)
				self:Show()
			end)
		end

		btn:SetMovable(true)
		--btn:SetUserPlaced(true)
		btn:SetParent(MAIMicroButtons)
		if btn.OldSetPoint == nil then
			btn.OldSetPoint = btn.SetPoint
			function btn:SetPoint(...)
				-- FAKE
			end
			btn.OldClearAllPoints = btn.ClearAllPoints
			function btn:ClearAllPoints()
				-- FAKE
			end
		end
		if i == 1 then
			hooksecurefunc(btn, "SetPoint", function(self, ...)
				if self.setpoint then return end
				self.setpoint = true

				self:SetMovable(true)
				--self:SetUserPlaced(true)
				self:OldClearAllPoints()
				if MAIBUILD == "RETAIL" then
					self:OldSetPoint("TOPLEFT", MAIMicroButtons, "TOPLEFT", (i - 1) * (self:GetWidth() - 4), 0)
				else
					self:OldSetPoint("TOPLEFT", MAIMicroButtons, "TOPLEFT", (i - 1) * (self:GetWidth() - 4), 21)
				end
				self.setpoint = false
			end)
		end
		btn:SetPoint("LEFT", MAIMicroButtons, "LEFT", (i - 1) * (btn:GetWidth() - 4), 0)
	end

	MAIUpdateMAIMicroButtons()
end
