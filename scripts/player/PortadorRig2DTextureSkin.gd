class_name PortadorRig2DTextureSkin
extends Node2D

## First-pass image cutouts from approved helmeted reference.
## Requires all eight PNGs in res://assets/player/portador_rig2d/.
const ASSET_DIR := "res://assets/player/portador_rig2d/"
const IMG_SCALE := 0.45
const CENTER_SOURCE := Vector2(470.0, 300.0)
const CENTER_RIG := Vector2(0.0, -65.0)

const PARTS := [
    ["cape_back", "Armature/Hips/Torso/Cape", Vector2(162, 239)],
    ["left_leg", "Armature/Hips/BackThigh", Vector2(326, 336)],
    ["right_leg", "Armature/Hips/FrontThigh", Vector2(449, 340)],
    ["left_arm", "Armature/Hips/Torso/RearArm", Vector2(359, 247)],
    ["torso_waist", "Armature/Hips/Torso", Vector2(388, 234)],
    ["right_arm", "Armature/Hips/Torso/SwordUpperArm", Vector2(481, 254)],
    ["head", "Armature/Hips/Torso/Neck/Helmet", Vector2(437, 167)],
    ["sword", "Armature/Hips/Torso/SwordUpperArm/SwordForearm/Sword", Vector2(495, 346)]
]

func _ready() -> void:
    var rig := get_parent() as PortadorRig2DPrototype
    if rig == null:
        push_warning("Texture skin must be child of PortadorRig2DPrototype")
        return

    var loaded: Dictionary = {}
    for part in PARTS:
        var path: String = ASSET_DIR + str(part[0]) + ".png"
        if not ResourceLoader.exists(path):
            push_warning("Missing art " + path + "; retaining placeholder rig")
            return
        loaded[part[0]] = load(path)

    _hide_provisional_shapes(rig.get_node("Armature"))
    for part in PARTS:
        var bone := rig.get_node_or_null(str(part[1])) as Bone2D
        if bone == null:
            push_warning("Bone missing: " + str(part[1]))
            continue
        var sprite := Sprite2D.new()
        sprite.name = "Cutout_" + str(part[0])
        sprite.texture = loaded[part[0]]
        sprite.centered = false
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        var neutral_position: Vector2 = (part[2] - CENTER_SOURCE) * IMG_SCALE + CENTER_RIG
        sprite.position = bone.to_local(rig.to_global(neutral_position))
        sprite.scale = Vector2.ONE * IMG_SCALE
        bone.add_child(sprite)

func _hide_provisional_shapes(node: Node) -> void:
    for child in node.get_children():
        if child is Polygon2D or child is Line2D:
            (child as CanvasItem).visible = false
        _hide_provisional_shapes(child)
