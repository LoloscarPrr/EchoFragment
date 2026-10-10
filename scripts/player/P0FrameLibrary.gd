class_name P0FrameLibrary
extends RefCounted

const FRAME_COUNTS := {
	&"idle_ready": 10,
	&"run_forward": 10,
	&"jump_start": 3,
	&"jump_rise": 4,
	&"jump_apex": 2,
	&"jump_fall": 3,
	&"land_light": 3,
	&"attack_light": 6,
	&"hit_light": 4
}

const DURATIONS := {
	&"idle_ready": 60,
	&"run_forward": 30,
	&"jump_start": 6,
	&"jump_rise": 12,
	&"jump_apex": 6,
	&"jump_fall": 12,
	&"land_light": 8,
	&"attack_light": 18,
	&"hit_light": 14
}

static func drawing_index(state: StringName, state_tick: int) -> int:
	var count: int = int(FRAME_COUNTS.get(state, 1))
	var duration: int = int(DURATIONS.get(state, 1))
	if count <= 1 or duration <= 1:
		return 0
	var tick := state_tick
	if state == &"idle_ready" or state == &"run_forward" or state == &"jump_rise" or state == &"jump_fall":
		tick = posmod(state_tick, duration)
	else:
		tick = mini(state_tick, duration - 1)
	return mini(count - 1, int(floor(float(tick) * float(count) / float(duration))))

static func pose(state: StringName, drawing: int) -> Dictionary:
	match state:
		&"idle_ready":
			var idle := [
				{"bob":0.0,"lean":0.00,"crouch":0.0,"sword":-0.22,"coat":0.0},
				{"bob":-1.0,"lean":0.01,"crouch":0.0,"sword":-0.20,"coat":1.0},
				{"bob":-1.6,"lean":0.01,"crouch":0.0,"sword":-0.18,"coat":2.0},
				{"bob":-1.0,"lean":0.00,"crouch":0.0,"sword":-0.19,"coat":2.5},
				{"bob":0.0,"lean":-0.01,"crouch":0.0,"sword":-0.22,"coat":1.5},
				{"bob":0.8,"lean":-0.01,"crouch":0.0,"sword":-0.24,"coat":0.0},
				{"bob":1.3,"lean":0.00,"crouch":0.0,"sword":-0.25,"coat":-1.0},
				{"bob":0.8,"lean":0.01,"crouch":0.0,"sword":-0.24,"coat":-1.5},
				{"bob":0.2,"lean":0.01,"crouch":0.0,"sword":-0.23,"coat":-0.5},
				{"bob":0.0,"lean":0.00,"crouch":0.0,"sword":-0.22,"coat":0.0}
			]
			return idle[clampi(drawing,0,idle.size()-1)]
		&"run_forward":
			var phase := float(drawing) / 10.0 * TAU
			return {
				"bob": absf(sin(phase)) * -3.2,
				"lean": 0.13,
				"crouch": absf(sin(phase)) * 2.0,
				"sword": -0.34 + sin(phase) * 0.08,
				"coat": -9.0 + cos(phase) * 6.0,
				"stride": sin(phase) * 10.0
			}
		&"jump_start":
			var poses := [
				{"bob":0.0,"lean":0.06,"crouch":5.0,"sword":-0.28,"coat":1.0},
				{"bob":1.0,"lean":0.10,"crouch":11.0,"sword":-0.34,"coat":3.0},
				{"bob":-2.0,"lean":0.12,"crouch":4.0,"sword":-0.38,"coat":-3.0}
			]
			return poses[clampi(drawing,0,2)]
		&"jump_rise":
			var poses := [
				{"bob":0.0,"lean":0.13,"crouch":0.0,"sword":-0.42,"coat":-8.0},
				{"bob":0.0,"lean":0.14,"crouch":-2.0,"sword":-0.38,"coat":-10.0},
				{"bob":0.0,"lean":0.12,"crouch":-1.0,"sword":-0.34,"coat":-9.0},
				{"bob":0.0,"lean":0.10,"crouch":0.0,"sword":-0.30,"coat":-7.0}
			]
			return poses[clampi(drawing,0,3)]
		&"jump_apex":
			return {"bob":0.0,"lean":0.02 if drawing == 0 else -0.02,"crouch":-2.0,"sword":-0.18,"coat":-3.0}
		&"jump_fall":
			var poses := [
				{"bob":0.0,"lean":-0.04,"crouch":0.0,"sword":-0.12,"coat":5.0},
				{"bob":0.0,"lean":-0.07,"crouch":1.0,"sword":-0.08,"coat":8.0},
				{"bob":0.0,"lean":-0.05,"crouch":3.0,"sword":-0.12,"coat":10.0}
			]
			return poses[clampi(drawing,0,2)]
		&"land_light":
			var poses := [
				{"bob":2.0,"lean":0.06,"crouch":13.0,"sword":-0.18,"coat":5.0},
				{"bob":1.0,"lean":0.03,"crouch":8.0,"sword":-0.20,"coat":2.0},
				{"bob":0.0,"lean":0.00,"crouch":2.0,"sword":-0.22,"coat":0.0}
			]
			return poses[clampi(drawing,0,2)]
		&"attack_light":
			var poses := [
				{"bob":0.0,"lean":-0.08,"crouch":2.0,"sword":-0.55,"coat":2.0,"reach":0.0},
				{"bob":0.0,"lean":-0.13,"crouch":4.0,"sword":-0.92,"coat":4.0,"reach":-2.0},
				{"bob":-1.0,"lean":0.14,"crouch":1.0,"sword":-0.10,"coat":-8.0,"reach":8.0},
				{"bob":-1.0,"lean":0.20,"crouch":0.0,"sword":0.48,"coat":-14.0,"reach":13.0},
				{"bob":0.0,"lean":0.10,"crouch":1.0,"sword":0.30,"coat":-8.0,"reach":7.0},
				{"bob":0.0,"lean":0.02,"crouch":0.0,"sword":-0.12,"coat":-2.0,"reach":1.0}
			]
			return poses[clampi(drawing,0,5)]
		&"hit_light":
			var poses := [
				{"bob":0.0,"lean":-0.22,"crouch":3.0,"sword":-0.05,"coat":8.0},
				{"bob":1.0,"lean":-0.30,"crouch":6.0,"sword":0.02,"coat":12.0},
				{"bob":1.0,"lean":-0.18,"crouch":5.0,"sword":-0.08,"coat":8.0},
				{"bob":0.0,"lean":-0.07,"crouch":2.0,"sword":-0.16,"coat":3.0}
			]
			return poses[clampi(drawing,0,3)]
	return {"bob":0.0,"lean":0.0,"crouch":0.0,"sword":-0.22,"coat":0.0}
