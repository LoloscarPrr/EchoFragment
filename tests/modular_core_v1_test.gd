extends SceneTree

## Test neutral art build; deliberately do not animate any parts.
var failures := 0

func require(ok: bool, description: String) -> void:
    if not ok:
        failures += 1
        push_error("[Modular V1] " + description)

func _initialize() -> void:
    call_deferred("_test")

func _test() -> void:
    var rig := PortadorModularCoreV1.new()
    root.add_child(rig)
    require(rig.art_loaded, "four independently authored PNGs must load")
    require(rig.get_node_or_null("Armature") is Skeleton2D, "Skeleton2D assembled")
    require(rig.sprites.size() == 4, "exactly four original independent Sprite2D pieces")
    require(rig.bones.size() == 4, "four articulable bone pivots")
    for part in rig.sprites:
        var sprite = rig.sprites[part] as Sprite2D
        require(sprite.texture != null, "PNG loaded for " + str(part))
        require(not sprite.region_enabled, "NO region cropping for " + str(part))
        require(sprite.scale == Vector2.ONE, "NO per-part scale patches for " + str(part))
        var img = sprite.texture.get_image()
        require(img.get_width() >= 300, "full-size asset, not Canva 200px thumbnail: " + str(part))
    var scene := load("res://scenes/experiments/PortadorModularCoreV1Preview.tscn") as PackedScene
    require(scene != null, "static Godot preview scene loads")
    if scene != null:
        var preview := scene.instantiate()
        root.add_child(preview)
        require(preview.get_node_or_null("PortadorCore") != null, "preview uses same rig and PNGs")
        preview.queue_free()
    rig.queue_free()
    print("[Modular V1] ", "PASS" if failures == 0 else str(failures) + " failed")
    quit(1 if failures > 0 else 0)
