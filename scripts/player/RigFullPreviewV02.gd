extends Node2D

## EchoFragment v0.2 experimental showroom for the 17-bone prototype.
## Does not load the playable main scene, touch collisions or change combat.
var rig: PortadorFullRigV02
var status: Label

func _ready() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#181920")
    bg.size = Vector2(1280, 720)
    add_child(bg)
    var title := Label.new()
    title.text = "ECHOFRAGMENT   /   PORTADOR DEL ECO"
    title.position = Vector2(38, 30)
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color("#E9DDE0"))
    add_child(title)
    var info := Label.new()
    info.text = "Rig 2D v0.2: casco, armadura, codos, rodillas, capa, espada"
    info.position = Vector2(40, 78)
    info.add_theme_font_size_override("font_size", 18)
    info.add_theme_color_override("font_color", Color("#D98691"))
    add_child(info)
    var floor_line := Line2D.new()
    floor_line.name = "Ground"
    floor_line.points = PackedVector2Array([Vector2(120, 640), Vector2(1150, 640)])
    floor_line.default_color = Color("#81424C")
    floor_line.width = 2.0
    add_child(floor_line)

    rig = PortadorFullRigV02.new()
    rig.name = "PortadorRigV02"
    rig.position = Vector2(660, 395)
    rig.scale = Vector2.ONE * 0.83
    rig.demo_cycle = true
    add_child(rig)

    status = Label.new()
    status.position = Vector2(40, 658)
    status.add_theme_font_size_override("font_size", 17)
    status.add_theme_color_override("font_color", Color("#DDC9CD"))
    add_child(status)
    _display_status()

func _process(_delta: float) -> void:
    if is_instance_valid(rig) and rig.art_loaded and is_instance_valid(status):
        status.text = "Texturas cargadas: 9 PNG | Pose: " + str(rig.state) + " | Codos, rodillas y manos articulados"

func _display_status() -> void:
    if rig.art_loaded:
        status.text = "9 PNG cargados: reposo, carrera, tajo, esquiva y salto"
    else:
        status.text = "FALTAN " + str(rig.missing_files.size()) + " PNG ORIGINALES. Mostrando maniqui temporal."
