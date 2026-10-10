extends CanvasLayer

# Each Android finger owns an action independently; releasing one finger
# never cancels an action held by another.
var _pressed_actions: Dictionary = {}
var _touch_actions: Dictionary = {}
var _touch_counts: Dictionary = {}
var _touch_buttons: Array[Button] = []
const TOUCH_ACTIONS := ["move_left", "move_right", "jump", "attack", "dodge", "interact", "inventory", "skills"]

func _ready() -> void:
	_bind_button($Root/Left, "move_left")
	_bind_button($Root/Right, "move_right")
	_bind_button($Root/Jump, "jump")
	_bind_button($Root/Attack, "attack")
	_bind_button($Root/Dodge, "dodge")
	_bind_tap($Root/Interact, "interact")
	_bind_tap($Root/Inventory, "inventory")
	_bind_tap($Root/Skills, "skills")
	if OS.has_feature("mobile"):
		for button in _touch_buttons:
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _exit_tree() -> void:
	for action in _pressed_actions.keys():
		Input.action_release(action)
	for action in _touch_counts.keys():
		Input.action_release(action)
	_touch_actions.clear()
	_touch_counts.clear()

func _input(event: InputEvent) -> void:
	if not OS.has_feature("mobile") or not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_set_finger_action(event.index, _action_at(event.position))
		else:
			_set_finger_action(event.index, "")
	elif event is InputEventScreenDrag:
		_set_finger_action(event.index, _action_at(event.position))

func _action_at(point: Vector2) -> String:
	for i in range(_touch_buttons.size()):
		var button := _touch_buttons[i]
		if button.visible and button.get_global_rect().has_point(point):
			return TOUCH_ACTIONS[i]
	return ""

func _set_finger_action(finger: int, action: String) -> void:
	var previous: String = str(_touch_actions.get(finger, ""))
	if previous == action:
		return
	if previous != "":
		var count: int = int(_touch_counts.get(previous, 0)) - 1
		if count <= 0:
			_touch_counts.erase(previous)
			Input.action_release(previous)
		else:
			_touch_counts[previous] = count
	_touch_actions.erase(finger)
	if action != "":
		_touch_actions[finger] = action
		var count: int = int(_touch_counts.get(action, 0))
		_touch_counts[action] = count + 1
		if count == 0:
			Input.action_press(action)

func _bind_button(button: Button, action: StringName) -> void:
	_touch_buttons.append(button)
	button.button_down.connect(func() -> void:
		_pressed_actions[action] = true
		Input.action_press(action)
	)
	button.button_up.connect(func() -> void:
		_pressed_actions.erase(action)
		if not _touch_counts.has(action):
			Input.action_release(action)
	)
	button.focus_mode = Control.FOCUS_NONE

func _bind_tap(button: Button, action: StringName) -> void:
	_touch_buttons.append(button)
	button.pressed.connect(func() -> void:
		Input.action_press(action)
		await get_tree().process_frame
		if not _touch_counts.has(action):
			Input.action_release(action)
	)
	button.focus_mode = Control.FOCUS_NONE
