
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

		ArenaEnemyFrames.Hide = ArenaEnemyFrames.Show
		ArenaEnemyFrames:Show()

		for i = 1, 5 do
			_G["ArenaEnemyFrame" .. i].Hide = _G["ArenaEnemyFrame" .. i].Show
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
		ArenaPrepFrames.Hide = ArenaPrepFrames.Show
		ArenaPrepFrames:Show()

		for i = 1, 5 do
			_G["ArenaPrepFrame" .. i].Hide = _G["ArenaPrepFrame" .. i].Show
			_G["ArenaPrepFrame" .. i]:Show()
		end
	end
end
