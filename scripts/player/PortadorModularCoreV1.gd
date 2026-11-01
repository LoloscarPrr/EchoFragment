class_name PortadorModularCoreV1
extends Node2D

## EchoFragment Modular V1: ONLY a neutral, independently illustrated core.
## Animation is intentionally disabled until the neutral silhouette is approved.
## Does not replace Player.gd or the previous canonical visual.
const MANIFEST_PATH := "res://assets/player/portador_modular_v1/manifest.json"
const ART_DIR := "res://assets/player/portador_modular_v1/png/"

var art_loaded := false
var missing_files: Array[String] = []
var bones: Dictionary = {}
var sprites: Dictionary = {}

func _ready() -> void:
    if not FileAccess.file_exists(MANIFEST_PATH):
        push_error("Missing modular v1 art manifest")
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
    if not parsed is Dictionary:
        push_error("Invalid modular v1 art manifest")
        return

    var parts: Array = parsed.get("parts", [])
    if parts.size() != 4:
        push_error("Expected exactly four original core parts")
        return
    for part in parts:
        var path: String = ART_DIR + str(part.get("file", ""))
        if not ResourceLoader.exists(path):
            missing_files.append(path)
    if not missing_files.is_empty():
        push_warning("Modular V1: missing PNGs: " + str(missing_files))
        return

    var by_id: Dictionary = {}
    for part in parts:
        by_id[str(part["id"])] = part
    var skeleton := Skeleton2D.new()
    skeleton.name = "Armature"
    add_child(skeleton)

    var pelvis_anchor := _anchor(by_id["pelvis_waist"])
    var torso_anchor := _anchor(by_id["torso_upper"])
    var neck_anchor := _anchor(by_id["neck_guard"])
    var helmet_anchor := _anchor(by_id["head_helmet"])
    var hips := _bone(skeleton, "Hips", Vector2.ZERO)
    var torso := _bone(hips, "Torso", torso_anchor - pelvis_anchor)
    var neck := _bone(torso, "NeckGuard", neck_anchor - torso_anchor)
    var helmet := _bone(neck, "Helmet", helmet_anchor - neck_anchor)
    _sprite(hips, by_id["pelvis_waist"])
    _sprite(torso, by_id["torso_upper"])
    _sprite(neck, by_id["neck_guard"])
    _sprite(helmet, by_id["head_helmet"])
    bones = {
        "pelvis_waist": hips, "torso_upper": torso,
        "neck_guard": neck, "head_helmet": helmet
    }
    art_loaded = true

func _bone(parent: Node2D, bone_name: String, origin: Vector2) -> Bone2D:
    var bone := Bone2D.new()
    bone.name = bone_name
    bone.position = origin
    parent.add_child(bone)
    return bone

func _anchor(part: Dictionary) -> Vector2:
    var a: Array = part["anchor_master"]
    return Vector2(float(a[0]), float(a[1]))

func _sprite(parent: Bone2D, part: Dictionary) -> void:
    var t := load(ART_DIR + str(part["file"])) as Texture2D
    var sprite := Sprite2D.new()
    sprite.name = str(part["id"])
    sprite.centered = false
    sprite.texture = t
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    var pivot: Array = part["pivot_px"]
    sprite.position = -Vector2(float(pivot[0]), float(pivot[1]))
    sprite.z_index = int(part["z"])
    parent.add_child(sprite)
    sprites[str(part["id"])] = sprite
