extends SceneTree
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var visual := PortadorPoseVisual.new()
	root.add_child(visual)
	check(visual.art_loaded, "pose atlas and all twelve frames load")
	if not visual.art_loaded:
		quit(1)
		return
	var texture := visual._pose_sprite.texture
	var image := texture.get_image()
	check(image.detect_alpha() != Image.ALPHA_NONE, "transparent character atlas")
	for frame in visual._frames:
		var region: Array = frame["region"]
		var bounds := Rect2(region[0], region[1], region[2], region[3])
		check(Rect2(Vector2.ZERO, texture.get_size()).encloses(bounds), "frame remains within atlas")
	visual.configure(&"idle_ready", 0.0, 1.0)
	var right_offset := visual._pose_sprite.position
	visual.configure(&"idle_ready", 0.0, -1.0)
	check(is_equal_approx(visual._pose_sprite.position.x, -right_offset.x), "mirror retains player pivot")
	check(is_equal_approx(visual._pose_sprite.position.y, right_offset.y), "mirror retains floor anchor")
	for tick in range(TajoDelEcoTimeline.ATTACK_TICKS):
		visual.configure(&"attack_light", float(tick) / TajoDelEcoTimeline.ATTACK_TICKS, 1.0)
		var expected := 8 if tick < 5 else (9 if tick <= 7 else 10)
		check(visual.frame_index == expected, "strike pose matches actual hitbox tick " + str(tick))
	for index in range(4):
		visual.configure(&"run_forward", 0.0, 1.0)
		visual._pose_clock = float(index) / 10.0 + 0.001
		visual._apply_pose()
		check(visual.frame_index == index + 1, "four-frame run sequence advances")
	visual.configure(&"jump_apex", 0.5, 1.0)
	check(visual.frame_index == 6, "apex uses tucked legs")
	visual.configure(&"dodge", 0.5, 1.0)
	check(visual.frame_index == 11, "dodge uses low body pose")
	visual.queue_free()
	if failures == 0:
		print("[Portador Poses] PASS: twelve alpha poses, fixed mirror pivot, run and attack timing")
	quit(1 if failures > 0 else 0)
