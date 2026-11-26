extends SceneTree

var failures := 0

func check(ok: bool, msg: String) -> void:
	if not ok:
		failures += 1
		push_error("[WeaponVisual] " + msg)

func _initialize() -> void:
	create_timer(12.0).timeout.connect(func() -> void:
		push_error("Weapon visual smoke test timed out")
		quit(1)
	)
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/main/Main.tscn") as PackedScene
	check(scene != null, "Main scene must load")
	if scene == null:
		quit(1)
		return
	var game := scene.instantiate()
	root.add_child(game)
	current_scene = game
	await process_frame
	var player = game.get_node("Player")
	var controls = game.get_node("VirtualControls")
	check(player.articulated_visual is PortadorPoseVisual, "coherent full-body pixel atlas remains")
	var pose := player.articulated_visual as PortadorPoseVisual
	check(pose.art_loaded, "approved original atlas imported")
	check(pose.get_node_or_null("EquippedWeaponArt") is WeaponArtOverlay, "weapon silhouettes are on live character")
	check(pose._pose_sprite.material is ShaderMaterial, "forward blade cleanup shader assigned")
	check(controls.get_node("Root/Attack/Glyph") is ActionGlyph, "live melee action icon")
	check(controls.get_node("Root/Secondary/Glyph") is ActionGlyph, "live ranged action icon")
	check(controls.get_node("Root/Guard/Glyph") is ActionGlyph, "live guard icon")
	check(controls.get_node("Root/Jump/Glyph") is ActionGlyph, "jump icon")
	check(controls.get_node("Root/Dodge/Glyph") is ActionGlyph, "dodge icon")
	for mode_info in [
		[&"rusted_sword", 0, "sword", "fire"],
		[&"hunter_bow", 1, "bow", "bow"],
		[&"apprentice_staff", 2, "staff", "shield"],
		[&"shadow_daggers", 3, "daggers", "throw"]
	]:
		var item: StringName = mode_info[0]
		if not player.inventory.has_item(item):
			player.add_item(item)
		check(player.equip_weapon(item), "weapon equip " + str(item))
		player._update_visual(1.0 / 60.0)
		controls.set_weapon_mode(player.weapon_mode)
		controls._refresh_weapon_labels()
		check(pose.equipped_mode == int(mode_info[1]), "pose mode sync " + str(item))
		check(pose._weapon_art.weapon_mode == int(mode_info[1]), "weapon model sync " + str(item))
		check(pose._weapon_art.visible == (int(mode_info[1]) != 0) and not (int(mode_info[1]) == 1 and pose._bow_frames.is_loaded), "overlay visibility " + str(item))
		check(controls.get_node("Root/Attack/Glyph").symbol == str(mode_info[2]), "primary button symbol " + str(item))
		var secondary_or_guard = controls.get_node("Root/Guard/Glyph") if int(mode_info[1]) == 2 else controls.get_node("Root/Secondary/Glyph")
		check(secondary_or_guard.symbol == str(mode_info[3]), "secondary button symbol " + str(item))
		check(controls.get_node("Root/Attack").text.is_empty(), "no big text overlap")
		check(pose.art_loaded, "weapon switch does not unload base atlas")
	# Active weapon visuals must actually change with attack animations.
	player.equip_weapon(&"apprentice_staff")
	player.animation_controller.play_weapon_action(&"staff_cast")
	player._update_visual(1.0 / 60.0)
	check(pose.state == &"staff_cast", "staff visual action shown")
	player.equip_weapon(&"shadow_daggers")
	player.animation_controller.play_weapon_action(&"daggers_strike")
	player._update_visual(1.0 / 60.0)
	check(pose.state == &"daggers_strike", "dagger attack visual action shown")

	game.queue_free()
	await process_frame
	if failures == 0:
		print("[WeaponVisual] PASS: original pixels, equipped props, glyph buttons and attack visuals")
	quit(1 if failures > 0 else 0)
