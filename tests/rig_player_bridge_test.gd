extends SceneTree

## Verify the opt-in player bridge does not replace the canonical art when PNGs
## are missing. This intentionally exercises the actual gameplay Main scene.
var failures := 0

func _check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error("[ArticulatedPlayerBridge] " + description)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene := load("res://scenes/main/Main.tscn") as PackedScene
    _check(scene != null, "Main scene loads")
    if scene == null:
        quit(1)
        return

    var instance := scene.instantiate()
    root.add_child(instance)
    var player = instance.get_node_or_null("Player")
    _check(player != null, "Main contains Player")
    if player != null:
        var rig = player.get_node_or_null("ArticulatedVisual")
        _check(rig != null, "Player attaches experimental visual bridge")
        if rig != null:
            _check(rig is PortadorCleanRigV03, "Player bridge uses the anatomical 22-part v0.3 rig")
            _check(not rig.demo_cycle, "Gameplay does not run showroom animation")
            player.enable_articulated_visual = true
            player.call("_update_visual", 1.0 / 60.0)
            if not rig.art_loaded:
                _check(not rig.visible, "missing PNGs must hide experimental rig")
                _check(player.canonical_visual.visible, "sword must retain original canonical art")
            player.enable_articulated_visual = false
            player.call("_update_visual", 1.0 / 60.0)
            _check(not rig.visible, "disable switch restores old art")
            _check(player.canonical_visual.visible, "disable switch shows original canonical art")

    instance.queue_free()
    if failures == 0:
        print("[ArticulatedPlayerBridge] PASS: scene, fallback, opt-in and render selector")
    quit(1 if failures > 0 else 0)
