class_name WeaponArtOverlay
extends Node2D

# First in-game silhouette pass for the approved Portador del Eco armor.
# The weapon art is a separate layer: never rotate/scale the physics root.
# Local units are pixel-aligned so the 2D GL renderer keeps hard edges.
const OUTLINE := Color("#110b18")
const STEEL := Color("#8d899d")
const LIGHT_STEEL := Color("#e0c7af")
const ANTIQUE_GOLD := Color("#bb8750")
const HIGHLIGHT_GOLD := Color("#f2bd70")
const CRIMSON := Color("#cf2945")
const FIRE := Color("#ff7647")
const ASH_WOOD := Color("#473042")
const VIOLET := Color("#9b65e0")

var weapon_mode := 0
var animation_state: StringName = &"idle_ready"
var facing := 1.0
var bow_charge := 0.0
var _clock := 0.0

func configure(mode: int, state: StringName, direction: float, charge: float = 0.0) -> void:
	var next_facing := -1.0 if direction < 0.0 else 1.0
	var changed := weapon_mode != mode or animation_state != state or facing != next_facing or absf(bow_charge - charge) > 0.01
	weapon_mode = mode
	animation_state = state
	facing = next_facing
	bow_charge = clampf(charge, 0.0, 1.0)
	visible = weapon_mode != 0
	if changed:
		queue_redraw()

func _process(delta: float) -> void:
	_clock += delta
	if visible and (animation_state == &"run_forward" or animation_state == &"bow_draw"):
		queue_redraw()

func _poly(points: Array[Vector2], tint: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), tint)

func _draw() -> void:
	if weapon_mode == 0:
		return
	var moving := animation_state == &"run_forward"
	var bob := roundf(sin(_clock * 12.0) * 3.0) if moving else 0.0
	# Local front-hand pivot follows direction; the full-body atlas remains fixed.
	draw_set_transform(Vector2(facing * 26.0, -117.0 + bob), 0.0, Vector2(facing, 1.0))
	match weapon_mode:
		1:
			_draw_bow()
		2:
			_draw_staff()
		3:
			_draw_daggers()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_bow() -> void:
	# Bow: layered black yew, antique gold nocks and crimson-glowing arrow.
	_poly([Vector2(30,-68), Vector2(47,-62), Vector2(58,-48), Vector2(66,-26),
		Vector2(67,0), Vector2(61,30), Vector2(49,54), Vector2(31,67),
		Vector2(30,57), Vector2(40,48), Vector2(48,26), Vector2(52,-1),
		Vector2(47,-28), Vector2(40,-48), Vector2(29,-58)], OUTLINE)
	_poly([Vector2(30,-64),Vector2(43,-57),Vector2(52,-42),Vector2(60,-22),
		Vector2(62,1),Vector2(56,27),Vector2(45,51),Vector2(32,63),
		Vector2(34,53),Vector2(46,28),Vector2(51,2),Vector2(46,-30),
		Vector2(37,-49),Vector2(31,-56)], ASH_WOOD)
	draw_line(Vector2(32,-58), Vector2(33,59), LIGHT_STEEL, 2.0, false)
	draw_line(Vector2(34,-49),Vector2(49,-30),ANTIQUE_GOLD, 3.0, false)
	draw_line(Vector2(45,32),Vector2(34,50),ANTIQUE_GOLD, 3.0, false)
	_poly([Vector2(27,-67),Vector2(40,-67),Vector2(41,-61),Vector2(28,-60)], HIGHLIGHT_GOLD)
	_poly([Vector2(29,60),Vector2(41,60),Vector2(39,67),Vector2(26,67)], HIGHLIGHT_GOLD)
	_poly([Vector2(45,-11),Vector2(59,-10),Vector2(59,12),Vector2(45,13)], ANTIQUE_GOLD)
	_poly([Vector2(52,-7),Vector2(62,-5),Vector2(62,6),Vector2(52,8)], OUTLINE)
	if animation_state in [&"bow_draw", &"bow_shot"] or bow_charge > 0.03:
		var shift := -22.0 * bow_charge
		draw_line(Vector2(12+shift,1),Vector2(113,1),LIGHT_STEEL,3.0, false)
		_poly([Vector2(122,1),Vector2(103,-7),Vector2(105,1),Vector2(103,9)],CRIMSON)
		_poly([Vector2(10+shift,-5),Vector2(20+shift,-2),Vector2(19+shift,2)],ANTIQUE_GOLD)
		if bow_charge > 0.1:
			draw_arc(Vector2(53,0), 32.0, -1.15, 1.15, 18, FIRE.darkened(0.15), 2.0, false)
	else:
		# The waiting arrow rests diagonally beneath the hand.
		draw_line(Vector2(16,12),Vector2(86,24),STEEL,2.0,false)
		_poly([Vector2(92,25),Vector2(82,18),Vector2(82,28)],CRIMSON)

func _draw_staff() -> void:
	# Staff: dark ironwood shaft, rune-gold bands and a suspended violet crystal.
	_poly([Vector2(32,-57),Vector2(43,-57),Vector2(45,100),Vector2(32,104)],OUTLINE)
	_poly([Vector2(34,-55),Vector2(39,-55),Vector2(41,96),Vector2(34,101)],ASH_WOOD)
	draw_line(Vector2(36,-46),Vector2(37,95),ANTIQUE_GOLD,2.0,false)
	_poly([Vector2(29,-38),Vector2(48,-38),Vector2(49,-29),Vector2(28,-28)],ANTIQUE_GOLD)
	_poly([Vector2(30,18),Vector2(47,18),Vector2(48,27),Vector2(30,28)],ANTIQUE_GOLD)
	_poly([Vector2(29,79),Vector2(47,79),Vector2(49,88),Vector2(30,90)],ANTIQUE_GOLD)
	_poly([Vector2(15,-56),Vector2(21,-79),Vector2(37,-86),Vector2(55,-78),
		Vector2(62,-54),Vector2(53,-47),Vector2(50,-64),Vector2(42,-69),
		Vector2(38,-56),Vector2(30,-69),Vector2(23,-64),Vector2(22,-47)],OUTLINE)
	_poly([Vector2(19,-57),Vector2(24,-74),Vector2(37,-79),Vector2(51,-74),
		Vector2(57,-58),Vector2(51,-56),Vector2(44,-66),Vector2(37,-55),
		Vector2(30,-66),Vector2(23,-55)],ANTIQUE_GOLD)
	_poly([Vector2(37,-100),Vector2(51,-85),Vector2(48,-68),Vector2(37,-56),
		Vector2(26,-68),Vector2(24,-85)],OUTLINE)
	_poly([Vector2(37,-95),Vector2(47,-83),Vector2(44,-70),Vector2(37,-61),
		Vector2(30,-71),Vector2(28,-83)],VIOLET)
	_poly([Vector2(37,-90),Vector2(42,-80),Vector2(38,-73),Vector2(33,-80)],Color("#c8a2ff"))
	_poly([Vector2(34,-88),Vector2(30,-82),Vector2(32,-74),Vector2(37,-68)],Color("#6645a8"))
	if animation_state in [&"bow_shot", &"attack_light"]:
		draw_arc(Vector2(37,-79),29.0,0.0,TAU,24,Color("#bc9bf4",0.75),2.0,false)

func _draw_daggers() -> void:
	# Paired short obsidian blades are intentionally distinct from sword proportions.
	# Rear knife, with gold-crossguard silhouette.
	_poly([Vector2(-34,-40),Vector2(-10,-14),Vector2(-5,14),Vector2(-13,9),
		Vector2(-35,-8),Vector2(-45,-35)],OUTLINE)
	_poly([Vector2(-38,-34),Vector2(-19,-14),Vector2(-7,7),Vector2(-23,-8)],STEEL)
	_poly([Vector2(-36,-32),Vector2(-21,-13),Vector2(-15,-11)],LIGHT_STEEL)
	draw_line(Vector2(-16,8),Vector2(1,20),ANTIQUE_GOLD,7.0,false)
	draw_line(Vector2(-4,17),Vector2(10,33),OUTLINE,9.0,false)
	draw_line(Vector2(-4,17),Vector2(10,33),ASH_WOOD,5.0,false)
	_poly([Vector2(23,-51),Vector2(50,-29),Vector2(57,-6),Vector2(43,2),
		Vector2(20,-27),Vector2(14,-44)],OUTLINE)
	_poly([Vector2(22,-44),Vector2(47,-26),Vector2(51,-7),Vector2(42,-3),
		Vector2(22,-29)],STEEL)
	_poly([Vector2(22,-42),Vector2(42,-27),Vector2(46,-23)],LIGHT_STEEL)
	_poly([Vector2(41,-5),Vector2(56,3),Vector2(51,13),Vector2(37,6)],ANTIQUE_GOLD)
	draw_line(Vector2(46,9),Vector2(61,31),OUTLINE,10.0,false)
	draw_line(Vector2(46,9),Vector2(61,31),ASH_WOOD,6.0,false)
	_poly([Vector2(58,27),Vector2(66,25),Vector2(72,34),Vector2(62,39)],ANTIQUE_GOLD)
	draw_line(Vector2(31,-24),Vector2(44,-13),CRIMSON,3.0,false)
	draw_line(Vector2(-29,-18),Vector2(-18,-9),CRIMSON,2.0,false)
