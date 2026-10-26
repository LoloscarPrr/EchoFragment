class_name PortadorFullRigV02
extends Node2D

## EchoFragment 0.2: 9 source PNGs, 17 independently animated cutouts.
## Arms, legs and hands use Sprite2D.region_rect to separate articulation
## ranges of already-independent source illustrations. Unions are temporary;
## the animation pipeline will replace each region with retouched PNG pieces.
## Isolated experiment: never touches Player.gd, hitboxes or input.
const ASSET_DIR := "res://assets/player/portador_rig2d/v02/"
const ART := {
    "helmet": "portador_head_helmet.png",
    "torso": "portador_torso_upper.png",
    "pelvis": "portador_pelvis_waist.png",
    "cape": "portador_cape.png",
    "arm_R": "portador_arm_R.png",
    "arm_L": "portador_arm_L.png",
    "leg_R": "portador_leg_R.png",
    "leg_L": "portador_leg_L.png",
    "sword": "portador_sword.png",
}

@export var demo_cycle := true
@export var show_pivots := false

var state: StringName = &"idle_ready"
var state_progress := 0.0
var facing := 1.0
var art_loaded := false
var missing_files: Array[String] = []
var _time := 0.0
var _armature: Skeleton2D
var _bones: Dictionary = {}
var _proxy: PortadorRig2DPrototype

func _ready() -> void:
    for key in ART:
        var path: String = ASSET_DIR + str(ART[key])
        if not ResourceLoader.exists(path):
            missing_files.append(path)
    if not missing_files.is_empty():
        _proxy = PortadorRig2DPrototype.new()
        _proxy.name = "FallbackProvisional"
        _proxy.demo_cycle = false
        add_child(_proxy)
        push_warning("Rig 0.2: faltan " + str(missing_files.size()) + " PNG. Usando figura tecnica; ver README del paquete.")
        return
    _armature = Skeleton2D.new()
    _armature.name = "Armature"
    add_child(_armature)

    var hips := _bone(_armature, &"Hips", Vector2.ZERO)
    var torso := _bone(hips, &"Torso", Vector2(0, -45))
    var helmet := _bone(torso, &"Helmet", Vector2(0, -153))
    var cape := _bone(torso, &"Cape", Vector2(-21, -134))
    var cape_tip := _bone(cape, &"CapeTip", Vector2(-87, 146))
    var left_thigh := _bone(hips, &"LegLThigh", Vector2(-31, 22))
    var left_shin := _bone(left_thigh, &"LegLShin", Vector2(2, 90))
    var left_foot := _bone(left_shin, &"LegLFoot", Vector2(19, 91))
    var right_thigh := _bone(hips, &"LegRThigh", Vector2(29, 22))
    var right_shin := _bone(right_thigh, &"LegRShin", Vector2(9, 84))
    var right_foot := _bone(right_shin, &"LegRFoot", Vector2(15, 94))
    var arm_l := _bone(torso, &"ArmLUpper", Vector2(-67, -119))
    var fore_l := _bone(arm_l, &"ArmLForearm", Vector2(-1, 64))
    var hand_l := _bone(fore_l, &"ArmLHand", Vector2(15, 73))
    var arm_r := _bone(torso, &"ArmRUpper", Vector2(68, -119))
    var fore_r := _bone(arm_r, &"ArmRForearm", Vector2(7, 66))
    var hand_r := _bone(fore_r, &"ArmRHand", Vector2(28, 72))
    var sword := _bone(hand_r, &"Sword", Vector2(6, 25))

    # Render order: cape behind all, then rear limbs, torso/helmet, front limbs, sword.
    _sprite(cape, "cape", "cape", Vector2(840, 245), 0.235, -26)
    _region(left_thigh, "leg_L", "leg_L_thigh", 0, 708, Vector2(515, 270), 0.205, -19)
    _region(left_shin, "leg_L", "leg_L_shin", 650, 1150, Vector2(525, 708), 0.205, -18)
    _region(left_foot, "leg_L", "leg_L_foot", 1090, 1536, Vector2(620, 1150), 0.205, -17)
    _region(arm_l, "arm_L", "arm_L_upper", 0, 700, Vector2(488, 310), 0.165, -15)
    _region(fore_l, "arm_L", "arm_L_forearm", 638, 1140, Vector2(483, 700), 0.165, -14)
    _region(hand_l, "arm_L", "arm_L_hand", 1075, 1536, Vector2(575, 1140), 0.165, -13)
    _sprite(torso, "torso", "torso", Vector2(515, 752), 0.305, 0)
    _sprite(helmet, "helmet", "helmet", Vector2(550, 810), 0.205, 4)
    _region(right_thigh, "leg_R", "leg_R_thigh", 0, 684, Vector2(482, 275), 0.205, 6)
    _region(right_shin, "leg_R", "leg_R_shin", 626, 1140, Vector2(525, 684), 0.205, 7)
    _region(right_foot, "leg_R", "leg_R_foot", 1080, 1536, Vector2(600, 1140), 0.205, 8)
    _sprite(hips, "pelvis", "pelvis", Vector2(512, 298), 0.246, 10)
    _region(arm_r, "arm_R", "arm_R_upper", 0, 714, Vector2(480, 315), 0.166, 11)
    _region(fore_r, "arm_R", "arm_R_forearm", 650, 1145, Vector2(520, 714), 0.166, 12)
    _region(hand_r, "arm_R", "arm_R_hand", 1080, 1536, Vector2(690, 1145), 0.166, 13)
    _sprite(sword, "sword", "sword", Vector2(844, 229), 0.145, 15)
    # Cape tip is a separate bone prepared for later PNG; keep it idle
    # until the cape itself is repainted into independent physical segments.
    cape_tip.rotation = 0.0
    art_loaded = true
    _apply_pose()

func _bone(parent: Node2D, bone_name: StringName, local_offset: Vector2) -> Bone2D:
    var bone := Bone2D.new()
    bone.name = String(bone_name)
    bone.position = local_offset
    parent.add_child(bone)
    _bones[bone_name] = bone
    return bone

func _sprite(parent: Bone2D, source_id: String, label: String, source_pivot: Vector2, size_factor: float, depth: int) -> void:
    var tex := load(ASSET_DIR + str(ART[source_id])) as Texture2D
    var sprite := Sprite2D.new()
    sprite.name = label
    sprite.texture = tex
    sprite.centered = false
    sprite.scale = Vector2.ONE * size_factor
    sprite.position = -source_pivot * size_factor
    sprite.z_index = depth
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    parent.add_child(sprite)

func _region(parent: Bone2D, source_id: String, label: String, begin_y: int, end_y: int, source_pivot: Vector2, size_factor: float, depth: int) -> void:
    var tex := load(ASSET_DIR + str(ART[source_id])) as Texture2D
    var sprite := Sprite2D.new()
    sprite.name = label
    sprite.texture = tex
    sprite.region_enabled = true
    var y_min := clampi(begin_y, 0, tex.get_height())
    var y_max := clampi(end_y, y_min, tex.get_height())
    sprite.region_rect = Rect2(0.0, float(y_min), float(tex.get_width()), float(y_max - y_min))
    sprite.centered = false
    sprite.scale = Vector2.ONE * size_factor
    sprite.position = (Vector2(0, y_min) - source_pivot) * size_factor
    sprite.z_index = depth
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    parent.add_child(sprite)

func configure(new_state: StringName, progress: float, direction: float = 1.0) -> void:
    demo_cycle = false
    state = new_state
    state_progress = clampf(progress, 0.0, 1.0)
    facing = -1.0 if direction < 0.0 else 1.0
    _apply_pose()

func _process(delta: float) -> void:
    _time += delta
    if demo_cycle:
        var t := fmod(_time, 5.5)
        state = &"idle_ready"
        state_progress = 0.0
        if t > 1.15 and t <= 2.3:
            state = &"run_forward"
            state_progress = (t - 1.15) / 1.15
        elif t > 2.3 and t <= 3.6:
            state = &"attack_light"
            state_progress = (t - 2.3) / 1.3
        elif t > 3.6 and t <= 4.5:
            state = &"dodge"
            state_progress = (t - 3.6) / 0.9
        elif t > 4.5 and t <= 5.0:
            state = &"jump_rise"
            state_progress = (t - 4.5) / 0.5
    _apply_pose()

func _apply_pose() -> void:
    if not art_loaded:
        if is_instance_valid(_proxy):
            _proxy.configure(state, state_progress, facing, 0)
        return
    _armature.scale.x = facing
    var gait := sin(_time * 11.0)
    var breathing := sin(_time * 2.7)
    var hips := _bones[&"Hips"] as Bone2D
    var torso := _bones[&"Torso"] as Bone2D
    var helmet := _bones[&"Helmet"] as Bone2D
    var cape := _bones[&"Cape"] as Bone2D
    var thigh_l := _bones[&"LegLThigh"] as Bone2D
    var thigh_r := _bones[&"LegRThigh"] as Bone2D
    var shin_l := _bones[&"LegLShin"] as Bone2D
    var shin_r := _bones[&"LegRShin"] as Bone2D
    var foot_l := _bones[&"LegLFoot"] as Bone2D
    var foot_r := _bones[&"LegRFoot"] as Bone2D
    var arm_l := _bones[&"ArmLUpper"] as Bone2D
    var arm_r := _bones[&"ArmRUpper"] as Bone2D
    var fore_l := _bones[&"ArmLForearm"] as Bone2D
    var fore_r := _bones[&"ArmRForearm"] as Bone2D
    var hand_l := _bones[&"ArmLHand"] as Bone2D
    var hand_r := _bones[&"ArmRHand"] as Bone2D
    var sword := _bones[&"Sword"] as Bone2D

    hips.position = Vector2.ZERO
    hips.rotation = 0.0
    torso.rotation = breathing * 0.018
    helmet.rotation = breathing * 0.042
    cape.rotation = sin(_time * 3.5) * 0.09
    thigh_l.rotation = -0.04
    thigh_r.rotation = 0.04
    shin_l.rotation = 0.04
    shin_r.rotation = -0.04
    foot_l.rotation = 0.0
    foot_r.rotation = 0.0
    arm_l.rotation = 0.12
    arm_r.rotation = -0.08
    fore_l.rotation = 0.0
    fore_r.rotation = 0.0
    hand_l.rotation = 0.0
    hand_r.rotation = 0.0
    sword.rotation = 0.05

    match state:
        &"run_forward":
            hips.position.y = -absf(gait) * 7.0
            torso.rotation = -0.14 + breathing * 0.01
            helmet.rotation = 0.07
            thigh_l.rotation = -gait * 0.55
            thigh_r.rotation = gait * 0.55
            shin_l.rotation = maxf(0.0, gait) * 0.55
            shin_r.rotation = maxf(0.0, -gait) * 0.55
            foot_l.rotation = -shin_l.rotation * 0.45
            foot_r.rotation = -shin_r.rotation * 0.45
            arm_l.rotation = gait * 0.30
            arm_r.rotation = -gait * 0.24
            fore_l.rotation = 0.24
            fore_r.rotation = -0.10
            cape.rotation = -0.32 + sin(_time * 8.0) * 0.12
        &"attack_light":
            var windup := smoothstep(0.0, 0.28, state_progress)
            var release := smoothstep(0.31, 0.60, state_progress)
            var recover := smoothstep(0.63, 1.0, state_progress)
            torso.rotation = -0.22 * windup + 0.52 * release - 0.30 * recover
            helmet.rotation = -torso.rotation * 0.45
            arm_r.rotation = -1.15 * windup + 2.08 * release - 0.93 * recover
            fore_r.rotation = -0.74 * windup + 0.86 * release - 0.12 * recover
            hand_r.rotation = -0.30 * windup + 0.56 * release - 0.26 * recover
            sword.rotation = -0.30 * windup - 0.64 * release + 0.94 * recover
            arm_l.rotation = -0.24 * windup + 0.34 * release - 0.10 * recover
            thigh_r.rotation = -0.35 * windup + 0.48 * release - 0.13 * recover
            thigh_l.rotation = 0.22 * windup - 0.32 * release + 0.10 * recover
            cape.rotation = -0.28 * windup - 0.36 * release + 0.64 * recover
            hips.position.y = 4.0 * windup - 4.0 * recover
        &"dodge":
            var duck := sin(PI * state_progress)
            hips.position.y = 21.0 * duck
            hips.rotation = 0.28 * duck
            torso.rotation = 0.50 * duck
            helmet.rotation = -0.18 * duck
            arm_r.rotation = -0.62 * duck
            fore_r.rotation = -0.5 * duck
            thigh_l.rotation = 0.88 * duck
            thigh_r.rotation = -0.90 * duck
            shin_l.rotation = -0.85 * duck
            shin_r.rotation = 0.70 * duck
            cape.rotation = -0.5 * duck
        &"jump_rise", &"jump_fall":
            hips.position.y = -14.0
            thigh_l.rotation = 0.38
            thigh_r.rotation = -0.50
            shin_l.rotation = -0.64
            shin_r.rotation = 0.52
            cape.rotation = 0.22
        &"guard":
            arm_r.rotation = -0.65
            fore_r.rotation = -0.25
            sword.rotation = -0.15
            torso.rotation = -0.07
