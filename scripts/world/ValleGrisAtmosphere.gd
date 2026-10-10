extends Node2D
## Atmospheric background for the Valle Gris prototype. No collision or gameplay coupling.
## Uses deterministic geometry; generated art can later replace this layer.
@export var world_width := 4100.0
@export var ground_y := 640.0
var _mist_time := 0.0

func _process(delta: float) -> void:
	_mist_time += delta
	queue_redraw()

func _draw() -> void:
	# Distant mountain ridges, repeated through the whole playable stretch.
	for i in range(15):
		var x := float(i) * 330.0 - 260.0
		var top := 285.0 + sin(float(i) * 2.1) * 60.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 280.0, 585.0), Vector2(x, top),
			Vector2(x + 310.0, 585.0)]), Color(0.12, 0.17, 0.23, 0.85))
	# Ruined towers and broken parapets establish a sense of scale.
	for i in range(10):
		var x := 180.0 + float(i) * 430.0
		var height := 115.0 + float((i * 37) % 90)
		var base := 590.0
		draw_rect(Rect2(x, base - height, 55.0, height), Color(0.15, 0.19, 0.23, 0.88))
		for j in range(3):
			draw_rect(Rect2(x + float(j) * 19.0, base - height - 14.0, 13.0, 15.0), Color(0.15, 0.19, 0.23, 0.88))
		draw_rect(Rect2(x + 19.0, base - height + 35.0, 13.0, 27.0), Color(0.065, 0.10, 0.14, 0.9))
	# Sparse dead trees form a foreground silhouette without covering the player.
	for i in range(21):
		var x := 75.0 + float(i) * 195.0
		var trunk_h := 62.0 + float((i * 29) % 49)
		var root := Vector2(x, ground_y)
		var trunk_end := root + Vector2(0, -trunk_h)
		var ink := Color(0.095, 0.13, 0.15, 0.9)
		draw_line(root, trunk_end, ink, 8.0)
		draw_line(trunk_end + Vector2(0, 25), trunk_end + Vector2(-22, -15), ink, 5.0)
		draw_line(trunk_end + Vector2(0, 31), trunk_end + Vector2(24, -7), ink, 4.0)
	# Soft, shifting banks of mist stay below head height.
	for i in range(17):
		var x := float(i) * 265.0 + sin(_mist_time * 0.15 + float(i)) * 18.0
		var y := 581.0 + sin(_mist_time * 0.28 + float(i)) * 5.0
		draw_circle(Vector2(x, y), 67.0, Color(0.37, 0.48, 0.54, 0.055))
		draw_circle(Vector2(x + 85.0, y + 13.0), 48.0, Color(0.41, 0.51, 0.58, 0.045))
