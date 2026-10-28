class_name PortadorRig2DPrototype
extends Node2D

## Prototipo técnico articulado: arte geométrico TEMPORAL.
## No reemplaza las ilustraciones canónicas ni modifica daño/física/hitboxes.
## Las piezas definitivas deberán ser PNG transparentes redibujados por capa.

@export var demo_cycle := false

const ARMOR := Color("#222630")
const ARMOR_EDGE := Color("#63616A")
const ARMOR_DARK := Color("#101217")
const CLOTH := Color("#70202F")
const CLOTH_SHADE := Color("#3B1421")
const METAL := Color("#C3C7CF")
const ECHO := Color("#F13E52")

var _bones: Dictionary = {}
var _armature: Skeleton2D
var _blade_glow: Line2D
var _elapsed := 0.0
var _state: StringName = &"idle_ready"
var _progress := 0.0
var _facing := 1.0

func _ready() -> void:
    _armature = Skeleton2D.new()
    _armature.name = "Armature"
    add_child(_armature)

    var hips := _bone(_armature, &"Hips", Vector2(0, -45))
    var back_leg := _bone(hips, &"BackThigh", Vector2(-9, 7))
    _poly(back_leg, "ThighArmor", [Vector2(-7, -2), Vector2(8, -2), Vector2(9, 27), Vector2(-5, 29)], ARMOR_DARK, -4)
    var back_shin := _bone(back_leg, &"BackShin", Vector2(-1, 26))
    _poly(back_shin, "ShinArmor", [Vector2(-6, -3), Vector2(6, -3), Vector2(5, 30), Vector2(-7, 29)], ARMOR_EDGE, -3)
    _poly(back_shin, "BackBoot", [Vector2(-9, 26), Vector2(5, 25), Vector2(18, 32), Vector2(17, 36), Vector2(-10, 36)], ARMOR_DARK, -3)

    var torso := _bone(hips, &"Torso", Vector2(0, -20))
    var cape := _bone(torso, &"Cape", Vector2(-13, -22))
    _poly(cape, "CapeShadow", [Vector2(3, 0), Vector2(-11, 3), Vector2(-28, 21), Vector2(-55, 47), Vector2(-38, 44), Vector2(-17, 38), Vector2(5, 18)], CLOTH_SHADE, -10)
    _poly(cape, "CapeOuter", [Vector2(0, -3), Vector2(-18, 2), Vector2(-40, 17), Vector2(-67, 41), Vector2(-57, 36), Vector2(-34, 38), Vector2(-9, 22)], CLOTH, -9)
    var cape_tip := _bone(cape, &"CapeTip", Vector2(-34, 35))
    _poly(cape_tip, "CapeTipArt", [Vector2(4, -7), Vector2(-15, -4), Vector2(-28, 19), Vector2(-13, 12), Vector2(-6, 17), Vector2(8, 1)], CLOTH, -9)

    var rear_arm := _bone(torso, &"RearArm", Vector2(-17, -25))
    _poly(rear_arm, "RearPauldron", [Vector2(-11, -7), Vector2(6, -9), Vector2(12, 11), Vector2(-3, 18)], ARMOR_DARK, -5)
    var rear_forearm := _bone(rear_arm, &"RearForearm", Vector2(-2, 19))
    _poly(rear_forearm, "RearBracer", [Vector2(-6, -2), Vector2(6, -2), Vector2(6, 23), Vector2(-7, 22)], ARMOR_EDGE, -5)

    _poly(torso, "ChestPlate", [Vector2(-16, -29), Vector2(-4, -37), Vector2(15, -29), Vector2(19, -4), Vector2(10, 17), Vector2(-11, 17), Vector2(-18, -4)], ARMOR, 2)
    _poly(torso, "ChestHighlight", [Vector2(-12, -27), Vector2(-2, -32), Vector2(12, -26), Vector2(7, -14), Vector2(0, -10), Vector2(-8, -15)], ARMOR_EDGE, 3)
    _poly(torso, "Collar", [Vector2(-15, -32), Vector2(-2, -39), Vector2(15, -31), Vector2(9, -24), Vector2(-9, -24)], CLOTH, 5)
    _poly(hips, "BeltAndSkirt", [Vector2(-15, -10), Vector2(14, -10), Vector2(16, 8), Vector2(11, 23), Vector2(-2, 14), Vector2(-12, 25), Vector2(-16, 7)], ARMOR_DARK, 4)
    _poly(hips, "Belt", [Vector2(-16, -10), Vector2(14, -10), Vector2(14, -4), Vector2(-16, -4)], ARMOR_EDGE, 5)
    _poly(hips, "Brooch", [Vector2(-4, -8), Vector2(2, -12), Vector2(7, -7), Vector2(2, -2)], ECHO, 6)

    var front_leg := _bone(hips, &"FrontThigh", Vector2(10, 7))
    _poly(front_leg, "FrontThighArmor", [Vector2(-8, -4), Vector2(8, -2), Vector2(10, 23), Vector2(2, 30), Vector2(-9, 24)], ARMOR, 7)
    _poly(front_leg, "Knee", [Vector2(-11, 20), Vector2(10, 19), Vector2(8, 30), Vector2(-10, 29)], ARMOR_EDGE, 8)
    var front_shin := _bone(front_leg, &"FrontShin", Vector2(2, 26))
    _poly(front_shin, "FrontShinArmor", [Vector2(-7, -4), Vector2(7, -4), Vector2(8, 27), Vector2(-6, 30)], ARMOR, 7)
    _poly(front_shin, "FrontBoot", [Vector2(-8, 26), Vector2(5, 25), Vector2(18, 31), Vector2(18, 36), Vector2(-8, 36)], ARMOR_DARK, 8)

    var neck := _bone(torso, &"Neck", Vector2(0, -39))
    var head := _bone(neck, &"Helmet", Vector2(0, -1))
    _poly(head, "HelmetShell", [Vector2(-11, -13), Vector2(-6, -24), Vector2(-2, -18), Vector2(5, -23), Vector2(12, -10), Vector2(11, 7), Vector2(3, 13), Vector2(-8, 8)], ARMOR_DARK, 9)
    _poly(head, "HelmetPlate", [Vector2(-9, -10), Vector2(-4, -16), Vector2(7, -11), Vector2(9, 2), Vector2(1, 9), Vector2(-8, 4)], ARMOR_EDGE, 10)
    _poly(head, "HelmetFace", [Vector2(-8, -2), Vector2(7, -1), Vector2(3, 5), Vector2(-7, 3)], ARMOR_DARK, 11)
    _poly(head, "Visor", [Vector2(-6, 0), Vector2(8, -2), Vector2(4, 2), Vector2(-6, 3)], ECHO, 12)

    var sword_arm := _bone(torso, &"SwordUpperArm", Vector2(17, -24))
    _poly(sword_arm, "SwordPauldron", [Vector2(-10, -9), Vector2(8, -11), Vector2(12, 13), Vector2(-6, 18)], ARMOR_EDGE, 12)
    var sword_forearm := _bone(sword_arm, &"SwordForearm", Vector2(4, 22))
    _poly(sword_forearm, "SwordBracer", [Vector2(-7, -4), Vector2(6, -4), Vector2(6, 23), Vector2(-7, 22)], ARMOR, 13)
    var weapon := _bone(sword_forearm, &"Sword", Vector2(0, 21))
    _poly(weapon, "Hilt", [Vector2(-11, -3), Vector2(12, -3), Vector2(12, 3), Vector2(-11, 3)], ARMOR_DARK, 14)
    _poly(weapon, "Crossguard", [Vector2(7, -13), Vector2(13, -12), Vector2(17, 12), Vector2(11, 13)], ARMOR_EDGE, 15)
    _poly(weapon, "Blade", [Vector2(13, -5), Vector2(77, -3), Vector2(96, 0), Vector2(77, 4), Vector2(13, 5)], METAL, 14)
    _blade_glow = Line2D.new()
    _blade_glow.name = "EchoBlade"
    _blade_glow.points = PackedVector2Array([Vector2(18, 0), Vector2(90, 0)])
    _blade_glow.width = 2.0
    _blade_glow.default_color = ECHO
    weapon.add_child(_blade_glow)
    _apply_pose()

func _bone(parent: Node2D, key: StringName, offset: Vector2) -> Bone2D:
    var bone := Bone2D.new()
    bone.name = String(key)
    bone.position = offset
    parent.add_child(bone)
    _bones[key] = bone
    return bone

func _poly(parent: Node2D, label: String, verts: Array, tint: Color, depth: int) -> void:
    var shape := Polygon2D.new()
    shape.name = label
    shape.polygon = PackedVector2Array(verts)
    shape.color = tint
    shape.z_index = depth
    parent.add_child(shape)

func set_pose(state: StringName, progress: float, facing: float = 1.0) -> void:
    demo_cycle = false
    _state = state
    _progress = clampf(progress, 0.0, 1.0)
    _facing = -1.0 if facing < 0.0 else 1.0
    _apply_pose()

func _process(delta: float) -> void:
    _elapsed += delta
    if demo_cycle:
        var t := fmod(_elapsed, 3.6)
        _state = &"idle_ready"
        _progress = 0.0
        if t > 0.75 and t <= 1.5:
            _state = &"run_forward"
            _progress = (t - 0.75) / 0.75
        elif t > 1.5 and t <= 2.35:
            _state = &"attack_light"
            _progress = (t - 1.5) / 0.85
        elif t > 2.35 and t <= 2.85:
            _state = &"dodge"
            _progress = (t - 2.35) / 0.5
    _apply_pose()

func _apply_pose() -> void:
    if _armature == null:
        return
    _armature.scale.x = _facing
    var breath := sin(_elapsed * 3.2) * 0.026
    var run := _state == &"run_forward"
    var attack := _state == &"attack_light"
    var dodge := _state == &"dodge"
    var stride := sin(_elapsed * 13.0) if run else 0.0

    var hips := _bones[&"Hips"] as Bone2D
    var torso := _bones[&"Torso"] as Bone2D
    var front_thigh := _bones[&"FrontThigh"] as Bone2D
    var front_shin := _bones[&"FrontShin"] as Bone2D
    var back_thigh := _bones[&"BackThigh"] as Bone2D
    var back_shin := _bones[&"BackShin"] as Bone2D
    var sword_arm := _bones[&"SwordUpperArm"] as Bone2D
    var sword_forearm := _bones[&"SwordForearm"] as Bone2D
    var sword := _bones[&"Sword"] as Bone2D
    var rear_arm := _bones[&"RearArm"] as Bone2D
    var cape := _bones[&"Cape"] as Bone2D
    var cape_tip := _bones[&"CapeTip"] as Bone2D
    var head := _bones[&"Helmet"] as Bone2D

    hips.rotation = 0.0
    torso.rotation = breath
    front_thigh.rotation = stride * 0.35
    front_shin.rotation = -maxf(0.0, stride) * 0.34
    back_thigh.rotation = -stride * 0.35
    back_shin.rotation = -maxf(0.0, -stride) * 0.34
    sword_arm.rotation = -0.22 - stride * 0.12
    sword_forearm.rotation = -0.2
    sword.rotation = 0.8
    rear_arm.rotation = 0.15 + stride * 0.2
    head.rotation = -breath * 0.55
    cape.rotation = sin(_elapsed * 4.0) * 0.10 - (0.25 if run else 0.0)
    cape_tip.rotation = sin(_elapsed * 5.4 + 0.9) * 0.18
    _blade_glow.visible = attack

    if attack:
        var windup := smoothstep(0.0, 0.32, _progress)
        var strike := smoothstep(0.33, 0.62, _progress)
        var recover := smoothstep(0.64, 1.0, _progress)
        torso.rotation = -0.16 * windup + 0.42 * strike - 0.26 * recover
        sword_arm.rotation = -1.25 * windup + 1.95 * strike - 0.70 * recover
        sword_forearm.rotation = -0.85 * windup + 0.95 * strike - 0.10 * recover
        sword.rotation = -0.45 * windup - 1.30 * strike + 1.75 * recover
        front_thigh.rotation = -0.27 * windup + 0.33 * strike - 0.06 * recover
        back_thigh.rotation = 0.28 * windup - 0.37 * strike + 0.09 * recover
        head.rotation = 0.08 * windup - 0.15 * strike + 0.07 * recover
        cape.rotation = -0.12 * windup - 0.48 * strike + 0.50 * recover
        cape_tip.rotation = 0.20 * strike - 0.2 * recover
    elif dodge:
        var roll := sin(_progress * PI)
        hips.rotation = roll * 0.34
        torso.rotation = roll * 0.64
        sword_arm.rotation -= roll * 0.75
        front_thigh.rotation += roll * 0.95
        back_thigh.rotation -= roll * 0.65
        cape.rotation -= roll * 0.35
