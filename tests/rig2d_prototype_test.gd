extends SceneTree

## Godot 4.3 smoke test: isolated 2D bone hierarchy and safe poses.
## ./godot --headless --path . --script res://tests/rig2d_prototype_test.gd
var failures := 0

func _check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error("[EchoFragment Rig2D] " + description)

func _initialize() -> void:
    call_deferred("_test")

func _test() -> void:
    var rig := PortadorRig2DPrototype.new()
    root.add_child(rig)
    var skeleton := rig.get_node_or_null("Armature") as Skeleton2D
    _check(skeleton != null, "Skeleton2D is created")
    var torso := rig.get_node_or_null("Armature/Hips/Torso") as Bone2D
    var helmet := rig.get_node_or_null("Armature/Hips/Torso/Neck/Helmet") as Bone2D
    var sword := rig.get_node_or_null("Armature/Hips/Torso/SwordUpperArm/SwordForearm/Sword") as Bone2D
    var cape := rig.get_node_or_null("Armature/Hips/Torso/Cape") as Bone2D
    _check(torso != null, "torso bone exists")
    _check(helmet != null, "helmet bone exists")
    _check(sword != null, "sword bone exists")
    _check(cape != null, "cape bone exists")
    if torso != null and sword != null and skeleton != null:
        rig.set_pose(&"idle_ready", 0.0, 1.0)
        var rest_angle := sword.rotation
        rig.set_pose(&"attack_light", 0.52, 1.0)
        _check(not is_equal_approx(sword.rotation, rest_angle), "attack rotates actual weapon bone")
        _check(not is_equal_approx(torso.rotation, 0.0), "attack changes torso pose")
        rig.set_pose(&"attack_light", 0.52, -1.0)
        _check(skeleton.scale.x < 0.0, "mirroring faces left without redrawing sprites")
        rig.set_pose(&"idle_ready", 0.0, 1.0)
        _check(skeleton.scale.x > 0.0, "mirroring returns right")
    var stage := load("res://scenes/experiments/Rig2DPreview.tscn") as PackedScene
    _check(stage != null, "standalone preview scene loads")
    if stage != null:
        var preview := stage.instantiate()
        root.add_child(preview)
        _check(preview.get_node_or_null("PortadorRig") != null, "preview includes rig")
        preview.queue_free()
    rig.queue_free()
    print("[EchoFragment Rig2D] ", "PASS" if failures == 0 else str(failures) + " failures")
    quit(1 if failures > 0 else 0)
