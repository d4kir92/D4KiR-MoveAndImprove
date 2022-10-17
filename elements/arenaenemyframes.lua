
if MAIDEBUG then
	LoadAddOn("Blizzard_ArenaUI") -- DEBUG
end

function MAISetupArenaEnemyFrames()
	ArenaEnemyFrames.OldSetPoint = ArenaEnemyFrames.SetPoint
	function ArenaEnemyFrames:SetPoint(...)
		-- FAKE
	end
	ArenaEnemyFrames.OldClearAllPoints = ArenaEnemyFrames.ClearAllPoints
	function ArenaEnemyFrames:ClearAllPoints()
		-- FAKE
	end

	if MAIDEBUG then

		hooksecurefunc( ArenaEnemyFrames, "Hide", function( self )
			if self.mahide then return end
			self.mahide = true
			self:Show()
			self.mahide = false
		end )
		ArenaEnemyFrames:Show()

		for i = 1, 5 do
			hooksecurefunc( _G["ArenaEnemyFrame" .. i], "Hide", function( self )
				if self.mahide then return end
				self.mahide = true
				self:Show()
				self.mahide = false
			end )
			_G["ArenaEnemyFrame" .. i]:Show()
		end
	end
end

function MAISetupArenaPrepFrames()
	ArenaPrepFrames.OldSetPoint = ArenaPrepFrames.SetPoint
	function ArenaPrepFrames:SetPoint(...)
		-- FAKE
	end
	ArenaPrepFrames.OldClearAllPoints = ArenaPrepFrames.ClearAllPoints
	function ArenaPrepFrames:ClearAllPoints()
		-- FAKE
	end

	if MAIDEBUG then
		hooksecurefunc( ArenaPrepFrames, "Hide", function( self )
			if self.mahide then return end
			self.mahide = true
			self:Show()
			self.mahide = false
		end )
		ArenaPrepFrames:Show()

		for i = 1, 5 do
			hooksecurefunc( _G["ArenaPrepFrame" .. i], "Hide", function( self )
				if self.mahide then return end
				self.mahide = true
				self:Show()
				self.mahide = false
			end )
			_G["ArenaPrepFrame" .. i]:Show()
		end
	end
end
