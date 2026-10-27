extends SceneTree

## Godot 4.3 headless smoke test:
## godot --headless --path . --script res://tests/rig_full_v02_test.gd
var failures := 0

func check(condition: bool, why: String) -> void:
    if not condition:
        failures += 1
        push_error("[RigFull v0.2] " + why)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var rig := PortadorFullRigV02.new()
    rig.demo_cycle = false
    root.add_child(rig)
    check(rig.ART.size() == 9, "9 independent source images declared")
    check(rig.missing_files.is_empty(), "all 9 actual PNG files must be present")
    check(rig.art_loaded, "actual textured rig must load, never fallback to polygon mannequin")
    check(rig.get_node_or_null("FallbackProvisional") == null, "no polygon fallback when art exists")
    var skeleton := rig.get_node_or_null("Armature") as Skeleton2D
    check(skeleton != null, "textured Skeleton2D built")
    var chest := rig.get_node_or_null("Armature/Hips/Torso/torso") as Sprite2D
    var arm := rig.get_node_or_null("Armature/Hips/Torso/ArmRUpper/arm_R_upper") as Sprite2D
    var blade := rig.get_node_or_null("Armature/Hips/Torso/ArmRUpper/ArmRForearm/ArmRHand/Sword/sword") as Sprite2D
    check(chest != null and chest.texture != null, "visible torso uses imported PNG")
    check(arm != null and arm.region_enabled and arm.region_rect.size.y > 0.0, "right upper arm has a real animated cutout")
    check(blade != null and blade.texture != null, "sword PNG attaches to animated hand")
    if chest != null and chest.texture != null:
        check(absf(chest.scale.x * float(chest.texture.get_width()) - 312.32) < 1.0, "preview-image pixel size normalized to original bone scale")
    # The head was originally 0.205 of its 1024px master and looked nearly as
    # tall as the whole chest. Preserve a plausible helmet-to-torso proportion.
    var head_art := rig.get_node_or_null("Armature/Hips/Torso/Helmet/helmet") as Sprite2D
    check(head_art != null, "helmet Sprite2D exists")
    if head_art != null and chest != null and head_art.texture != null and chest.texture != null:
        var helmet_canvas_width: float = absf(head_art.scale.x * float(head_art.texture.get_width()))
        var chest_canvas_width: float = absf(chest.scale.x * float(chest.texture.get_width()))
        check(helmet_canvas_width < chest_canvas_width * 0.55, "helmet is not oversized relative to cuirass")
        check(helmet_canvas_width > chest_canvas_width * 0.45, "helmet remains visible")
    var rear_arm := rig.get_node_or_null("Armature/Hips/Torso/ArmLUpper") as Bone2D
    var forearm := rig.get_node_or_null("Armature/Hips/Torso/ArmRUpper/ArmRForearm") as Bone2D
    check(rear_arm != null and rear_arm.position.x < -85.0, "rear arm shoulder sits outside chest silhouette")
    check(forearm != null and forearm.position.y <= 60.0, "smaller upper arm retains matched elbow pivot")
    rig.configure(&"idle_ready", 0.0, 1.0)
    rig.configure(&"run_forward", 0.5, -1.0)
    rig.configure(&"attack_light", 0.5, 1.0)
    rig.configure(&"dodge", 0.65, 1.0)
    rig.configure(&"jump_rise", 0.1, -1.0)
    var scene := load("res://scenes/experiments/RigFullPreviewV02.tscn") as PackedScene
    check(scene != null, "v0.2 experimental scene loads")
    if scene != null:
        var instance := scene.instantiate()
        root.add_child(instance)
        check(instance.get_node_or_null("PortadorRigV02") != null, "preview contains the rig")
        instance.queue_free()
    rig.queue_free()
    if failures == 0:
        print("[RigFull v0.2] PASS: nine PNGs loaded as actual animated Sprite2D parts, Skeleton2D, preview, and pose API")
    quit(1 if failures > 0 else 0)
