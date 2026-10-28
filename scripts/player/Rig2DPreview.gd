extends Node2D

## Visor independiente: ejecutarlo con Godot 4.3 como escena de prueba.
## No se carga desde Main.tscn ni reemplaza el personaje jugable.
var _rig: PortadorRig2DPrototype

func _ready() -> void:
    var backdrop := ColorRect.new()
    backdrop.name = "Backdrop"
    backdrop.color = Color("#101218")
    backdrop.size = Vector2(1280, 720)
    add_child(backdrop)

    var horizon := Line2D.new()
    horizon.name = "GroundGuide"
    horizon.points = PackedVector2Array([Vector2(100, 535), Vector2(1180, 535)])
    horizon.width = 2.0
    horizon.default_color = Color("#8C4654")
    add_child(horizon)

    var title := Label.new()
    title.name = "Title"
    title.text = "ECHOFRAGMENT  |  PORTADOR DEL ECO"
    title.position = Vector2(42, 38)
    title.add_theme_font_size_override("font_size", 30)
    title.add_theme_color_override("font_color", Color("#F0D6D6"))
    add_child(title)

    var note := Label.new()
    note.name = "Info"
    note.text = "RIG 2D - PROTOTIPO TECNICO / idle - run - attack - dodge"
    note.position = Vector2(44, 82)
    note.add_theme_font_size_override("font_size", 18)
    note.add_theme_color_override("font_color", Color("#C2A4A9"))
    add_child(note)

    var footnote := Label.new()
    footnote.name = "Footnote"
    footnote.text = "PIEZAS PROVISIONALES. El arte final con casco aprobado se agrega al validar huesos y articulaciones."
    footnote.position = Vector2(44, 663)
    footnote.add_theme_font_size_override("font_size", 16)
    footnote.add_theme_color_override("font_color", Color("#B4A5A9"))
    add_child(footnote)

    _rig = PortadorRig2DPrototype.new()
    _rig.name = "PortadorRig"
    _rig.position = Vector2(640, 478)
    _rig.scale = Vector2.ONE * 2.35
    _rig.demo_cycle = true
    add_child(_rig)
    # The optional art skin keeps provisional polygons if the eight cutout PNGs are absent.
    var skin := PortadorRig2DTextureSkin.new()
    skin.name = "HelmetArtSkin"
    _rig.add_child(skin)
