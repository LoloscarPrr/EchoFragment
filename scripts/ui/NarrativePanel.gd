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
