class_name WeaponActionRules
extends RefCounted

# Pure, frame-rate-independent decisions used by the touch combat controller.
const MAX_BOW_HOLD := 1.30
const FAST_BOW_HOLD := 1.00
const DAGGER_RECHARGE := 3.60
const SWORD_BLOCK_DURATION := 2.0
const STAFF_BARRIER_DURATION := 2.8

static func bow_charge(held_seconds: float, fast_draw: bool = false) -> float:
	var duration := FAST_BOW_HOLD if fast_draw else MAX_BOW_HOLD
	return clampf(held_seconds / duration, 0.0, 1.0)

static func bow_damage(base_damage: int, charge: float) -> int:
	return roundi(float(base_damage) * lerpf(1.0, 2.3, clampf(charge, 0.0, 1.0)))

static func bow_piercing(charge: float, learned_piercing: bool) -> int:
	if charge >= 0.90:
		return 4 if learned_piercing else 3
	return 2 if learned_piercing else 1

static func ready_dagger_slot(ready_at: Array[float], now: float) -> int:
	for index in range(ready_at.size()):
		if now >= ready_at[index]:
			return index
	return -1

static func daggers_available(ready_at: Array[float], now: float) -> int:
	var ready := 0
	for ready_time in ready_at:
		if now >= ready_time:
			ready += 1
	return ready

static func cooldown_remaining(until: float, now: float) -> float:
	return maxf(0.0, until - now)
