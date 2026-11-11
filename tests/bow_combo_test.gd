extends SceneTree

func _initialize() -> void:
	# First close-range press is an arrow held as a short melee weapon.
	assert(BowCombo.next_step(0, 10.0, -1.0, true) == BowCombo.ARROW_STAB)
	# Follow-up works even after the kick has pushed an enemy farther away.
	assert(BowCombo.next_step(1, 10.3, 11.0, false) == BowCombo.PUSH_KICK)
	assert(BowCombo.next_step(2, 10.7, 11.3, false) == BowCombo.FINISHER_SHOT)
	# Expired chains start over, rather than firing the finisher for free.
	assert(BowCombo.next_step(2, 12.0, 11.0, false) == BowCombo.DIRECT_SHOT)
	assert(BowCombo.next_step(1, 12.0, 11.0, true) == BowCombo.ARROW_STAB)
	# Normal bow firing is unchanged when the target is far away.
	assert(BowCombo.next_step(0, 10.0, -1.0, false) == BowCombo.DIRECT_SHOT)
	# Proximity is facing-aware, and does not trigger behind the player.
	assert(BowCombo.is_target_close(Vector2(80, 10), 1.0, 112.0))
	assert(BowCombo.is_target_close(Vector2(-80, -10), -1.0, 112.0))
	assert(not BowCombo.is_target_close(Vector2(-80, 0), 1.0, 112.0))
	assert(not BowCombo.is_target_close(Vector2(200, 0), 1.0, 112.0))
	assert(not BowCombo.is_target_close(Vector2(55, 150), 1.0, 112.0))
	print("BowCombo assertions passed")
	quit(0)
