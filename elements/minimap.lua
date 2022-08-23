
function MAIIsCustomMinimapLoaded()
	if IsAddOnLoaded("SexyMap") then
		return true
	end
	return false
end

local ranges = {
	[0] = 233,
	[1] = 200,
	[2] = 166 + 2/3,
	[3] = 133 + 1/6,
	[4] = 100,
	[5] = 66 + 2/3
}

local maimmbtnsaddo = {}
local maimmbtnsbliz = {}

local iconsize = 24
local iconborder = 6

function GetMinimapShape()
	if not MAIIsCustomMinimapLoaded() then
		if MAIGV( "Minimap" .. "form" ) ~= nil then
			if MAIGV( "Minimap" .. "form" ) == "round" or MAIGV( "nochanges" ) then
				return 'ROUND'
			else
				return 'SQUARE'
			end
		else
			return 'ROUND'
		end
	end
end

function MAICreateMinimapButtonsFrame()
	minimapbuttons = CreateFrame( "FRAME", "minimapbuttons")

	local icon = nil
	if MAIGV( "mmicon" ) == nil then
		MAIGV( "mmicon", {} )
	end
	function ToggleMinimapButton()
		MAIGV( "mmicon" )["hide"] = not MAIGV( "mmicon" )["hide"]
		if icon then
			if MAIGV( "mmicon" )["hide"] then
				icon:Hide("Move_And_Improve")
			else
				icon:Show("Move_And_Improve")
			end
		end
	end
	local Move_And_Improve = LibStub("LibDataBroker-1.1"):NewDataObject("Move_And_Improve", {
		type = "data source",
		text = "Move_And_Improve",
		icon = 136222,
		OnClick = function(self, btn)
			if btn == "LeftButton" then
				MAIToggleMenu()
			elseif IsShiftKeyDown() and btn == "RightButton" then
				ToggleMinimapButton()
			end
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine("Move And Improve")
			tooltip:AddLine("LeftClick = Toggle MAI Menu")
			tooltip:AddLine("Shift + RightClick = Hide Minimap Button")
		end,
	})
	if Move_And_Improve then
		icon = LibStub("LibDBIcon-1.0", true)
		if icon then
			icon:Register("Move_And_Improve", Move_And_Improve, MAIGV( "mmicon" ))
		end
	end
	


	if not InCombatLockdown() then
		-- Hide Icons
		local mmdebug_design = false
		local mmdebug_hover = false
		local maimmdir = 0
		local maichilds = 0
		tinsert(maimmbtnsbliz, MAIToggler)
		tinsert(maimmbtnsbliz, MinimapAddonsToggler)

		if MAIGV( "Minimap" .. "hideminimapbuttons" ) == nil then
			MAISV( "Minimap" .. "hideminimapbuttons", true )
		end

		if mmdebug_design then
			if MiniMapMailFrame then
				MiniMapMailFrame.Hide = MiniMapMailFrame.Show
				MiniMapMailFrame:Show()
			end

			if MiniMapTracking then
				MiniMapTracking.Hide = MiniMapTracking.Show
				MiniMapTracking:Show()
			end
			if MiniMapTrackingFrame then
				MiniMapTrackingFrame.Hide = MiniMapTrackingFrame.Show
				MiniMapTrackingFrame:Show()
			end

			if QueueStatusMinimapButton then
				QueueStatusMinimapButton.Hide = QueueStatusMinimapButton.Show
				QueueStatusMinimapButton:Show()
			end
		end

		if MAIGV( "minimapbuttons" .. "Enabled" ) then
			minimapbuttons:SetSize(30 * 6, 30 * 2)
			minimapbuttons:SetPoint("CENTER")
	
			minimapbuttonsdyn = CreateFrame( "FRAME", "minimapbuttonsdyn", minimapbuttons)
			minimapbuttonsdyn:SetSize(30 * 6, 30 * 2)
			minimapbuttonsdyn:SetPoint("CENTER", minimapbuttons, "CENTER", 0, 0)
	
			minimapbuttonsdyn.texture = minimapbuttonsdyn:CreateTexture(nil, "BACKGROUND")
			minimapbuttonsdyn.texture:SetAllPoints(minimapbuttonsdyn)
			minimapbuttonsdyn.texture:SetColorTexture(0, 0, 0, 0.2)

			minimapbuttonsdynborder = CreateFrame( "FRAME", "minimapbuttonsdynborder", minimapbuttonsdyn)
			minimapbuttonsdynborder:SetSize(30 * 6, 30 * 2)
			minimapbuttonsdynborder:SetPoint("CENTER", minimapbuttonsdyn, "CENTER", 0, 0)
				
			minimapbuttonsdyn.alpha = 1

			function MAIIsMMBTNSVisible()
				local visible = false
				if MouseIsOver(minimapbuttonsdyn) then
					minimapbuttonsdyn.alpha = 1
				elseif MouseIsOver(minimapbuttonsdynborder) then
					minimapbuttonsdyn.alpha = minimapbuttonsdyn.alpha + 0.15
				elseif minimapbuttonsdyn.alpha > 0 then
					minimapbuttonsdyn.alpha = minimapbuttonsdyn.alpha - 0.05
				end

				if minimapbuttonsdyn.alpha > 1 then
					minimapbuttonsdyn.alpha = 1
				elseif minimapbuttonsdyn.alpha < 0 then
					minimapbuttonsdyn.alpha = 0
				end

				if minimapbuttonsdyn:GetAlpha() ~= minimapbuttonsdyn.alpha then
					minimapbuttonsdyn:SetAlpha(minimapbuttonsdyn.alpha)

					C_Timer.After(0.06, MAIIsMMBTNSVisible)
				else
					C_Timer.After(0.3, MAIIsMMBTNSVisible)
				end
			end
			MAIIsMMBTNSVisible()
			
			local maicount = 0
			function MAIThinkMinimapButtons()
				if minimapbuttonsMover then

					maicount = maicount + 1
					
					local p1, p2, p3, p4, p5 = minimapbuttonsMover:GetPoint()
					for i, child in pairs({Minimap:GetChildren()}) do
						if type(child:GetName()) == "string" and strfind(child:GetName(), "LibDBIcon") and not strfind(child:GetName(), "Move_And_Improve") then
							if not tContains(maimmbtnsaddo, child) then
								tinsert(maimmbtnsaddo, child)
							end
						end
					end
					local ydir = -30
					if p1 == "BOTTOMLEFT" or p1 == "BOTTOMRIGHT" or p1 == "BOTTOM" then
						ydir = 30
					end
					if maichilds ~= getn(maimmbtnsaddo) or maimmdir ~= ydir then
						maichilds = getn(maimmbtnsaddo)
						maimmdir = ydir
		
						local x = 0
						local rows = (getn(maimmbtnsbliz) + getn(maimmbtnsaddo)) / 6
						local rmod = (1 - rows % 1)
						if rmod ~= 1 then
							rows = rows + rmod
						end
						local y = 0
						if ydir > 0 then
							y = (rows - 1) * -30
						end
		
						for i, v in pairs(maimmbtnsbliz) do
							v:SetSize(26, 26)
							v:SetParent(minimapbuttonsdyn)
							v:ClearAllPoints()
							v:SetPoint("TOPLEFT", minimapbuttonsdyn, "TOPLEFT", x, y)
		
							x = x + 30
							if x + 30 > 30 * 6 then
								x = 0
								y = y + ydir
							end
						end
						for i, v in pairs(maimmbtnsaddo) do
							v:SetSize(26, 26)
							v:SetParent(minimapbuttonsdyn)
							v:ClearAllPoints()
							v:SetPoint("TOPLEFT", minimapbuttonsdyn, "TOPLEFT", x, y)
		
							x = x + 30
							if x + 30 > 30 * 6 then
								x = 0
								y = y + ydir
							end
						end

						local sw = 30 * 6
						local sh = math.abs(rows * ydir)

						minimapbuttonsdyn:SetSize(sw, sh)
						minimapbuttonsdynborder:SetSize(sw + 300, sh + 400)

						if ydir < 0 then
							minimapbuttonsdyn:ClearAllPoints()
							minimapbuttonsdyn:SetPoint("TOP", minimapbuttons, "TOP", 0, 0)
						else
							minimapbuttonsdyn:ClearAllPoints()
							minimapbuttonsdyn:SetPoint("BOTTOM", minimapbuttons, "BOTTOM", 0, 0)
						end
					end
				end

				if maicount < 10 then
					C_Timer.After(1, MAIThinkMinimapButtons)
				end
			end
			MAIThinkMinimapButtons()
		elseif MAIGV( "Minimap" .. "improvements" ) and MAIGV( "Minimap" .. "hideminimapbuttons" ) and not MAIGV( "nochanges" ) then
			if MinimapHoverInside == nil then
				local ie = 22
				local br = 52
				MinimapHoverInside = CreateFrame( "FRAME", "MinimapHoverInside", Minimap)
				local sw, sh = Minimap:GetSize()
				MinimapHoverInside:SetSize(sw - ie, sh - ie)
				MinimapHoverInside:SetPoint("CENTER", "Minimap", "CENTER", 0, 0)
	
				if mmdebug_hover then
					MinimapHoverInside.texture = MinimapHoverInside:CreateTexture(nil, "BACKGROUND")
					MinimapHoverInside.texture:SetAllPoints(MinimapHoverInside)
					MinimapHoverInside.texture:SetColorTexture(1, 0, 0, 1)
				end
	
				MinimapHoverBorder = CreateFrame( "FRAME", "MinimapHoverBorder", Minimap)
				local sw, sh = Minimap:GetSize()
				MinimapHoverBorder:SetSize(sw + br, sh + br)
				MinimapHoverBorder:SetPoint("CENTER", "Minimap", "CENTER", 0, 0)
	
				if mmdebug_hover then
					MinimapHoverBorder.texture = MinimapHoverBorder:CreateTexture(nil, "BACKGROUND")
					MinimapHoverBorder.texture:SetAllPoints(MinimapHoverBorder)
					MinimapHoverBorder.texture:SetColorTexture(0, 1, 0, 0.5)
				end
			end
			function MAIIsMMBTNSVisible()
				local visible = false
				if not MouseIsOver(MinimapHoverInside) and MouseIsOver(MinimapHoverBorder) then
					visible = true
				end
				for i, v in pairs(maimmbtnsaddo) do
					if v.isMouseDown or MouseIsOver(v) then
						visible = true
					end
				end
				return visible
			end
	
	
			function MAIThinkMinimapButtons()
				local overminimap = false
				local px, py = Minimap:GetPoint()
				
				if maichilds ~= getn({Minimap:GetChildren()}) then
					maichilds = getn({Minimap:GetChildren()})
					for i, child in pairs({Minimap:GetChildren()}) do
						if type(child:GetName()) == "string" and strfind(child:GetName(), "LibDBIcon") then
							if not tContains(maimmbtnsaddo, child) then
								tinsert(maimmbtnsaddo, child)
							end
						end
					end
				end
				local show = MAIIsMMBTNSVisible()
				for i, v in pairs(maimmbtnsbliz) do
					if show then
						v:SetAlpha(1)
					else
						v:SetAlpha(0)
					end
				end
				for i, v in pairs(maimmbtnsaddo) do
					if show then
						v:SetAlpha(1)
					else
						v:SetAlpha(0)
					end
				end
	
				C_Timer.After(0.1, MAIThinkMinimapButtons)
			end
			MAIThinkMinimapButtons()
		end
	else
		C_Timer.After(1, MAICreateMinimapButtonsFrame)
	end
end

function MAIConvertToMinimapButton( name, hide )
	local btn = _G[name]
	if btn then
		if MAIGV( "nochanges" ) or MAIGV( "minimapbuttons" .. "Enabled" ) then
			tinsert( maimmbtnsbliz, btn )
			return
		end

		if hide then
			tinsert( maimmbtnsbliz, btn )
		end

		btn:SetMovable( true )
		btn:SetUserPlaced( true )
		
		local radius = 76
		function btn:UpdatePos()
			if btn.maiinit == nil then
				btn.maiinit = true
				hooksecurefunc( btn, "SetPoint", function()
					if self.maipoint then return end
					self.maipoint = true

					btn:ClearAllPoints()
					btn:SetPoint( "CENTER", Minimap, "CENTER", MAIGV( name .. "ofsx", radius ), MAIGV( name .. "ofsy", radius ) )

					self.maipoint = false
				end )
				btn:ClearAllPoints()
				btn:SetPoint( "CENTER", Minimap, "CENTER", MAIGV( name .. "ofsx", radius ), MAIGV( name .. "ofsy", radius ) )
			end

			if btn.moving then
				if GetMinimapShape() == "ROUND" then
					local Xpoa, Ypoa = GetCursorPosition()
					local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
					Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
					Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
					myIconPos = math.deg(math.atan2(Ypoa, Xpoa))

					local ofsx = (-80 * cos(myIconPos))
					local ofsy = (80 * sin(myIconPos))

					MAISV( name .. "ofsx", ofsx )
					MAISV( name .. "ofsy", ofsy )

					btn:ClearAllPoints()
					btn:SetPoint( "CENTER", Minimap, "CENTER", ofsx, ofsy )
				else
					local Xpoa, Ypoa = GetCursorPosition()
					local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
					Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
					Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70

					if Ypoa >= radius or Ypoa <= -radius then
						Xpoa = MAIMathC( Xpoa, -radius, radius )
					else
						if Xpoa > 0 then
							Xpoa = radius
						else
							Xpoa = -radius
						end
					end
					if Xpoa >= radius or Xpoa <= -radius then
						Ypoa = MAIMathC( Ypoa, -radius, radius )
					else
						if Ypoa > 0 then
							Ypoa = radius
						else
							Ypoa = -radius
						end
					end
					
					local ofsx = -Xpoa
					local ofsy = Ypoa

					MAISV( name .. "ofsx", ofsx )
					MAISV( name .. "ofsy", ofsy )

					btn:ClearAllPoints()
					btn:SetPoint( "CENTER", Minimap, "CENTER", ofsx, ofsy )
				end
			end

			C_Timer.After( 0.001, btn.UpdatePos )
		end
		btn:UpdatePos()

		btn:RegisterForDrag("LeftButton")
		btn:SetScript( "OnDragStart", function()
			btn:StartMoving()
			btn.moving = true
		end )

		btn:SetScript( "OnDragStop", function()
			btn:StopMovingOrSizing();
			btn.moving = false
		end )
	end
end

function MAISetupMinimap()
	if MAIGV( "Minimap" .. "range" ) == nil then
		MAISV( "Minimap" .. "range", false )
	end
	if MAIGV( "Minimap" .. "minimapbuttons" ) == nil then
		MAISV( "Minimap" .. "minimapbuttons", true )
	end



	-- Blizzard Minimap Buttons Dragging, Fix
	if MiniMapWorldMapButton then
		if MiniMapWorldMapButton:GetNormalTexture():GetTexture() == 452113 then -- "Interface\\minimap\\UI-Minimap-WorldMapSquare"
			MiniMapWorldMapButton:SetNormalTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\minimap\\UI-Minimap-WorldMapSquare" )
			MiniMapWorldMapButton:SetPushedTexture( "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\minimap\\UI-Minimap-WorldMapSquare" )
		end
	end
	if MiniMapTracking and MiniMapTrackingButton then
		MiniMapTrackingButton:ClearAllPoints()
		MiniMapTrackingButton:SetPoint( "CENTER", Minimap, "CENTER", 0, 0 )
		if MAIGV( "minimapbuttons" .. "Enabled" ) then
			MiniMapTrackingButton:SetParent( Minimap )
		end

		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint( "CENTER", MiniMapTrackingButton, "CENTER", 0, 0 )
		if MAIGV( "minimapbuttons" .. "Enabled" ) then
			MiniMapTracking:SetParent( MiniMapTrackingButton )
		end
	end



	-- Blizzard Minimap Buttons Dragging
	-- ALL
	MAIConvertToMinimapButton( "MiniMapWorldMapButton", true ) -- WorldMap
	MAIConvertToMinimapButton( "MiniMapMailFrame" ) -- Mail

	-- Retail
	MAIConvertToMinimapButton( "MiniMapTrackingButton" ) -- Tracking
	MAIConvertToMinimapButton( "GameTimeFrame", true ) -- Calendar
	MAIConvertToMinimapButton( "GarrisonLandingPageMinimapButton" ) -- Sanctum
	MAIConvertToMinimapButton( "QueueStatusMinimapButton" ) -- LFG

	-- Classic (TBC)
	if MAIBUILD == "TBC" then -- breaks retail if not checked
		MAIConvertToMinimapButton( "MiniMapTracking" ) -- Tracking
	end

	-- Classic ERA
	MAIConvertToMinimapButton( "MiniMapTrackingFrame" ) -- Tracking
	MAIConvertToMinimapButton( "MiniMapLFGFrame" ) -- LFG
	-- Blizzard Minimap Buttons Dragging



	if GameTimeTexture then
		GameTimeTexture.Show = GameTimeTexture.Hide
		GameTimeTexture:Hide()
	end

	if not MAIGV( "nochanges" ) then
		hooksecurefunc(MinimapBorder, "Show", function(self, ...)
			if not MAIGV( "nochanges" ) and MAIGV( "Minimap" .. "hideartwork" ) or MAIBUILD == "RETAIL" or (not MAIGV( "Minimap" .. "hideartwork" ) and MAIGV( "Minimap" .. "form" ) ~= "round") then
				self:Hide()
			end
		end)
		if not MAIGV( "nochanges" ) and MAIGV( "Minimap" .. "hideartwork" ) or MAIBUILD == "RETAIL" or (not MAIGV( "Minimap" .. "hideartwork" ) and MAIGV( "Minimap" .. "form" ) ~= "round") then
			MinimapBorder:Hide()
		elseif not MAIGV( "nochanges" ) then
			MAIRegisterUIColor(MinimapBorder)
		end
		if not MAIGV( "nochanges" ) then
			hooksecurefunc(MinimapBorderTop, "Show", function(self, ...)
				self:Hide()
			end)
			MinimapBorderTop:Hide()
		end
	end

	MinimapBackdrop:ClearAllPoints()
	MinimapBackdrop:SetPoint("CENTER", Minimap, "CENTER", -8, -26)
	MinimapBackdrop:SetParent(Minimap)

	local minimapborderscale = 0.7
	MinimapBorder:ClearAllPoints()
	MinimapBorder:SetPoint("CENTER", Minimap, "CENTER", -11, -31)
	--MinimapBorder:SetParent(Minimap)
	hooksecurefunc(Minimap, "SetScale", function(self, ...)
		if self.setscaleMinimapBorder then return end
		self.setscaleMinimapBorder = true
		MinimapBorder:SetScale(minimapborderscale)
		self.setscaleMinimapBorder = false
	end)
	hooksecurefunc(MinimapBorder, "SetScale", function(self, ...)
		if self.setscaleMinimapBorder then return end
		self.setscaleMinimapBorder = true
		MinimapBorder:SetScale(minimapborderscale)
		self.setscaleMinimapBorder = false
	end)
	MinimapBorder:SetScale(minimapborderscale)

	MinimapBorderTop:ClearAllPoints()
	MinimapBorderTop:SetPoint("CENTER", Minimap, "CENTER", -8, 74)
	MinimapBorderTop:SetParent(Minimap)

	if MinimapZoneTextButton and not MAIGV( "nochanges" ) then
		MinimapZoneTextButton:ClearAllPoints()
		MinimapZoneTextButton:SetPoint("CENTER", Minimap, "CENTER", -8, 76)
	elseif MinimapZoneTextButton then
		MinimapZoneTextButton:ClearAllPoints()
		MinimapZoneTextButton:SetPoint("CENTER", Minimap, "CENTER", -8, 78)
	end

	if MinimapToggleButton then
		MinimapToggleButton:ClearAllPoints()
		MinimapToggleButton:SetPoint("CENTER", Minimap, "TOPRIGHT", 3, 7)
		hooksecurefunc(Minimap, "SetScale", function(self, ...)
			if self.setscaleMinimapToggleButton then return end
			self.setscaleMinimapToggleButton = true
			MinimapToggleButton:SetScale(Minimap:GetScale())
			self.setscaleMinimapToggleButton = false
		end)
		MinimapToggleButton:SetScale(Minimap:GetScale())
		--MinimapToggleButton:SetParent(Minimap)
	end

	if MiniMapChallengeMode ~= nil then
		hooksecurefunc(MiniMapChallengeMode, "SetPoint", function(self, ...)
			if self.setpoint then return end
			self.setpoint = true
			self:ClearAllPoints()
			self:SetScale(1)--/Minimap:GetScale())
			self:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 6, -2)
			self.setpoint = false
		end)
		MiniMapChallengeMode:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	end
	
	if MiniMapInstanceDifficulty ~= nil then
		hooksecurefunc(MiniMapInstanceDifficulty, "SetPoint", function(self, ...)
			if self.setpoint then return end
			self.setpoint = true
			self:ClearAllPoints()
			self:SetScale(1)--/Minimap:GetScale())
			self:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 6, -2)
			self.setpoint = false
		end)
		MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	end

	if GuildInstanceDifficulty ~= nil then
		hooksecurefunc(GuildInstanceDifficulty, "SetPoint", function(self, ...)
			if self.setpoint then return end
			self.setpoint = true
			self:ClearAllPoints()
			self:SetScale(1)--/Minimap:GetScale())
			self:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 6, -2)
			self.setpoint = false
		end)
		GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	end

	if MiniMapBattlefieldFrame then
		hooksecurefunc(MiniMapBattlefieldFrame, "SetPoint", function(self, ...)
			if self.maisetpoint then return end
			self.maisetpoint = true

			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 5 * Minimap:GetScale(), 4 * Minimap:GetScale())
			
			self.maisetpoint = true
		end)
		MiniMapBattlefieldFrame:SetPoint("CENTER", Minimap, "BOTTOMLEFT", 0, 0)
		hooksecurefunc(MiniMapBattlefieldFrame, "SetScale", function(self, ...)
			if self.setscale then return end
			self.setscale = true
			self:SetScale(1 / Minimap:GetScale() * 0.8)
			self.setscale = false
		end)
		MiniMapBattlefieldFrame:SetScale(1)
	end

	if not MAIGV( "nochanges" ) then
		local clocktexture = select(1, TimeManagerClockButton:GetRegions())
		clocktexture:SetTexture(nil)
	end

	hooksecurefunc(MinimapZoneTextButton, "SetPoint", function(self, ...)
		if self.setpoint then return end
		self.setpoint = true
		self:ClearAllPoints()
		self:SetPoint("TOP", Minimap, "TOP", 0, 12)
		self.setpoint = false
	end)
	MinimapZoneTextButton:SetPoint("TOP", Minimap, "TOP", 0, 0)

	if MAIGV( "Minimap" .. "improvements" ) and not MAIGV( "nochanges" ) then
		if Minimap.SetArchBlobRingScalar and Minimap.SetQuestBlobRingScalar then
			Minimap:SetArchBlobRingScalar(0)
			Minimap:SetQuestBlobRingScalar(0)
			Minimap:SetArchBlobRingAlpha(0)
			Minimap:SetQuestBlobRingAlpha(0)
		end

		MinimapThinker = CreateFrame( "FRAME", "MinimapThinker", UIParent)
		function MinimapThinker.Think()
			if ( GetCVar("rotateMinimap") == "1" ) then
				MinimapNorthTag:Show()
			else
				MinimapNorthTag:Hide()
			end

			if not Minimap.range then
				Minimap.range = Minimap:CreateTexture("range", "BORDER")
				Minimap.range:SetPoint("CENTER")

				local tex = "Interface\\AddOns\\D4KiR MoveAndImprove\\media\\minimap\\range"
				
				Minimap.range:SetTexture(tex)
				Minimap.range:SetVertexColor(1.0, 1.0, 1.0, 0.25)
			end

			if MAIGV( "Minimap" .. "range" ) then
				Minimap.range:Show()

				local radius = ranges[Minimap:GetZoom()]

				local range = 100
				local minimapWidth = Minimap:GetWidth()
				local size = minimapWidth * range/radius

				if size > minimapWidth then
					local ratio = minimapWidth/size

					Minimap.range:SetTexCoord(0.5 - ratio/2, 0.5 + ratio/2, 0.5 - ratio/2, 0.5 + ratio/2)
					Minimap.range:SetWidth(minimapWidth)
					Minimap.range:SetHeight(minimapWidth)
				else
					Minimap.range:SetTexCoord(0, 1, 0, 1)
					Minimap.range:SetWidth(size)
					Minimap.range:SetHeight(size)
				end
			else
				Minimap.range:Hide()
			end
			C_Timer.After(0.3, MinimapThinker.Think)
		end
		MinimapThinker.Think()

		hooksecurefunc(MinimapNorthTag, "SetPoint", function(self, ...)
			if self.setpoint then return end
			self.setpoint = true
			self:ClearAllPoints()
			self:SetPoint("TOP", Minimap, "TOP", 0, -1)
			self.setpoint = false
		end)
		MinimapNorthTag:SetPoint("TOP", Minimap, "TOP", 0, 0)

		MinimapCoords = CreateFrame( "FRAME", "MinimapCoords", Minimap)
		MinimapCoords:SetSize(100, 20)

		MinimapCoords.text = MinimapCoords:CreateFontString(nil, "ARTWORK")
		MinimapCoords.text:SetPoint("CENTER", MinimapCoords, "CENTER", 0, 0)
		MinimapCoords.text:SetFont(STANDARD_TEXT_FONT, 10, "")
		MinimapCoords.text:SetShadowOffset(1, -1)
		MinimapCoords.text:SetText("")
		MinimapCoords.text:SetTextColor(0.1, 1.0, 0.1)

		function MinimapCoords.Think()
			local text = ""
			if C_Map then
				local mapID = C_Map.GetBestMapForUnit("player")
				if mapID then
					local mapPos = C_Map.GetPlayerMapPosition(mapID, "player")
					if mapPos then
						local px, py = mapPos:GetXY()
						if px and py then
							px = MAIStringR(px * 100, 1)
							py = MAIStringR(py * 100, 1)

							MinimapCoords.text:SetScale(1 / Minimap:GetScale())

							text = px .. ", " .. py
						end
					end
				end
			end
			MinimapCoords.text:SetText(text)
			C_Timer.After(0.3, MinimapCoords.Think)
		end
		MinimapCoords.Think()

		hooksecurefunc(MinimapCoords, "SetPoint", function(self, ...)
			if self.setpoint then return end
			self.setpoint = true
			self:ClearAllPoints()
			self:SetPoint("TOP", Minimap, "TOP", 0, -1)
			self.setpoint = false
		end)
		MinimapCoords:SetPoint("TOP", Minimap, "TOP", 0, 0)

		function MAIOnMouseWheel(self, dir)
			if (dir > 0) then
				MinimapZoomIn:Click()
			else
				MinimapZoomOut:Click()
			end
		end
		Minimap:EnableMouseWheel()
		Minimap:SetScript('OnMouseWheel', MAIOnMouseWheel)

		MinimapZoomIn:Hide()
		MinimapZoomOut:Hide()

		Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
		hooksecurefunc(Minimap, "SetMaskTexture", function(self, ...)
			if self.setmasktexture then return end
			self.setmasktexture = true
			if MAIGV( "Minimap" .. "form" ) == nil then
				MAISV( "Minimap" .. "form", "paper2" )
			end
			self:SetMaskTexture("Interface\\Addons\\D4KiR MoveAndImprove\\media\\minimap\\minimap_mask_" .. MAIGV( "Minimap" .. "form" ) ) --"Interface\\BUTTONS\\WHITE8X8")	
			self.setmasktexture = false
		end)
		Minimap:SetMaskTexture("")

		TimeManagerClockTicker:SetPoint("CENTER", TimeManagerClockButton, "CENTER", 0, 0)
		if GameTimeFrame.GetFontString ~= nil then
			GameTimeFrame:GetFontString():SetFont(STANDARD_TEXT_FONT, 8)
		end

		-- Mail indicator
		MiniMapMailFrame.text = MiniMapMailFrame:CreateFontString(nil, "ARTWORK")
		MiniMapMailFrame.text:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
		MiniMapMailFrame.text:SetPoint("CENTER", MiniMapMailFrame, "CENTER", 0, 0)
		MiniMapMailFrame.text:SetText("-1")
		function MiniMapMailFrame.Think()
			local n = getn({GetLatestThreeSenders()})
			if n ~= MiniMapMailFrame.n then
				MiniMapMailFrame.n = n
				MiniMapMailFrame.text:SetText(MiniMapMailFrame.n)
				if n == 0 then
					--MiniMapMailFrame:Hide()
				else
					--MiniMapMailFrame:Show()
				end
			end
			
			C_Timer.After(1, MiniMapMailFrame.Think)
		end
		MiniMapMailFrame.Think()
		
		hooksecurefunc(TimeManagerClockButton, "SetPoint", function(self, ...)
			if self.setpoint then return end
			self.setpoint = true
			self:ClearAllPoints()
			self:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 0)
			self.setpoint = false
		end)
		TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 0)

		if MinimapToggleButton then
			MinimapToggleButton:Hide()
		end

		if Minimap.SetArchBlobRingScalar and Minimap.SetQuestBlobRingScalar then
			Minimap:SetArchBlobRingScalar(0)
			Minimap:SetQuestBlobRingScalar(0)
		end

		function MAISearchForHybridMinimap()
			if HybridMinimap ~= nil then
				hooksecurefunc(HybridMinimap.CircleMask, "SetTexture", function(self, ...)
					if self.maisetmasktexture then return end
					self.maisetmasktexture = true
					if MAIGV( "Minimap" .. "form" ) == nil then
						MAISV( "Minimap" .. "form", "paper2" )
					end
					self:SetTexture("Interface\\Addons\\D4KiR MoveAndImprove\\media\\minimap\\minimap_mask_" .. MAIGV( "Minimap" .. "form" ) ) --"Interface\\BUTTONS\\WHITE8X8")	
					self.maisetmasktexture = false
				end)
				C_Timer.After(1, function()
					HybridMinimap.CircleMask:SetTexture("")
				end)
			else
				C_Timer.After(1, MAISearchForHybridMinimap)
			end
		end
		MAISearchForHybridMinimap()
	else
		MinimapZoneTextButton:SetParent(Minimap)
	end
end
