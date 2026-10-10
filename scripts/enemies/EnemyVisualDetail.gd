extends Node2D
## Cosmetic overlay for prototype adversaries. Never changes hitboxes or AI.
@export_enum("Raider", "Sentinel", "Knight") var archetype := 0
var _clock := 0.0

func _process(delta: float) -> void:
	_clock += delta
	queue_redraw()

func _draw() -> void:
	var iron := Color(0.23, 0.25, 0.30)
	var rim := Color(0.49, 0.48, 0.48)
	var cloth := Color(0.22, 0.13, 0.19)
	var ember := Color(0.90, 0.26, 0.30, 0.70 + sin(_clock * 3.2) * 0.16)
	if archetype == 2:
		# Massive asymmetric pauldrons and broken crown make the boss readable.
		draw_colored_polygon(PackedVector2Array([Vector2(-46,-43),Vector2(-19,-58),Vector2(-12,-28),Vector2(-43,-18)]), iron)
		draw_colored_polygon(PackedVector2Array([Vector2(17,-55),Vector2(47,-35),Vector2(40,-14),Vector2(13,-25)]), rim)
		draw_colored_polygon(PackedVector2Array([Vector2(-27,-56),Vector2(-23,-86),Vector2(-9,-70),Vector2(0,-92),Vector2(12,-69),Vector2(27,-80),Vector2(24,-51)]), iron)
		draw_line(Vector2(-8,-54),Vector2(10,-54),ember,4.0)
		draw_line(Vector2(3,-46),Vector2(-5,-15),ember,3.0)
		draw_line(Vector2(-5,-15),Vector2(8,16),ember,3.0)
		draw_colored_polygon(PackedVector2Array([Vector2(-35,34),Vector2(-45,58),Vector2(-13,52),Vector2(-12,31)]), cloth)
	elif archetype == 1:
		# Armoured sentry, broad shoulders and helmet visor.
		draw_colored_polygon(PackedVector2Array([Vector2(-32,-26),Vector2(-19,-44),Vector2(-10,-25)]), rim)
		draw_colored_polygon(PackedVector2Array([Vector2(10,-25),Vector2(20,-44),Vector2(33,-26)]), rim)
		draw_rect(Rect2(-20,-49,40,15), iron)
		draw_line(Vector2(-12,-40),Vector2(12,-40),ember,3.0)
		draw_line(Vector2(-19,1),Vector2(19,1),rim,4.0)
		draw_rect(Rect2(-13,22,26,5), iron)
	else:
		# Light raiders: hood, scarf, belt and a single ember eye.
		draw_colored_polygon(PackedVector2Array([Vector2(-25,-25),Vector2(-17,-50),Vector2(5,-57),Vector2(25,-35),Vector2(13,-24)]),cloth)
		draw_line(Vector2(-12,-34),Vector2(8,-33),rim,3.0)
		draw_circle(Vector2(9,-37),2.7,ember)
		draw_line(Vector2(-20,12),Vector2(20,9),iron,6.0)
		draw_colored_polygon(PackedVector2Array([Vector2(-20,10),Vector2(-29,36),Vector2(-6,33)]),cloth)
