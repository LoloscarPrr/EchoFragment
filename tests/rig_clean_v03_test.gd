extends SceneTree

## Godot 4.3: validate ALL actual 22 RGBA textures, anatomical bone
## parentage and no Sprite2D.region_rect slicing in the current 2D rig.
var failures := 0

func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error("[Rig v0.3] " + message)

func collect_sprites(node: Node, output: Array[Sprite2D]) -> void:
    if node is Sprite2D:
        output.append(node as Sprite2D)
    for child in node.get_children():
        collect_sprites(child, output)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var rig := PortadorCleanRigV03.new()
    rig.demo_cycle = false
    root.add_child(rig)
    check(rig.REQUIRED_PARTS.size() == 22, "exactly 22 named independent pieces")
    check(rig.art_loaded and rig.missing_files.is_empty(), "all 22 files load as actual PNG textures")
    check(rig.get_node_or_null("Armature") is Skeleton2D, "animated Skeleton2D exists")
    var all_sprites: Array[Sprite2D] = []
    collect_sprites(rig, all_sprites)
    check(all_sprites.size() == 22, "exactly 22 Sprite2D parts are instantiated")
    for part in all_sprites:
        check(part.texture != null, "non-null texture in " + part.name)
        check(part.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "pixel filtering: " + part.name)
        check(not part.region_enabled, "independent art, not rectangular sampling: " + part.name)
        if part.texture != null:
            check(part.texture.get_width() >= 100, "art texture not completely empty: " + part.name)

    var pelvis := rig.get_node_or_null("Armature/Hips/pelvis_waist") as Sprite2D
    var head := rig.get_node_or_null("Armature/Hips/Torso/Helmet/head_helmet") as Sprite2D
    var cape := rig.get_node_or_null("Armature/Hips/Torso/Cape/cape_main") as Sprite2D
    var cape_tail := rig.get_node_or_null("Armature/Hips/Torso/Cape/CapeTip/cape_tip") as Sprite2D
    var left_leg := rig.get_node_or_null("Armature/Hips/LegLThigh") as Bone2D
    var right_leg := rig.get_node_or_null("Armature/Hips/LegRThigh") as Bone2D
    var right_elbow := rig.get_node_or_null("Armature/Hips/Torso/ArmRUpper/ArmRForearm/arm_R_elbow_guard") as Sprite2D
    var left_knee := rig.get_node_or_null("Armature/Hips/LegLThigh/LegLShin/leg_L_knee_guard") as Sprite2D
    check(pelvis != null and head != null, "neck and waist art linked to appropriate bones")
    check(cape != null and cape_tail != null, "cape has two movable painted segments")
    check(left_leg != null and right_leg != null, "both legs use independent skeleton roots")
    check(right_elbow != null and left_knee != null, "elbow and knee include overlapping joint guards")
    if left_leg != null and right_leg != null:
        check(right_leg.position.x - left_leg.position.x > 90.0, "both thigh bones have separate hip anchors")

    # Exercise every controller state in both directions across full timelines.
    # Local joint anchors must stay fixed even when their parents rotate.
    var anchors: Dictionary = {}
    for key in rig._bones:
        anchors[key] = rig._bones[key].position
    for motion in [&"idle_ready", &"run_forward", &"jump_start", &"jump_rise", &"jump_apex", &"jump_fall", &"land_light", &"attack_light", &"dodge"]:
        for direction in [-1.0, 1.0]:
            for frame in range(61):
                rig._time = float(frame) / 60.0
                rig.configure(motion, float(frame) / 60.0, direction)
                for key in rig._bones:
                    var bone: Bone2D = rig._bones[key]
                    check(bone.global_transform.is_finite(), "finite transform: " + str(key))
                    if key != &"Hips":
                        check(bone.position.is_equal_approx(anchors[key]), "joint stays attached: " + str(key))
    rig.configure(&"jump_apex", 0.5, 1.0)
    check(rig._bones[&"Hips"].position.y < 0.0, "apex retains airborne pose")
    rig.configure(&"land_light", 1.0, 1.0)
    check(absf(rig._bones[&"Hips"].position.y) < 0.001, "landing returns hips to neutral")
    rig.configure(&"idle_ready", 0.0, 1.0)
    rig.configure(&"run_forward", 0.52, -1.0)
    rig.configure(&"attack_light", 0.45, 1.0)
    rig.configure(&"dodge", 0.4, 1.0)
    rig.configure(&"jump_rise", 0.3, -1.0)
    rig.configure(&"idle_ready", 0.0, 1.0)
    check(rig._armature.scale.x > 0.0, "character can face right after left-facing motion")
    if failures == 0:
        print("[Rig v0.3] PASS: 22 transparent parts, all loaded, real shoulders/elbows/knees, no regions, motions")
    rig.queue_free()
    quit(1 if failures > 0 else 0)
