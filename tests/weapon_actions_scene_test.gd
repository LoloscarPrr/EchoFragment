extends SceneTree

func _initialize() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var packed: PackedScene = load("res://scenes/main/Main.tscn")
	assert(packed != null)
	var game := packed.instantiate()
	root.add_child(game)
	current_scene = game
	await process_frame
	var player = game.get_node("Player")
	var controls = game.get_node("VirtualControls")
	assert(player != null and controls != null)
	assert(controls.get_node("Root/Secondary") != null)
	assert(controls.get_node("Root/Guard") != null)
	assert(player.get_weapon_action_status()["guard_visible"])

	# Verify that the same touch buttons change with equipped weapon.
	player.add_item(&"hunter_bow")
	assert(player.equip_weapon(&"hunter_bow"))
	assert(player.get_weapon_action_status()["secondary"] == "DISPARO")
	assert(not player.get_weapon_action_status()["guard_visible"])
	assert(controls.get_node("Root/Attack").text == "FLECHA" or player.weapon_mode == 1)

	player.add_item(&"shadow_daggers")
	assert(player.equip_weapon(&"shadow_daggers"))
	var t: float = Time.get_ticks_msec() / 1000.0
	assert(player.get_weapon_action_status()["ready"] == 2)
	player._try_secondary_action(t)
	assert(player.get_weapon_action_status()["ready"] == 1)
	player._attack_locked_until = 0.0
	player._try_secondary_action(t + 0.1)
	assert(player.get_weapon_action_status()["ready"] == 0)

	player.add_item(&"apprentice_staff")
	assert(player.equip_weapon(&"apprentice_staff"))
	assert(not player.get_weapon_action_status()["secondary_visible"])
	assert(player.get_weapon_action_status()["guard_visible"])
	player._try_guard(t)
	assert(player._shield_hits == 3)
	var before: int = player.health
	player.take_damage(10)
	assert(player.health == before)
	assert(player._shield_hits == 2)

	# The sword block absorbs only one attack.
	assert(player.equip_weapon(&"rusted_sword"))
	player._shield_cooldown_until = 0.0
	player._invulnerable_until = 0.0
	player._try_guard(t)
	assert(player._shield_hits == 1)
	player.take_damage(10)
	assert(player.health == before)
	assert(player._shield_hits == 0)

	print("Weapon combat scene and controls smoke test passed")
	game.queue_free()
	quit(0)
