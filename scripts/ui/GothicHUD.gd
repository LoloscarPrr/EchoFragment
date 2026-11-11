extends Control
## Visual skin only: existing Main signals continue to own all values.

func _ready() -> void:
	_skin_bar($HealthBar, Color("b51d39"), Vector2(38, 24), Vector2(300, 24))
	_skin_bar($StaminaBar, Color("367fc7"), Vector2(38, 58), Vector2(255, 16))
	_skin_bar($XPBar, Color("c08a51"), Vector2(38, 131), Vector2(180, 5))
	_skin_bar($BossBar, Color("b51d39"), Vector2(400, 48), Vector2(480, 18))
	$HealthLabel.add_theme_font_size_override("font_size", 13)
	$HealthLabel.position = Vector2(48, 26)
	$StaminaLabel.add_theme_font_size_override("font_size", 12)
	$StaminaLabel.position = Vector2(48, 57)
	$WeaponLabel.position = Vector2(38, 84)
	$WeaponLabel.add_theme_font_size_override("font_size", 14)
	$LevelLabel.position = Vector2(38, 108)
	$LevelLabel.add_theme_font_size_override("font_size", 12)
	$StatusLabel.position = Vector2(38, 148)
	for child in get_children():
		if child is Label:
			child.add_theme_color_override("font_color", Color("e1ced1"))
			child.add_theme_color_override("font_shadow_color", Color("100c17"))
			child.add_theme_constant_override("shadow_offset_x", 1)
			child.add_theme_constant_override("shadow_offset_y", 2)

func _skin_bar(bar: ProgressBar, ink: Color, at: Vector2, dimensions: Vector2) -> void:
	# Leave boss anchors intact so it stays centered at other aspect ratios.
	if bar.name != "BossBar":
		bar.position = at
		bar.size = dimensions
	var background := StyleBoxFlat.new()
	background.bg_color = Color("17111f")
	background.border_color = Color("987781")
	background.set_border_width_all(2)
	background.set_corner_radius_all(5)
	background.shadow_color = Color(0.03, 0.01, 0.04, 0.8)
	background.shadow_size = 3
	var fill := StyleBoxFlat.new()
	fill.bg_color = ink
	fill.border_color = ink.lightened(0.25)
	fill.set_border_width_all(2)
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
