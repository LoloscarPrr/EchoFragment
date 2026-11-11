class_name PortadorTresPiezasVisual
extends Node2D

## EchoFragment: casco, torso y pelvis con huesos independientes.
## Experimento aislado; no modifica Player.gd ni las hitboxes.
const ROOT := "res://assets/player/portador_rig2d/"

@export var demo_cycle := true
var skeleton: Skeleton2D
var hips: Bone2D
var torso: Bone2D
var head: Bone2D
var art_loaded := false
var elapsed := 0.0
var state: StringName = &"idle_ready"
var state_progress := 0.0
var facing := 1.0

func _ready() -> void:
    for name in ["portador_pelvis_waist.png", "portador_torso_upper.png", "portador_head_helmet.png"]:
        if not ResourceLoader.exists(ROOT + name):
            push_warning("Falta recurso del rig 2D: " + ROOT + name)
            return
    skeleton = Skeleton2D.new()
    skeleton.name = "Armature"
    add_child(skeleton)
    hips = _bone(skeleton, "Hips", Vector2.ZERO)
    torso = _bone(hips, "Torso", Vector2(0, -82))
    var neck := _bone(torso, "Neck", Vector2(0, -241))
    head = _bone(neck, "Helmet", Vector2.ZERO)
    _sprite(torso, "portador_torso_upper.png", Vector2(515, 735), 0.58, 1)
    _sprite(head, "portador_head_helmet.png", Vector2(550, 760), 0.36, 2)
    _sprite(hips, "portador_pelvis_waist.png", Vector2(512, 287), 0.60, 3)
    art_loaded = true
    _apply_pose()

func _bone(parent: Node2D, bone_name: String, offset: Vector2) -> Bone2D:
    var bone := Bone2D.new()
    bone.name = bone_name
    bone.position = offset
    parent.add_child(bone)
    return bone

func _sprite(parent: Bone2D, image_name: String, pivot_px: Vector2, size_factor: float, depth: int) -> void:
    var sprite := Sprite2D.new()
    sprite.name = image_name.get_basename()
    sprite.texture = load(ROOT + image_name) as Texture2D
    sprite.centered = false
    sprite.position = -pivot_px * size_factor
    sprite.scale = Vector2.ONE * size_factor
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    sprite.z_index = depth
    parent.add_child(sprite)

func configure(next_state: StringName, progress: float, direction: float = 1.0) -> void:
    demo_cycle = false
    state = next_state
    state_progress = clampf(progress, 0.0, 1.0)
    facing = -1.0 if direction < 0.0 else 1.0
    _apply_pose()

func _process(delta: float) -> void:
    if not art_loaded:
        return
    elapsed += delta
    if demo_cycle:
        var t := fmod(elapsed, 6.0)
        state = &"idle_ready"
        state_progress = 0.0
        if t >= 2.0 and t < 4.0:
            state = &"run_forward"
            state_progress = (t - 2.0) / 2.0
        elif t >= 4.0 and t < 5.1:
            state = &"attack_light"
            state_progress = (t - 4.0) / 1.1
    _apply_pose()

func _apply_pose() -> void:
    if not art_loaded:
        return
    skeleton.scale.x = facing
    hips.position.y = 0.0
    torso.rotation = sin(elapsed * 2.5) * 0.02
    head.rotation = sin(elapsed * 1.8) * 0.065
    match state:
        &"run_forward":
            hips.position.y = -absf(sin(elapsed * 10.0)) * 5.0
            torso.rotation = -0.075 + sin(elapsed * 10.0) * 0.015
            head.rotation = 0.045 + sin(elapsed * 8.0) * 0.025
        &"attack_light":
            var windup := smoothstep(0.0, 0.45, state_progress)
            var release := smoothstep(0.52, 1.0, state_progress)
            torso.rotation = -0.15 * windup + 0.15 * release
            head.rotation = -torso.rotation * 0.45
            hips.position.y = 7.0 * windup - 7.0 * release
