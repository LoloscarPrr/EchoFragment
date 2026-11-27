extends SceneTree

func _initialize() -> void:
	call_deferred("_test")

func _test() -> void:
	var packed := load("res://scenes/main/Main.tscn") as PackedScene
	assert(packed != null)
	var game := packed.instantiate()
	root.add_child(game)
	current_scene = game
	var player = game.get_node("Player")
	var controls = game.get_node("VirtualControls")
	player.add_item(&"hunter_bow")
	assert(player.equip_weapon(&"hunter_bow"))
	controls.set_weapon_mode(player.weapon_mode)
	assert(player.get_weapon_action_status()["bow_single_button"])
	assert(not player.get_weapon_action_status()["secondary_visible"])
	assert(not controls.get_node("Root/Secondary").visible)
	assert(controls.get_node("Root/Attack/Glyph").symbol == "bow")
	assert(player.BOW_HOLD_THRESHOLD < BowCharge.MAX_DURATION)
	assert(BowCharge.fraction(0.75) > 0.50)

	# A second tap kicks after a punch; a third fires the finisher.
	var now := Time.get_ticks_msec() / 1000.0
	player._bow_combo_step = BowCombo.ARROW_STAB
	player._bow_combo_deadline = now + 2.0
	player._attack_locked_until = 0.0
	player._attack_bow(now)
	assert(player._bow_combo_step == BowCombo.PUSH_KICK)
	assert(player.animation_controller.state == &"bow_kick")
	assert(player.hitbox.knockback >= 480.0)
	player._attack_locked_until = 0.0
	player._attack_bow(now + 0.50)
	assert(player._bow_combo_step == BowCombo.FINISHER_SHOT)
	assert(player._bow_projectile_queued_at >= now)

	# When released after charging, the same input produces a stronger arrow.
	player._attack_locked_until = 0.0
	player._bow_queued_charge = BowCharge.fraction(0.90)
	player._bow_queued_finisher = false
	player._process_queued_bow_shot(now + 1.0)
	assert(player._bow_projectile_charge >= 0.70)
	assert(player._bow_projectile_damage > 20)

	# The newly approved atlas renderer must be present, with safe fallback
	# if its PNG assets haven't been imported into this branch yet.
	var pose = player.articulated_visual
	assert(pose.get_node("ApprovedBowFrames") is BowApprovedFrames)
	game.queue_free()
	print("Bow single-button combo and charged-shot integration passed")
	quit(0)
