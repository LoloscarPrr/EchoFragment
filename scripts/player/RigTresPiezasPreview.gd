extends Node2D

## Visor aislado: no modifica escenas jugables.
var rig: PortadorTresPiezasVisual
var state_label: Label

func _ready() -> void:
    var background := ColorRect.new()
    background.color = Color("#15171F")
    background.size = Vector2(1280, 720)
    add_child(background)
    var title := Label.new()
    title.text = "ECHOFRAGMENT  |  PORTADOR DEL ECO"
    title.position = Vector2(32, 28)
    title.add_theme_font_size_override("font_size", 26)
    title.add_theme_color_override("font_color", Color("#F0D3D8"))
    add_child(title)
    var subtitle := Label.new()
    subtitle.text = "CASCO / TORSO / PELVIS - RIG 2D EXPERIMENTAL"
    subtitle.position = Vector2(34, 70)
    subtitle.add_theme_font_size_override("font_size", 18)
    subtitle.add_theme_color_override("font_color", Color("#D57C90"))
    add_child(subtitle)
    rig = PortadorTresPiezasVisual.new()
    rig.name = "PortadorTresPiezas"
    rig.position = Vector2(640, 420)
    rig.scale = Vector2.ONE * 0.67
    rig.demo_cycle = true
    add_child(rig)
    state_label = Label.new()
    state_label.position = Vector2(34, 658)
    state_label.add_theme_font_size_override("font_size", 17)
    state_label.add_theme_color_override("font_color", Color("#DFC6C8"))
    add_child(state_label)
    if not rig.art_loaded:
        state_label.text = "FALTAN PNG: colocar los 3 archivos en assets/player/portador_rig2d/"

func _process(_delta: float) -> void:
    if is_instance_valid(rig) and rig.art_loaded and is_instance_valid(state_label):
        state_label.text = "POSE DEMOSTRATIVA: " + str(rig.state) + "  |  SIN COMBATE NI PIERNAS TODAVIA"
