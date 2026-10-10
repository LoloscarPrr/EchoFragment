class_name ProtagonistProxyVisual
extends Node2D

var anim_state: StringName = &"idle_ready"
var facing := 1.0
var state_progress := 0.0
var drawing_index := 0
var _time := 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func configure(state: StringName, progress: float, direction: float, frame_index: int = 0) -> void:
	anim_state = state
	state_progress = progress
	drawing_index = frame_index
	if direction != 0.0:
		facing = signf(direction)
	queue_redraw()

func _draw() -> void:
	var flip: float = facing
	var pose: Dictionary = P0FrameLibrary.pose(anim_state, drawing_index)
	var bob: float = float(pose.get("bob", 0.0))
	var lean: float = float(pose.get("lean", 0.0)) * flip
	var crouch: float = float(pose.get("crouch", 0.0))
	var sword_angle: float = float(pose.get("sword", -0.22))
	var coat_swing: float = float(pose.get("coat", 0.0))
	var reach: float = float(pose.get("reach", 0.0))
	var stride: float = float(pose.get("stride", 0.0))
	var sword_offset := Vector2((16.0 + reach) * flip, -8.0)

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
		Vector2((-13 - stride * 0.25) * flip, 24 + crouch), Vector2(-2 * flip, 24 + crouch),
		Vector2((-6 - stride) * flip, 49 + crouch), Vector2((-17 - stride) * flip, 49 + crouch)
	]), dark)
	draw_colored_polygon(PackedVector2Array([
		Vector2(2 * flip, 24 + crouch), Vector2((13 + stride * 0.25) * flip, 24 + crouch),
		Vector2((17 + stride) * flip, 49 + crouch), Vector2((6 + stride) * flip, 49 + crouch)
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

	# Animated scarf and coat stitching accentuate direction and momentum.
	var flutter := sin(_time * 8.0) * 3.0
	var scarf_pull := -10.0 if anim_state == &"run_forward" else -4.0
	if anim_state == &"jump_rise" or anim_state == &"jump_fall":
		scarf_pull = -13.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(-8 * flip, -20 + crouch),
		Vector2(-17 * flip, -17 + crouch),
		Vector2((scarf_pull - 25.0) * flip, -22 + flutter + crouch),
		Vector2((scarf_pull - 18.0) * flip, -27 + flutter + crouch)
	]), wine)
	draw_line(Vector2(-12 * flip, 14 + crouch), Vector2((-13 + coat_swing) * flip, 37 + crouch), Color(0.57, 0.25, 0.30, 0.78), 2.0)
	draw_line(Vector2(11 * flip, 13 + crouch), Vector2((13 + coat_swing) * flip, 35 + crouch), Color(0.57, 0.25, 0.30, 0.78), 2.0)

	# An arc follows the sword's active attack poses; purely visual, no hitbox change.
	if anim_state == &"attack_light" and drawing_index >= 2 and drawing_index <= 4:
		var arc_alpha := 0.42 if drawing_index == 3 else 0.22
		var center := hilt + Vector2(14.0 * flip, 0)
		draw_arc(center, 67.0, -0.83 if flip > 0 else PI - 0.83, 0.65 if flip > 0 else PI + 0.65, 19, Color(0.93, 0.23, 0.31, arc_alpha), 5.0)
		draw_arc(center, 73.0, -0.52 if flip > 0 else PI - 0.52, 0.35 if flip > 0 else PI + 0.35, 13, Color(0.95, 0.74, 0.76, arc_alpha * 0.6), 2.0)

	# Broken circular brooch.
	draw_arc(Vector2(0, -13 + crouch), 5.0, -2.7, 2.2, 14, echo, 2.0)
