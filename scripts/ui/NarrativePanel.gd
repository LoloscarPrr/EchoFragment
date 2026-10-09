extends Control

signal choice_selected(choice_id: StringName)
signal dismissed

@onready var title_label: Label = $Panel/Margin/VBox/Title
@onready var body_label: Label = $Panel/Margin/VBox/Body
@onready var choices_box: VBoxContainer = $Panel/Margin/VBox/Choices
@onready var result_label: Label = $Panel/Margin/VBox/Result
@onready var continue_button: Button = $Panel/Margin/VBox/Continue

func _ready() -> void:
	visible = false
	_setup_presentation()
	continue_button.pressed.connect(_on_continue_pressed)

func show_event(title: String, body: String, choices: Array) -> void:
	_clear_choices()
	title_label.text = title
	body_label.text = body
	result_label.text = ""
	continue_button.visible = false

	for choice in choices:
		var button := Button.new()
		button.text = choice.text
		button.custom_minimum_size.y = 48.0
		button.focus_mode = Control.FOCUS_NONE
		var choice_id: StringName = choice.id
		button.pressed.connect(func() -> void:
			choice_selected.emit(choice_id)
		)
		choices_box.add_child(button)

	visible = true

func show_result(text: String) -> void:
	for child in choices_box.get_children():
		child.queue_free()
	result_label.text = text
	continue_button.visible = true

func _clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()

func _on_continue_pressed() -> void:
	visible = false
	dismissed.emit()


func _setup_presentation() -> void:
	var panel: PanelContainer = $Panel
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	_apply_panel_size(panel)

	title_label.add_theme_font_size_override("font_size", 24)
	body_label.add_theme_font_size_override("font_size", 18)
	result_label.add_theme_font_size_override("font_size", 18)
	body_label.custom_minimum_size = Vector2(0, 84)
	result_label.custom_minimum_size = Vector2(0, 72)
	continue_button.custom_minimum_size = Vector2(0, 56)

func _apply_panel_size(panel: PanelContainer) -> void:
	var width: float = clampf(size.x - 96.0, 560.0, 780.0)
	var height: float = clampf(size.y - 88.0, 390.0, 490.0)
	panel.offset_left = -width * 0.5
	panel.offset_right = width * 0.5
	panel.offset_top = -height * 0.5
	panel.offset_bottom = height * 0.5

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_apply_panel_size($Panel)
