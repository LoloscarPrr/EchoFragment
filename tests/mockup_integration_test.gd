extends SceneTree

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var scene := load("res://scenes/main/Main.tscn") as PackedScene
	var game := scene.instantiate()
	root.add_child(game)
	await process_frame
	var plate := game.get_node("ValleGrisAtmosphere")
	check(plate.PLATE.get_width() > 1000, "environment plate loads at game resolution")
	check(plate.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "pixel filtering retained")
	var floor_shape := game.get_node("Ground/CollisionShape2D") as CollisionShape2D
	var floor_rect := floor_shape.shape as RectangleShape2D
	check(is_equal_approx(plate.GROUND_Y, floor_shape.position.y - floor_rect.size.y / 2.0), "painted surface matches collision top")
	var hp := game.get_node("UI/HUD/HealthBar") as ProgressBar
	game.player.health_changed.emit(37, 100)
	check(hp.value == 37, "styled health bar still receives gameplay values")
	check(hp.get_theme_stylebox("fill") is StyleBoxFlat, "gothic HUD skin applied")
	var controls := game.get_node("VirtualControls")
	var attack := controls.get_node("Root/Attack") as Button
	var jump := controls.get_node("Root/Jump") as Button
	check(not attack.get_global_rect().intersects(jump.get_global_rect()), "jump and attack touch targets do not overlap")
	# Exercise the existing finger-owner path after applying the new layout.
	controls._set_touch(10, "attack")
	controls._set_touch(11, "jump")
	check(controls._action_holders.has("attack") and controls._action_holders.has("jump"), "two actions remain independently held")
	controls._set_touch(10, "")
	check(controls._action_holders.has("jump"), "lifting attack does not release jump")
	controls._release_all()
	game.queue_free()
	await process_frame
	if failures == 0:
		print("[Mockup Integration] PASS: plate, floor alignment, live HUD, touch layout and independent actions")
	quit(1 if failures > 0 else 0)
