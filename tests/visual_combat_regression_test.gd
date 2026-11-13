extends SceneTree

var failures := 0

func _check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error("[Visual Combat Baseline] " + label)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var source := load("res://scenes/main/Main.tscn") as PackedScene
	_check(source != null, "Main scene must load")
	if source == null:
		quit(1)
		return
	var game := source.instantiate()
	root.add_child(game)
	current_scene = game
	await process_frame

	var art = game.get_node("ValleGrisAtmosphere")
	var player = game.get_node("Player")
	var hud = game.get_node("UI/HUD")
	var controls = game.get_node("VirtualControls")

	_check(art.get_script().resource_path == "res://scripts/world/RuinasDelEcoBackdrop.gd", "Ruinas del Eco environment is retained")
	_check(art.PLATE.get_width() > 1000, "gothic background texture is present")
	_check(hud.get_script().resource_path == "res://scripts/ui/GothicHUD.gd", "approved gothic HUD skin remains attached")
	_check(player.articulated_visual is PortadorPoseVisual, "Portador pixel pose atlas is active")
	_check(player.articulated_visual.art_loaded, "the coherent armor atlas loads")
	_check(player.articulated_visual.visible, "armored player is visible with sword equipped")

	player.add_item(&"hunter_bow")
	_check(player.equip_weapon(&"hunter_bow"), "bow equip works")
	player._update_visual(1.0 / 60.0)
	_check(player.articulated_visual.visible, "bow does not fall back to an obsolete proxy character")
	_check(player.get_weapon_action_status()["secondary_visible"], "bow uses separate ranged button")
	_check(not player.get_weapon_action_status()["guard_visible"], "bow has no guard button")

	player.add_item(&"shadow_daggers")
	_check(player.equip_weapon(&"shadow_daggers"), "dagger equip works")
	_check(player.articulated_visual.visible, "daggers retain approved character look")
	player.add_item(&"apprentice_staff")
	_check(player.equip_weapon(&"apprentice_staff"), "staff equip works")
	_check(player.articulated_visual.visible, "staff retains approved character look")
	_check(player.get_weapon_action_status()["guard_visible"], "staff barrier button appears")
	_check(not player.get_weapon_action_status()["secondary_visible"], "staff does not show extra ranged button")

	# Verify the right-hand circular cluster has no overlapping touch rectangles.
	controls.set_weapon_mode(0)
	controls._refresh_weapon_labels()
	var action_names := ["Attack", "Secondary", "Guard", "Jump", "Dodge"]
	for i in range(action_names.size()):
		var first := controls.get_node("Root/" + action_names[i]) as Button
		for j in range(i + 1, action_names.size()):
			var second := controls.get_node("Root/" + action_names[j]) as Button
			_check(not first.get_global_rect().intersects(second.get_global_rect()), "touch zones overlap: %s and %s" % [first.name, second.name])
	controls._set_touch(30, "move_right")
	controls._set_touch(31, "jump")
	controls._set_touch(32, "weapon_secondary")
	_check(controls._action_holders.has("move_right") and controls._action_holders.has("jump") and controls._action_holders.has("weapon_secondary"), "three separate finger actions remain held")
	controls._release_all()

	game.queue_free()
	await process_frame
	if failures == 0:
		print("[Visual Combat Baseline] PASS: gothic scene, armored character, circular buttons and multi-finger controls")
	quit(1 if failures > 0 else 0)
