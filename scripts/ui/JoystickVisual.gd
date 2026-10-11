extends Control
## Purely cosmetic joystick display. Input and finger ownership live in VirtualControls.
var axis := 0.0

func set_axis(value: float) -> void:
	axis = clampf(value, -1.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.35
	draw_circle(center, radius + 12.0, Color(0.08, 0.10, 0.15, 0.42))
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.64, 0.68, 0.76, 0.70), 4.0)
	draw_line(center + Vector2(-radius * 0.75, 0), center + Vector2(radius * 0.75, 0), Color(0.55, 0.59, 0.67, 0.25), 2.0)
	var knob := center + Vector2(axis * radius * 0.62, 0)
	draw_circle(knob, radius * 0.40, Color(0.25, 0.30, 0.39, 0.90))
	draw_arc(knob, radius * 0.40, 0.0, TAU, 32, Color(0.78, 0.36, 0.43, 0.90), 3.0)
