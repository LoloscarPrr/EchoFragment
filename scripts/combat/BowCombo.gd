class_name BowCombo
extends RefCounted

# Pure decision rules for the bow's contextual three-hit sequence.
# Kept independent of the Player to allow headless regression tests.
const DIRECT_SHOT := 0
const ARROW_STAB := 1
const PUSH_KICK := 2
const FINISHER_SHOT := 3

static func next_step(current_step: int, now: float, expires_at: float, close_target: bool) -> int:
	if now <= expires_at:
		if current_step == ARROW_STAB:
			return PUSH_KICK
		if current_step == PUSH_KICK:
			return FINISHER_SHOT
	return ARROW_STAB if close_target else DIRECT_SHOT


static func is_target_close(offset: Vector2, facing: float, max_range: float) -> bool:
	var forward_distance := offset.x * facing
	return forward_distance >= -8.0 and forward_distance <= max_range and absf(offset.y) <= 85.0
