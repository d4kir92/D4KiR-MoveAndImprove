
function MAISetupPlayerFrame()
	if PlayerFrame and not PlayerFrame:IsShown() then
		PlayerFrame:Show()
		PlayerFrame:Hide()
	end
	if PlayerFrameTexture then
		hooksecurefunc(PlayerFrameTexture, "SetVertexColor", function(self, ...)
			if self.maisetvertexcolor then return end
			self.maisetvertexcolor = true
			if MAIGV( "UIColorEnabled", true ) then
				self:SetVertexColor(MAIGetUIColor())
			end
			self.maisetvertexcolor = false
		end )
		MAIRegisterUIColor(PlayerFrameTexture)
	end
	MAIRegisterUIColor( PetFrameTexture )

	if MAIGV( "PlayerFrame" .. "groupindicator" ) == nil then
		MAISV( "PlayerFrame" .. "groupindicator", true )
	end
	if PlayerFrameGroupIndicator then
		hooksecurefunc(PlayerFrameGroupIndicator, "Show", function(self)
			if not MAIGV( "PlayerFrame" .. "groupindicator" ) then
				PlayerFrameGroupIndicator:Hide()
			end
		end)
		if not MAIGV( "PlayerFrame" .. "groupindicator" ) then
			PlayerFrameGroupIndicator:Hide()
		end
	end

	if MAIGV( "PlayerFrame" .. "showtotemtimer" ) == nil then
		MAISV( "PlayerFrame" .. "showtotemtimer", false )
	end
	if TotemFrame then
		hooksecurefunc( TotemFrame, "Show", function(self)
			if not MAIGV( "PlayerFrame" .. "showtotemtimer" ) then
				TotemFrame:Hide()
			end
		end )
	
		if not MAIGV( "PlayerFrame" .. "showtotemtimer" ) then
			TotemFrame:Hide()
		end
	end

	if not MAIGV( "PlayerFrame" .. "showpvpicon", true ) then
		PlayerPVPIcon:SetParent( MAIHIDDEN )
	end

	MAIRegisterUIColor(PlayerFrameTexture)
end

for i = 1, 4 do
	_G["MAISetup" .. "PartyMemberFrame" .. i] = function()
		--[[_G["PartyMemberFrame" .. i].OldSetPoint = _G["PartyMemberFrame" .. i].SetPoint
		_G["PartyMemberFrame" .. i].SetPoint = function( self, ... )
			--
		end]]
	end
end
