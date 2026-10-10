class_name P0CombatEffects
extends Node2D

var _slash_alpha := 0.0
var _slash_progress := 0.0
var _slash_facing := 1.0
var _impact_alpha := 0.0
var _impact_position := Vector2.ZERO

func _process(delta: float) -> void:
	if _slash_alpha > 0.0:
		_slash_alpha = maxf(0.0, _slash_alpha - delta * 8.0)
		_slash_progress = minf(1.0, _slash_progress + delta * 10.0)
	if _impact_alpha > 0.0:
		_impact_alpha = maxf(0.0, _impact_alpha - delta * 10.0)
	queue_redraw()

func play_slash(facing: float) -> void:
	_slash_facing = signf(facing) if facing != 0.0 else 1.0
	_slash_alpha = 1.0
	_slash_progress = 0.0
	queue_redraw()

func play_impact(local_position: Vector2 = Vector2(58, -6)) -> void:
	_impact_position = local_position
	_impact_alpha = 1.0
	queue_redraw()

func _draw() -> void:
	if _slash_alpha > 0.0:
		var center := Vector2(12.0 * _slash_facing, -10.0)
		var radius := lerpf(34.0, 78.0, _slash_progress)
		var start := -1.05 if _slash_facing > 0.0 else PI + 0.20
		var finish := 0.70 if _slash_facing > 0.0 else PI - 1.55
		var color := Color(0.86, 0.90, 0.96, _slash_alpha * 0.78)
		draw_arc(center, radius, start, finish, 18, color, 5.0)
		draw_arc(center, radius - 9.0, start + 0.08, finish - 0.08, 16, Color(0.82, 0.18, 0.25, _slash_alpha * 0.42), 2.0)

	if _impact_alpha > 0.0:
		var color := Color(0.95, 0.88, 0.68, _impact_alpha)
		for angle in [0.0, 0.8, 1.6, 2.5, 3.4, 4.3, 5.2]:
			var dir := Vector2(cos(angle), sin(angle))
			draw_line(_impact_position + dir * 4.0, _impact_position + dir * 18.0, color, 3.0)
