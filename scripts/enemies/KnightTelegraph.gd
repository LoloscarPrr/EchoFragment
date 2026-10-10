class_name KnightTelegraph
extends Node2D
## Visual telegraphs for the Fragmented Knight; no combat or collision logic.
var windup_ratio := 0.0
var attack_direction := 1.0
var phase := 1
var shifting := false
var active := false
var _clock := 0.0

func _process(delta: float) -> void:
	_clock += delta
	queue_redraw()

func _draw() -> void:
	if shifting:
		var pulse := 1.0 + sin(_clock * 16.0) * 0.12
		draw_arc(Vector2(0,-5), 74.0 * pulse, 0.0, TAU, 40, Color(0.87, 0.18, 0.33, 0.66), 5.0)
		draw_arc(Vector2(0,-5), 95.0 * pulse, 0.0, TAU, 40, Color(0.79, 0.32, 0.50, 0.28), 3.0)
	if active:
		var alpha := 0.20 + 0.52 * windup_ratio
		var d := 1.0 if attack_direction >= 0 else -1.0
		var extent := 96.0 if phase == 1 else 112.0
		var tip := Vector2(d * extent, 9.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(d * 24.0,-33.0), tip, Vector2(d * 25.0,36.0)
		]), Color(0.96,0.22,0.29,alpha * 0.31))
		draw_line(Vector2(d * 30.0,-32.0),tip,Color(1.0,0.38,0.38,alpha),3.0)
		draw_line(tip,Vector2(d * 29.0,33.0),Color(1.0,0.38,0.38,alpha),3.0)
