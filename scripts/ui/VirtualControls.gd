extends CanvasLayer

var _pressed_actions: Dictionary = {}

func _ready() -> void:
	_bind_button($Root/Left, "move_left")
	_bind_button($Root/Right, "move_right")
	_bind_button($Root/Jump, "jump")
	_bind_button($Root/Attack, "attack")
	_bind_button($Root/Dodge, "dodge")
	_bind_tap($Root/Weapon, "weapon_next")

func _exit_tree() -> void:
	for action in _pressed_actions.keys():
		Input.action_release(action)

func _bind_button(button: Button, action: StringName) -> void:
	button.button_down.connect(func() -> void:
		_pressed_actions[action] = true
		Input.action_press(action)
	)
	button.button_up.connect(func() -> void:
		_pressed_actions.erase(action)
		Input.action_release(action)
	)
	button.focus_mode = Control.FOCUS_NONE

func _bind_tap(button: Button, action: StringName) -> void:
	button.pressed.connect(func() -> void:
		Input.action_press(action)
		await get_tree().process_frame
		Input.action_release(action)
	)
	button.focus_mode = Control.FOCUS_NONE
