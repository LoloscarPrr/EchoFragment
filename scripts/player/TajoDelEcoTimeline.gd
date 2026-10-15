class_name TajoDelEcoTimeline
extends RefCounted

## Fase 1.1: reference-pose timing bridge for the canonical Portador del Eco.
## Reference frames are NOT production sprites; never draw this atlas in-game.
## The gameplay combat timeline stays at 60Hz / 18 ticks.
const SIMULATION_HZ := 60
const ATTACK_TICKS := 18
const REFERENCE_FRAME_COUNT := 16
const ACTIVE_START_TICK := 5
const ACTIVE_END_TICK := 7
const STRIKE_TICK := 5

## 0-based frame index for each of the 18 gameplay ticks.
## Skipping reference frames preserves the existing fast 0.30s attack.
const FRAME_BY_TICK := [
	0, 1, 2, 3, 4, 6, 8, 10, 11,
	12, 13, 14, 15, 15, 15, 15, 15, 15
]

static func reference_frame_for_tick(tick: int) -> int:
	return int(FRAME_BY_TICK[clampi(tick, 0, ATTACK_TICKS - 1)])

static func phase_for_tick(tick: int) -> StringName:
	if tick < 0:
		return &"not_started"
	if tick < ACTIVE_START_TICK:
		return &"anticipation"
	if tick <= ACTIVE_END_TICK:
		return &"active"
	if tick < ATTACK_TICKS:
		return &"recovery"
	return &"finished"

static func is_active_tick(tick: int) -> bool:
	return tick >= ACTIVE_START_TICK and tick <= ACTIVE_END_TICK

## Player already guards hitbox.strike() with _sword_hit_committed.
## This predicate deliberately stays true AFTER the event tick, so a frame
## skipped during a temporary game lock cannot silently lose the attack.
static func strike_is_ready(tick: int) -> bool:
	return tick >= STRIKE_TICK

static func attack_seconds() -> float:
	return float(ATTACK_TICKS) / float(SIMULATION_HZ)
