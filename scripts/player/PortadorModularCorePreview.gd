extends Node2D

## Static art-review stage. Animation is deliberately disabled.
func _ready() -> void:
    var backdrop := ColorRect.new()
    backdrop.name = "Backdrop"
    backdrop.color = Color("#131720")
    backdrop.size = Vector2(1280, 720)
    add_child(backdrop)
    var title := Label.new()
    title.text = "ECHOFRAGMENT  /  PORTADOR DEL ECO - MODULAR V1"
    title.position = Vector2(30, 22)
    title.add_theme_font_size_override("font_size", 26)
    title.add_theme_color_override("font_color", Color("#EDE3E2"))
    add_child(title)
    var note := Label.new()
    note.text = "SPRINT 01  |  Casco, cuello, torso, pelvis independientes - SIN animacion"
    note.position = Vector2(34, 70)
    note.add_theme_font_size_override("font_size", 18)
    note.add_theme_color_override("font_color", Color("#D1A1A9"))
    add_child(note)

    var character := PortadorModularCoreV1.new()
    character.name = "PortadorCore"
    character.position = Vector2(650, 420)
    character.scale = Vector2.ONE * 0.40
    add_child(character)

    var footer := Label.new()
    footer.text = "Bloqueo de geometria / arte provisional: no aprobado para animacion ni APK."
    footer.position = Vector2(34, 658)
    footer.add_theme_font_size_override("font_size", 18)
    footer.add_theme_color_override("font_color", Color("#D1A1A9"))
    add_child(footer)
    if not character.art_loaded:
        footer.text = "ERROR: faltan recursos de arte v1 (los 4 PNG deben existir)."
