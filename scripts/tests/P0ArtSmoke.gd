extends SceneTree

## Headless runtime smoke test for P0 art integration.
## Runs on PR CI; no Android UI or user interaction is required.
const EXPECTED := {
	&"idle_ready": 2,
	&"run_forward": 3,
	&"jump_start": 1,
	&"jump_rise": 1,
	&"jump_apex": 1,
	&"jump_fall": 1,
	&"land_light": 1,
	&"attack_light": 2,
	&"hit_light": 1,
	&"dodge": 2
}

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var stage := load("res://scenes/main/Main.tscn") as PackedScene
	if stage == null:
		_fail("Main scene could not be loaded")
		return
	var instance := stage.instantiate()
	root.add_child(instance)
	await process_frame

	var player := instance.get_node_or_null("Player")
	if player == null:
		_fail("Main scene has no Player")
		return
	var bridge: ProtagonistArtBridge = player.art_bridge
	if not is_instance_valid(bridge) or not bridge.has_art:
		_fail("P0 SpriteFrames were not imported at runtime")
		return
	var sprite: AnimatedSprite2D = bridge.get_node_or_null("P0ArtSprite")
	if sprite == null:
		_fail("P0 art bridge has no AnimatedSprite2D")
		return
	for state in EXPECTED.keys():
		if not sprite.sprite_frames.has_animation(state):
			_fail("Missing art state: " + str(state))
			return
		if sprite.sprite_frames.get_frame_count(state) != int(EXPECTED[state]):
			_fail("Wrong frame count for " + str(state))
			return
		for frame_index in range(int(EXPECTED[state])):
			var frame_texture: Texture2D = sprite.sprite_frames.get_frame_texture(state, frame_index)
			if frame_texture.get_width() != 160 or frame_texture.get_height() != 140:
				_fail("Frame padding or sizing mismatch for " + str(state))
				return
			var padded: Image = frame_texture.get_image()
			for edge_x in range(160):
				if padded.get_pixel(edge_x, 0).a > 0.1 or padded.get_pixel(edge_x, 139).a > 0.1:
					_fail("Top/bottom edge clipped for " + str(state))
					return
			for edge_y in range(140):
				if padded.get_pixel(0, edge_y).a > 0.1 or padded.get_pixel(159, edge_y).a > 0.1:
					_fail("Left/right edge clipped for " + str(state))
					return
		if not bridge.configure(state, 0, 1.0):
			_fail("Could not configure state: " + str(state))
			return
		if not sprite.visible:
			_fail("Sprite hidden despite supported state: " + str(state))
			return
		if not bridge.configure(state, 0, -1.0) or not sprite.flip_h:
			_fail("Left orientation failed for " + str(state))
			return
	if not bridge.configure(&"attack_light", 2, 1.0) or sprite.frame != 1:
		_fail("Contact-time blade pose must be selected")
		return
	if not bridge.configure(&"attack_light", 5, 1.0) or sprite.frame != 0:
		_fail("Recovery must reset to the base attack pose")
		return
	if not bridge.configure(&"attack_light", 2, -1.0) or not sprite.flip_h:
		_fail("Mirrored attack visual failed")
		return
	if bridge.configure(&"nonexistent_p0_state", 0, 1.0):
		_fail("Unknown art state must use procedural fallback")
		return
	# Regression: the improvised curved Paint-style sword trail must stay out.
	var bridge_source := FileAccess.get_file_as_string("res://scripts/player/ProtagonistArtBridge.gd")
	var backup_source := FileAccess.get_file_as_string("res://scripts/player/ProtagonistProxyVisual.gd")
	var combat_source := FileAccess.get_file_as_string("res://scripts/player/P0CombatEffects.gd")
	var player_source := FileAccess.get_file_as_string("res://scripts/player/Player.gd")
	if bridge_source.contains("draw_polyline(trail") or backup_source.contains("var arc_alpha :="):
		_fail("Legacy procedural sword arc has returned")
		return
	if combat_source.contains("func play_slash(") or player_source.contains("combat_effects.play_slash"):
		_fail("Legacy sword sweep effect is still invoked")
		return
	if not combat_source.contains("func play_impact(") or not player_source.contains("hitbox.strike(global_position)"):
		_fail("Hit confirmation feedback or gameplay strike was removed")
		return
	print("P0.4.1 art smoke: PASS (10 states, 15 frames, no placeholder slash, hit feedback retained)")
	quit(0)

func _fail(message: String) -> void:
	push_error("P0 runtime art smoke: " + message)
	quit(1)
