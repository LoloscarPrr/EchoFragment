class_name ProtagonistProxyVisual
extends Node2D

var anim_state: StringName = &"idle_ready"
var facing := 1.0
var state_progress := 0.0
var _time := 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func configure(state: StringName, progress: float, direction: float) -> void:
	anim_state = state
	state_progress = progress
	if direction != 0.0:
		facing = signf(direction)
	queue_redraw()

func _draw() -> void:
	var flip := facing
	var bob := 0.0
	var lean := 0.0
	var crouch := 0.0
	var sword_angle := -0.18
	var sword_offset := Vector2(16.0 * flip, -8.0)
	var coat_swing := 0.0

	match anim_state:
		&"idle_ready":
			bob = sin(_time * 4.0) * 1.2
			coat_swing = sin(_time * 3.2) * 3.0
		&"run_forward":
			bob = sin(_time * 12.0) * 3.0
			lean = 0.14 * flip
			coat_swing = -10.0 * flip + sin(_time * 12.0) * 4.0
		&"jump_start":
			crouch = 10.0
			lean = 0.10 * flip
		&"jump_rise":
			lean = 0.12 * flip
			coat_swing = -8.0 * flip
		&"jump_apex":
			coat_swing = -4.0 * flip
		&"jump_fall":
			lean = -0.06 * flip
			coat_swing = 8.0 * flip
		&"land_light":
			crouch = 12.0 * (1.0 - state_progress)
		&"attack_light":
			var p := state_progress
			if p < 0.23:
				sword_angle = -0.70
				lean = -0.10 * flip
			elif p < 0.45:
				sword_angle = 0.55
				lean = 0.18 * flip
			else:
				sword_angle = lerpf(0.55, -0.18, (p - 0.45) / 0.55)
			coat_swing = -12.0 * flip
		&"hit_light":
			lean = -0.18 * flip
			crouch = 4.0

	position.y = bob
	rotation = lean

	var dark := Color("#1E2028")
	var metal := Color("#555B66")
	var wine := Color("#662530")
	var echo := Color("#D93246")
	var skin := Color("#DAB395")

	# Coat tails behind the body.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-15 * flip, 6 + crouch),
		Vector2(-7 * flip, 24 + crouch),
		Vector2((-18 + coat_swing) * flip, 48 + crouch),
		Vector2(-4 * flip, 34 + crouch)
	]), wine)
	draw_colored_polygon(PackedVector2Array([
		Vector2(4 * flip, 8 + crouch),
		Vector2(14 * flip, 22 + crouch),
		Vector2((20 + coat_swing) * flip, 46 + crouch),
		Vector2(7 * flip, 34 + crouch)
	]), wine)

	# Legs.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-13 * flip, 24 + crouch), Vector2(-2 * flip, 24 + crouch),
		Vector2(-6 * flip, 49 + crouch), Vector2(-17 * flip, 49 + crouch)
	]), dark)
	draw_colored_polygon(PackedVector2Array([
		Vector2(2 * flip, 24 + crouch), Vector2(13 * flip, 24 + crouch),
		Vector2(17 * flip, 49 + crouch), Vector2(6 * flip, 49 + crouch)
	]), dark)

	# Torso armor.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-19 * flip, -23 + crouch), Vector2(18 * flip, -23 + crouch),
		Vector2(14 * flip, 26 + crouch), Vector2(-14 * flip, 26 + crouch)
	]), dark)
	draw_polyline(PackedVector2Array([
		Vector2(-15 * flip, -17 + crouch), Vector2(0, -10 + crouch), Vector2(14 * flip, -17 + crouch)
	]), metal, 4.0)

	# Head / hair silhouette.
	draw_circle(Vector2(0, -38 + crouch), 12.0, skin)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-13, -43 + crouch), Vector2(-8, -54 + crouch), Vector2(-2, -48 + crouch),
		Vector2(4, -56 + crouch), Vector2(8, -47 + crouch), Vector2(14, -50 + crouch),
		Vector2(11, -34 + crouch), Vector2(-11, -34 + crouch)
	]), dark)

	# Echo arm.
	draw_line(Vector2(-15 * flip, -10 + crouch), Vector2(-24 * flip, 14 + crouch), metal, 8.0)
	draw_line(Vector2(-24 * flip, 5 + crouch), Vector2(-25 * flip, 14 + crouch), echo, 3.0)
	draw_circle(Vector2(-25 * flip, 14 + crouch), 3.5, echo)

	# Sword arm.
	draw_line(Vector2(15 * flip, -10 + crouch), sword_offset + Vector2(2 * flip, 5 + crouch), metal, 8.0)
	var hilt := sword_offset + Vector2(0, crouch)
	var blade_len := 66.0
	var dir := Vector2(cos(sword_angle) * flip, sin(sword_angle))
	var tip := hilt + dir * blade_len
	draw_line(hilt, tip, Color(0.72, 0.77, 0.82), 6.0)
	draw_line(hilt - Vector2(0, 7), hilt + Vector2(0, 7), metal, 4.0)
	draw_circle(hilt, 3.0, echo)

	# Broken circular brooch.
	draw_arc(Vector2(0, -13 + crouch), 5.0, -2.7, 2.2, 14, echo, 2.0)
