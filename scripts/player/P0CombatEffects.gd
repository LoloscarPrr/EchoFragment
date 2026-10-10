class_name P0CombatEffects
extends Node2D

var _slash_alpha := 0.0
var _slash_progress := 0.0
var _slash_facing := 1.0
var _impact_alpha := 0.0
var _impact_position := Vector2.ZERO
var _impact_progress := 0.0

func _process(delta: float) -> void:
	if _slash_alpha > 0.0:
		_slash_alpha = maxf(0.0, _slash_alpha - delta * 8.0)
		_slash_progress = minf(1.0, _slash_progress + delta * 10.0)
	if _impact_alpha > 0.0:
		_impact_alpha = maxf(0.0, _impact_alpha - delta * 8.0)
		_impact_progress = minf(1.0, _impact_progress + delta * 13.0)
	queue_redraw()

func play_slash(facing: float) -> void:
	_slash_facing = signf(facing) if facing != 0.0 else 1.0
	_slash_alpha = 1.0
	_slash_progress = 0.0
	queue_redraw()

func play_impact(local_position: Vector2 = Vector2(58, -6)) -> void:
	_impact_position = local_position
	_impact_alpha = 1.0
	_impact_progress = 0.0
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
		# Expanding contact ring and sparks make confirmed sword hits readable.
		var ring_radius := lerpf(5.0, 29.0, _impact_progress)
		draw_arc(_impact_position, ring_radius, 0.0, TAU, 24, Color(1.0, 0.43, 0.38, _impact_alpha * 0.56), 3.0)
		draw_circle(_impact_position, 7.0 * (1.0 - _impact_progress) + 1.0, Color(1.0, 0.93, 0.79, _impact_alpha * 0.8))
		for i in range(9):
			var angle := float(i) * TAU / 9.0 + 0.12
			var dir := Vector2(cos(angle), sin(angle))
			var near := 6.0 + _impact_progress * 13.0
			var far := near + 10.0 * (1.0 - _impact_progress)
			draw_line(_impact_position + dir * near, _impact_position + dir * far, color, 3.0 * (1.0 - _impact_progress) + 0.7)
