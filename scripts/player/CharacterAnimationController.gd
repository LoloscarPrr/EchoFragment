class_name CharacterAnimationController
extends RefCounted

signal state_changed(state: StringName)

const TICK_RATE := 60.0
const INPUT_BUFFER_TICKS := 6
const COYOTE_TICKS := 5

var state: StringName = &"idle_ready"
var state_tick := 0
var _buffered_actions: Dictionary = {}
var _coyote_ticks_left := 0
var _was_grounded := false
var _land_ticks_left := 0

func tick(is_grounded: bool, velocity: Vector2) -> void:
	_update_buffers()

	if is_grounded:
		_coyote_ticks_left = COYOTE_TICKS
	else:
		_coyote_ticks_left = maxi(0, _coyote_ticks_left - 1)

	if is_grounded and not _was_grounded:
		_land_ticks_left = 8
		set_state(&"land_light")

	if _land_ticks_left > 0:
		_land_ticks_left -= 1
	elif state != &"attack_light" and state != &"hit_light":
		if not is_grounded:
			if velocity.y < -80.0:
				set_state(&"jump_rise")
			elif absf(velocity.y) <= 80.0:
				set_state(&"jump_apex")
			else:
				set_state(&"jump_fall")
		elif absf(velocity.x) > 35.0:
			set_state(&"run_forward")
		else:
			set_state(&"idle_ready")

	state_tick += 1
	_was_grounded = is_grounded

func buffer_action(action: StringName) -> void:
	_buffered_actions[action] = INPUT_BUFFER_TICKS

func consume_buffered(action: StringName) -> bool:
	if not _buffered_actions.has(action):
		return false
	_buffered_actions.erase(action)
	return true

func can_coyote_jump() -> bool:
	return _coyote_ticks_left > 0

func start_jump() -> void:
	set_state(&"jump_start")

func start_light_attack() -> void:
	set_state(&"attack_light")

func start_light_hit() -> void:
	set_state(&"hit_light")

func light_attack_active() -> bool:
	return state == &"attack_light" and state_tick >= 5 and state_tick <= 7

func light_attack_finished() -> bool:
	return state == &"attack_light" and state_tick >= 18

func state_progress() -> float:
	var duration := _duration_for(state)
	if duration <= 0:
		return 0.0
	return clampf(float(state_tick) / float(duration), 0.0, 1.0)

func set_state(next: StringName) -> void:
	if state == next:
		return
	state = next
	state_tick = 0
	state_changed.emit(state)

func _duration_for(value: StringName) -> int:
	match value:
		&"idle_ready": return 60
		&"run_forward": return 30
		&"jump_start": return 6
		&"jump_rise": return 12
		&"jump_apex": return 6
		&"jump_fall": return 12
		&"land_light": return 8
		&"attack_light": return 18
		&"hit_light": return 14
	return 1

func _update_buffers() -> void:
	var expired: Array[StringName] = []
	for key in _buffered_actions.keys():
		var left: int = int(_buffered_actions[key]) - 1
		if left <= 0:
			expired.append(key)
		else:
			_buffered_actions[key] = left
	for key in expired:
		_buffered_actions.erase(key)
