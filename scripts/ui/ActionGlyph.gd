class_name ActionGlyph
extends Control

# A drawn icon, not a font glyph: works on Android even with missing Unicode fonts.
# All hit targets belong to the parent Button and remain multitouch compatible.
const IVORY := Color("#eacfc6")
const GOLD := Color("#efbb72")
const RED := Color("#d7475e")
const BLUE := Color("#8fa7e7")

var symbol := "sword"
var fill_fraction := 0.0
var dimmed := false

func set_visual(next_symbol: String, progress: float = 0.0, muted: bool = false) -> void:
	if symbol == next_symbol and is_equal_approx(fill_fraction, progress) and dimmed == muted:
		return
	symbol = next_symbol
	fill_fraction = clampf(progress, 0.0, 1.0)
	dimmed = muted
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var u := minf(size.x, size.y) / 64.0
	var center := size / 2.0
	draw_set_transform(center, 0.0, Vector2.ONE * u)
	var ink: Color = IVORY.darkened(0.54) if dimmed else IVORY
	var trim: Color = GOLD.darkened(0.6) if dimmed else GOLD
	match symbol:
		"sword":
			_sword(ink, trim)
		"arrow":
			_arrow(ink, trim)
		"bow":
			_bow(ink, trim)
		"daggers":
			_daggers(ink, trim)
		"staff":
			_staff(ink, trim)
		"fire":
			_fire(ink, trim)
		"shield":
			_shield(ink, trim)
		"jump":
			_jump(ink, trim)
		"dodge":
			_dodge(ink, trim)
		"throw":
			_daggers(ink, trim)
	if fill_fraction > 0.0:
		draw_arc(Vector2.ZERO, 29.0, -PI / 2.0,
			-PI / 2.0 + TAU * fill_fraction, 32, RED, 3.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _p(points: Array, tint: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), tint)

func _sword(ink: Color, trim: Color) -> void:
	_p([Vector2(-16,16),Vector2(10,-18),Vector2(22,-24),Vector2(18,-10),Vector2(-12,21)],ink)
	_p([Vector2(-10,12),Vector2(13,-17),Vector2(17,-19),Vector2(10,-8)],trim)
	draw_line(Vector2(-17,10),Vector2(-4,21),trim,5,false)
	draw_line(Vector2(-12,17),Vector2(-20,26),ink,5,false)

func _arrow(ink: Color, trim: Color) -> void:
	draw_line(Vector2(-21,15),Vector2(18,-14),ink,4,false)
	_p([Vector2(23,-20),Vector2(18,-4),Vector2(11,-13)],trim)
	draw_line(Vector2(-22,15),Vector2(-12,17),trim,3,false)
	draw_line(Vector2(-21,15),Vector2(-16,23),trim,3,false)

func _bow(ink: Color, trim: Color) -> void:
	_p([Vector2(4,-25),Vector2(17,-20),Vector2(23,-9),Vector2(25,6),
		Vector2(19,21),Vector2(7,27),Vector2(9,18),Vector2(15,9),
		Vector2(16,-8),Vector2(10,-18)],trim)
	draw_line(Vector2(7,-25),Vector2(8,26),ink,2,false)
	draw_line(Vector2(-22,0),Vector2(23,0),ink,3,false)
	_p([Vector2(25,0),Vector2(16,-7),Vector2(16,7)],RED)

func _daggers(ink: Color, trim: Color) -> void:
	_p([Vector2(-18,-24),Vector2(-4,-7),Vector2(2,6),Vector2(-8,4)],ink)
	_p([Vector2(17,-25),Vector2(24,-20),Vector2(8,5),Vector2(3,8)],ink)
	draw_line(Vector2(-5,4),Vector2(6,15),trim,4,false)
	draw_line(Vector2(8,7),Vector2(19,18),trim,4,false)
	draw_line(Vector2(7,14),Vector2(13,21),ink,5,false)
	draw_line(Vector2(18,17),Vector2(22,24),ink,5,false)

func _staff(ink: Color, trim: Color) -> void:
	draw_line(Vector2(0,-21),Vector2(0,27),ink,5,false)
	draw_line(Vector2(0,-16),Vector2(0,23),trim,2,false)
	_p([Vector2(0,-29),Vector2(13,-14),Vector2(0,-2),Vector2(-13,-14)],BLUE)
	draw_line(Vector2(-13,-16),Vector2(0,-29),trim,3,false)
	draw_line(Vector2(13,-16),Vector2(0,-29),trim,3,false)

func _fire(ink: Color, trim: Color) -> void:
	_p([Vector2(1,-26),Vector2(13,-13),Vector2(11,-1),Vector2(20,-10),
		Vector2(22,9),Vector2(13,22),Vector2(0,26),Vector2(-15,19),
		Vector2(-20,7),Vector2(-12,-11),Vector2(-6,2)],RED)
	_p([Vector2(1,-7),Vector2(8,7),Vector2(11,13),Vector2(3,22),
		Vector2(-8,16),Vector2(-8,6)],trim)

func _shield(ink: Color, trim: Color) -> void:
	_p([Vector2(0,-26),Vector2(23,-18),Vector2(21,8),Vector2(12,23),
		Vector2(0,30),Vector2(-12,23),Vector2(-21,8),Vector2(-23,-18)],trim)
	_p([Vector2(0,-20),Vector2(17,-14),Vector2(16,6),Vector2(9,17),
		Vector2(0,23),Vector2(-9,17),Vector2(-16,6),Vector2(-17,-14)],Color("#241c33"))
	draw_line(Vector2(0,-15),Vector2(0,18),ink,3,false)
	draw_line(Vector2(-11,0),Vector2(11,0),ink,3,false)

func _jump(ink: Color, trim: Color) -> void:
	draw_line(Vector2(0,24),Vector2(0,-13),ink,7,false)
	_p([Vector2(0,-28),Vector2(19,-7),Vector2(7,-7),Vector2(7,0),
		Vector2(-7,0),Vector2(-7,-7),Vector2(-19,-7)],trim)

func _dodge(ink: Color, trim: Color) -> void:
	_p([Vector2(-13,-12),Vector2(8,-12),Vector2(18,-2),Vector2(7,5),
		Vector2(-3,-2),Vector2(-17,-2)],ink)
	_p([Vector2(0,5),Vector2(20,5),Vector2(27,17),Vector2(11,16)],trim)
	draw_line(Vector2(-20,-18),Vector2(-8,-18),ink,3,false)
	draw_line(Vector2(-29,-7),Vector2(-17,-7),ink,3,false)
	draw_line(Vector2(-23,11),Vector2(-7,11),ink,3,false)
