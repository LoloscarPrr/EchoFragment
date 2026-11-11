extends Control

signal unlock_requested(skill_id: StringName)
signal closed

@onready var summary_label: Label = $Panel/Margin/VBox/Summary
@onready var list_box: VBoxContainer = $Panel/Margin/VBox/Skills
@onready var close_button: Button = $Panel/Margin/VBox/Close

var _branch_picker: OptionButton
var _selected_branch := "Arco"
var _progression: Progression
var _inventory: Inventory

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close)
	# Build a scrollable tree inside the existing panel: no scene surgery.
	var container := list_box.get_parent() as VBoxContainer
	var position := list_box.get_index()
	var scroll := ScrollContainer.new()
	scroll.name = "SkillScroll"
	scroll.custom_minimum_size.y = 290.0
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(scroll)
	container.move_child(scroll, position)
	list_box.reparent(scroll)
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_branch_picker = OptionButton.new()
	_branch_picker.custom_minimum_size.y = 52.0
	_branch_picker.focus_mode = Control.FOCUS_NONE
	for branch in SkillCatalog.BRANCHES:
		_branch_picker.add_item(branch)
	container.add_child(_branch_picker)
	container.move_child(_branch_picker, 2)
	_branch_picker.select(1) # Bow is the principal weapon.
	_branch_picker.item_selected.connect(_on_branch_selected)

func open_skills(progression: Progression, inventory: Inventory) -> void:
	_progression = progression
	_inventory = inventory
	_refresh()
	visible = true

func _refresh() -> void:
	for child in list_box.get_children():
		child.queue_free()
	if _progression == null or _inventory == null:
		return
	summary_label.text = "Nivel %d · Puntos: %d · Rama: %s" % [
		_progression.level, _progression.skill_points, _selected_branch
	]
	for skill_id in SkillCatalog.ORDER:
		var data: Dictionary = SkillCatalog.DATA[skill_id]
		if str(data["branch"]) != _selected_branch:
			continue
		var learned := _progression.has_skill(skill_id)
		var weapon_id: StringName = SkillCatalog.weapon_item(skill_id)
		var owned := weapon_id == &"" or _inventory.has_item(weapon_id)
		var missing: Array[StringName] = SkillCatalog.missing_requirements(skill_id, _progression.unlocked_skills)
		var status := "LISTA PARA APRENDER"
		if learned:
			status = "APRENDIDA"
		elif not owned:
			status = "ARMA TODAVÍA NO CONSEGUIDA"
		elif not missing.is_empty():
			var required_names: Array[String] = []
			for prerequisite in missing:
				required_names.append(str(SkillCatalog.DATA[prerequisite]["name"]))
			status = "REQUIERE: " + ", ".join(required_names)
		elif _progression.skill_points <= 0:
			status = "SIN PUNTOS DISPONIBLES"
		var button := Button.new()
		button.custom_minimum_size.y = 90.0
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.focus_mode = Control.FOCUS_NONE
		button.text = "RANGO %d · %s\n%s\n[%s]" % [
			int(data["tier"]), str(data["name"]), str(data["description"]), status
		]
		button.disabled = not owned or not _progression.can_unlock(skill_id)
		var captured: StringName = skill_id
		button.pressed.connect(func() -> void:
			unlock_requested.emit(captured)
		)
		list_box.add_child(button)

func _on_branch_selected(index: int) -> void:
	_selected_branch = _branch_picker.get_item_text(index)
	_refresh()

func _on_close() -> void:
	visible = false
	closed.emit()
