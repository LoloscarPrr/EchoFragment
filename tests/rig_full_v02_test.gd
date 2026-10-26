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
    check(rig.missing_files.size() <= 9, "asset import state well-formed")
    check(rig.art_loaded or rig.get_node_or_null("FallbackProvisional") != null, "missing sprites must show fallback")
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
        print("[RigFull v0.2] PASS: preview, 9 source files, fallback and pose API")
    quit(1 if failures > 0 else 0)
