class_name BowCharge
extends RefCounted

# Input duration (seconds) converted to a normalized bow tension.
# A short tap fires a normal arrow; holding increases damage and momentum.
const MAX_DURATION := 1.20
const MIN_VISIBLE := 0.06

static func fraction(duration: float) -> float:
	return clampf(maxf(duration, 0.0) / MAX_DURATION, 0.0, 1.0)

static func damage(base_damage: int, fraction_value: float) -> int:
	return base_damage + roundi(30.0 * clampf(fraction_value, 0.0, 1.0))

static func knockback(base_knockback: float, fraction_value: float) -> float:
	return base_knockback + 180.0 * clampf(fraction_value, 0.0, 1.0)

static func speed(base_speed: float, fraction_value: float) -> float:
	return base_speed + 190.0 * clampf(fraction_value, 0.0, 1.0)
