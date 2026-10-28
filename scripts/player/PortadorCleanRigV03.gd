class_name PortadorCleanRigV03
extends PortadorFullRigV02

## Anatomy-first rig. Each drawable is an independent alpha PNG, not a
## horizontal Sprite2D.region_rect of an entire arm or leg.
## Retains v0.2's public configure(state, progress, facing) API.
const PART_DIR := "res://assets/player/portador_rig2d/v03/"
const REQUIRED_PARTS := [
    "head_helmet", "torso_upper", "pelvis_waist",
    "arm_L_upper", "arm_L_forearm", "hand_L", "arm_L_elbow_guard",
    "arm_R_upper", "arm_R_forearm", "hand_R", "arm_R_elbow_guard",
    "leg_L_thigh", "leg_L_shin", "foot_L", "leg_L_knee_guard",
    "leg_R_thigh", "leg_R_shin", "foot_R", "leg_R_knee_guard",
    "cape_main", "cape_tip", "sword"
]

func _ready() -> void:
    missing_files.clear()
    for part in REQUIRED_PARTS:
        var path: String = PART_DIR + "portador_" + part + ".png"
        if not ResourceLoader.exists(path):
            missing_files.append(path)
    if not missing_files.is_empty():
        # Keep gameplay safe if the generation build did not export all PNGs.
        super._ready()
        push_warning("Rig v0.3 cutouts missing; v0.2 visual retained.")
        return
    _armature = Skeleton2D.new()
    _armature.name = "Armature"
    add_child(_armature)

    var hips := _bone(_armature, &"Hips", Vector2.ZERO)
    var torso := _bone(hips, &"Torso", Vector2(0, -2))
    var helmet := _bone(torso, &"Helmet", Vector2(0, -149))
    var cape := _bone(torso, &"Cape", Vector2(-28, -126))
    var cape_tip := _bone(cape, &"CapeTip", Vector2(-83, 122))
    var left_thigh := _bone(hips, &"LegLThigh", Vector2(-57, 14))
    var left_shin := _bone(left_thigh, &"LegLShin", Vector2(29, 115))
    var left_foot := _bone(left_shin, &"LegLFoot", Vector2(18, 104))
    var right_thigh := _bone(hips, &"LegRThigh", Vector2(42, 14))
    var right_shin := _bone(right_thigh, &"LegRShin", Vector2(24, 115))
    var right_foot := _bone(right_shin, &"LegRFoot", Vector2(14, 103))
    var arm_l := _bone(torso, &"ArmLUpper", Vector2(-72, -111))
    var fore_l := _bone(arm_l, &"ArmLForearm", Vector2(24, 76))
    var hand_l := _bone(fore_l, &"ArmLHand", Vector2(5, 76))
    var arm_r := _bone(torso, &"ArmRUpper", Vector2(72, -111))
    var fore_r := _bone(arm_r, &"ArmRForearm", Vector2(-20, 74))
    var hand_r := _bone(fore_r, &"ArmRHand", Vector2(31, 78))
    var sword := _bone(hand_r, &"Sword", Vector2(16, 35))

    # Paint order matters: cape/rear leg, torso, helmet, rear arm over
    # hollow socket, front leg, waist, sword arm & the sword.
    _part(cape, "cape_main", Vector2(870, 255), .225, -30)
    _part(cape_tip, "cape_tip", Vector2(510, 810), .225, -29)
    _part(left_thigh, "leg_L_thigh", Vector2(420, 175), .22, -21)
    _part(left_shin, "leg_L_shin", Vector2(550, 700), .22, -20)
    _part(left_shin, "leg_L_knee_guard", Vector2(550, 700), .22, -19)
    _part(left_foot, "foot_L", Vector2(635, 1170), .22, -18)
    _part(torso, "torso_upper", Vector2(512, 750), .305, 0)
    _part(arm_l, "arm_L_upper", Vector2(440, 215), .172, 2)
    _part(fore_l, "arm_L_forearm", Vector2(570, 650), .172, 3)
    _part(fore_l, "arm_L_elbow_guard", Vector2(570, 650), .172, 4)
    _part(hand_l, "hand_L", Vector2(600, 1100), .172, 5)
    _part(helmet, "head_helmet", Vector2(545, 870), .175, 6)
    _part(right_thigh, "leg_R_thigh", Vector2(430, 175), .22, 7)
    _part(right_shin, "leg_R_shin", Vector2(540, 700), .22, 8)
    _part(right_shin, "leg_R_knee_guard", Vector2(540, 700), .22, 9)
    _part(right_foot, "foot_R", Vector2(605, 1170), .22, 10)
    _part(hips, "pelvis_waist", Vector2(512, 265), .285, 11)
    _part(arm_r, "arm_R_upper", Vector2(525, 230), .172, 12)
    _part(fore_r, "arm_R_forearm", Vector2(410, 665), .172, 13)
    _part(fore_r, "arm_R_elbow_guard", Vector2(410, 665), .172, 14)
    _part(hand_r, "hand_R", Vector2(590, 1125), .172, 15)
    _part(sword, "sword", Vector2(855, 240), .125, 16)
    art_loaded = true
    _apply_pose()

func _part(parent: Bone2D, art: String, source_pivot: Vector2, size_factor: float, depth: int) -> void:
    var texture := load(PART_DIR + "portador_" + art + ".png") as Texture2D
    var sprite := Sprite2D.new()
    sprite.name = art
    sprite.texture = texture
    sprite.centered = false
    var natural_height := 1024.0 if art == "head_helmet" or art == "torso_upper" or art == "pelvis_waist" else 1536.0
    sprite.scale = Vector2(size_factor * 1024.0 / float(texture.get_width()), size_factor * natural_height / float(texture.get_height()))
    sprite.position = -source_pivot * size_factor
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    sprite.z_index = depth
    parent.add_child(sprite)

func _apply_pose() -> void:
    # Reuse the stable combat-driven animation API, but bound the exaggeration
    # of the old arm/leg poses until hidden joint surfaces are painted.
    super._apply_pose()
    if not art_loaded or _armature == null:
        return
    var forearm := _bones[&"ArmRForearm"] as Bone2D
    var offhand := _bones[&"ArmLForearm"] as Bone2D
    var left_shin := _bones[&"LegLShin"] as Bone2D
    var right_shin := _bones[&"LegRShin"] as Bone2D
    var left_thigh := _bones[&"LegLThigh"] as Bone2D
    var right_thigh := _bones[&"LegRThigh"] as Bone2D
    var torso := _bones[&"Torso"] as Bone2D
    forearm.rotation = clampf(forearm.rotation, -0.30, 0.34)
    offhand.rotation = clampf(offhand.rotation, -0.28, 0.30)
    left_shin.rotation = clampf(left_shin.rotation, -0.32, 0.40)
    right_shin.rotation = clampf(right_shin.rotation, -0.32, 0.40)
    left_thigh.rotation = clampf(left_thigh.rotation, -0.42, 0.42)
    right_thigh.rotation = clampf(right_thigh.rotation, -0.42, 0.42)
    torso.rotation = clampf(torso.rotation, -0.25, 0.36)
