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
	var sprite: AnimatedSprite2D = bridge.get_node_or_null("AnimatedSprite2D")
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
		if not bridge.configure(state, 0, 1.0):
			_fail("Could not configure state: " + str(state))
			return
		if not sprite.visible:
			_fail("Sprite hidden despite supported state: " + str(state))
			return
		if not bridge.configure(state, 0, -1.0) or not sprite.flip_h:
			_fail("Left orientation failed for " + str(state))
			return
	if bridge.configure(&"nonexistent_p0_state", 0, 1.0):
		_fail("Unknown art state must use procedural fallback")
		return
	print("P0 runtime art smoke: PASS (10 states, 15 unique pilot drawings)")
	quit(0)

func _fail(message: String) -> void:
	push_error("P0 runtime art smoke: " + message)
	quit(1)
