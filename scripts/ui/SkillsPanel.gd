extends Control

signal unlock_requested(skill_id: StringName)
signal closed

@onready var summary_label: Label = $Panel/Margin/VBox/Summary
@onready var list_box: VBoxContainer = $Panel/Margin/VBox/Skills
@onready var close_button: Button = $Panel/Margin/VBox/Close

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close)

func open_skills(progression: Progression) -> void:
	_refresh(progression)
	visible = true

func _refresh(progression: Progression) -> void:
	for child in list_box.get_children():
		child.queue_free()

	summary_label.text = "Nivel %d · Puntos de habilidad: %d" % [progression.level, progression.skill_points]

	for skill_id in SkillCatalog.ORDER:
		var data: Dictionary = SkillCatalog.DATA[skill_id]
		var unlocked := progression.has_skill(skill_id)
		var button := Button.new()
		button.custom_minimum_size.y = 62.0
		button.text = "%s — %s
%s%s" % [
			data["branch"],
			data["name"],
			data["description"],
			"  [APRENDIDA]" if unlocked else ""
		]
		button.disabled = unlocked or progression.skill_points <= 0
		button.focus_mode = Control.FOCUS_NONE
		var captured: StringName = skill_id
		button.pressed.connect(func() -> void:
			unlock_requested.emit(captured)
		)
		list_box.add_child(button)

func _on_close() -> void:
	visible = false
	closed.emit()
