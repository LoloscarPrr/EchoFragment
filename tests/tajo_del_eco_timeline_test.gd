extends SceneTree
## Offline-safe Godot 4.3 headless smoke test:
## godot --headless --path . --script res://tests/tajo_del_eco_timeline_test.gd
var failures := 0

func _check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error("[Tajo del Eco] FAIL: " + description)

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	_check(TajoDelEcoTimeline.ATTACK_TICKS == 18, "unchanged attack duration")
	_check(is_equal_approx(TajoDelEcoTimeline.attack_seconds(), 0.3), "0.30 seconds at 60 Hz")
	_check(TajoDelEcoTimeline.FRAME_BY_TICK.size() == 18, "one mapping per simulation tick")
	_check(TajoDelEcoTimeline.REFERENCE_FRAME_COUNT == 16, "16 source reference poses")
	var previous_frame := -1
	for tick in range(18):
		var frame: int = TajoDelEcoTimeline.reference_frame_for_tick(tick)
		_check(frame >= 0 and frame < 16, "reference frame in bounds at tick " + str(tick))
		_check(frame >= previous_frame, "monotonic reference poses at tick " + str(tick))
		previous_frame = frame
		_check(TajoDelEcoTimeline.is_active_tick(tick) == (tick >= 5 and tick <= 7), "active hit window at tick " + str(tick))
		_check(TajoDelEcoTimeline.strike_is_ready(tick) == (tick >= 5), "single-strike threshold at tick " + str(tick))
	_check(TajoDelEcoTimeline.phase_for_tick(-1) == &"not_started", "negative tick")
	_check(TajoDelEcoTimeline.phase_for_tick(0) == &"anticipation", "startup phase")
	_check(TajoDelEcoTimeline.phase_for_tick(5) == &"active", "first hit tick phase")
	_check(TajoDelEcoTimeline.phase_for_tick(7) == &"active", "last hit tick phase")
	_check(TajoDelEcoTimeline.phase_for_tick(8) == &"recovery", "recovery phase")
	_check(TajoDelEcoTimeline.phase_for_tick(18) == &"finished", "attack finished")
	_check(TajoDelEcoTimeline.reference_frame_for_tick(18) == 15, "last frame holds after duration")
	var controller := CharacterAnimationController.new()
	_check(controller.attack_reference_frame_index() == -1, "reference atlas disabled when idle")
	controller.start_light_attack()
	_check(controller.attack_reference_frame_index() == 0, "starts at frame zero")
	for tick in range(1, 19):
		controller.tick(true, Vector2.ZERO)
		_check(controller.state_tick == tick, "controller tick increments during attack: " + str(tick))
		_check(controller.attack_reference_frame_index() == TajoDelEcoTimeline.reference_frame_for_tick(tick), "controller frame matches atlas at tick " + str(tick))
		_check(controller.light_attack_active() == (tick >= 5 and tick <= 7), "controller gameplay hit window unchanged at tick " + str(tick))
	_check(controller.light_attack_finished(), "controller attack finishes at 18 ticks")
	if failures == 0:
		print("[Tajo del Eco] PASS: 18-tick bridge, 16 poses, startup/active/recovery, and controller sync")
	quit(1 if failures > 0 else 0)
