extends CanvasLayer

# Direct multi-finger touchscreen controller. Each touch ID is independent.
# GUI buttons remain as visual targets but do not intercept Android fingers.
const ACTIONS := ["move_left", "move_right", "jump", "attack", "dodge", "interact", "inventory", "skills"]
var _buttons: Array[Button] = []
var _touch_owner: Dictionary = {}
var _action_holders: Dictionary = {}
var _mouse_actions: Dictionary = {}
var _joystick: Control
var _joystick_finger := -1
var _joystick_axis := 0

func _ready() -> void:
	_buttons = [$Root/Left, $Root/Right, $Root/Jump, $Root/Attack, $Root/Dodge, $Root/Interact, $Root/Inventory, $Root/Skills]
	for index in range(_buttons.size()):
		var button: Button = _buttons[index]
		var action: String = ACTIONS[index]
		button.focus_mode = Control.FOCUS_NONE
		if OS.has_feature("mobile"):
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if index < 2:
				button.visible = false
		else:
			button.button_down.connect(_on_mouse_button.bind(action, true))
			button.button_up.connect(_on_mouse_button.bind(action, false))

	# The joystick occupies the old left/right area, with generous thumb travel.
	if OS.has_feature("mobile"):
		_joystick = Control.new()
		_joystick.set_script(preload("res://scripts/ui/JoystickVisual.gd"))
		$Root.add_child(_joystick)
		_joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		_joystick.position = Vector2(22, -226)
		_joystick.size = Vector2(220, 210)
		_joystick.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if not OS.has_feature("mobile"):
		return
	if not visible:
		_release_all()
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _joystick != null and _joystick.get_global_rect().has_point(touch.position):
			_joystick_finger = touch.index
			_update_joystick(touch.position)
		elif not touch.pressed and touch.index == _joystick_finger:
			_joystick_finger = -1
			_set_joystick_axis(0)
		else:
			_set_touch(touch.index, _find_action(touch.position) if touch.pressed else "")
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _joystick_finger:
			_update_joystick(drag.position)
			return
		var held: String = str(_touch_owner.get(drag.index, ""))
		if held == "":
			return
		if held == "move_left" or held == "move_right":
			var target: String = _find_action(drag.position)
			if target == "move_left" or target == "move_right":
				_set_touch(drag.index, target)
		# Keep each action captured until its finger is lifted.

func _update_joystick(screen_position: Vector2) -> void:
	if _joystick == null:
		return
	var center := _joystick.get_global_rect().get_center()
	var dx := screen_position.x - center.x
	var dead_zone := 26.0
	_set_joystick_axis(-1 if dx < -dead_zone else (1 if dx > dead_zone else 0))

func _set_joystick_axis(axis: int) -> void:
	if _joystick_axis == axis:
		return
	if _joystick_axis < 0:
		_change_count("move_left", -1)
	elif _joystick_axis > 0:
		_change_count("move_right", -1)
	_joystick_axis = axis
	if axis < 0:
		_change_count("move_left", 1)
	elif axis > 0:
		_change_count("move_right", 1)
	if _joystick != null:
		_joystick.set_axis(float(axis))

# Player reads direction directly, independently of synthetic input actions.
func get_touch_axis() -> float:
	if not visible or not OS.has_feature("mobile"):
		return 0.0
	var left: bool = _action_holders.has("move_left")
	var right: bool = _action_holders.has("move_right")
	return float(int(right) - int(left))

func _find_action(screen_position: Vector2) -> String:
	for index in range(_buttons.size()):
		var button: Button = _buttons[index]
		if button.is_visible_in_tree() and button.get_global_rect().has_point(screen_position):
			return ACTIONS[index]
	return ""

func _set_touch(finger: int, action: String) -> void:
	var previous: String = str(_touch_owner.get(finger, ""))
	if previous == action:
		return
	if previous != "":
		_touch_owner.erase(finger)
		_change_count(previous, -1)
	if action != "":
		_touch_owner[finger] = action
		_change_count(action, 1)

func _change_count(action: String, delta: int) -> void:
	var old_count: int = int(_action_holders.get(action, 0))
	var new_count: int = maxi(0, old_count + delta)
	if new_count == 0:
		_action_holders.erase(action)
		if not _mouse_actions.has(action):
			_send_action(action, false)
	else:
		_action_holders[action] = new_count
		if old_count == 0:
			_send_action(action, true)

func _send_action(action: String, pressed: bool) -> void:
	var input_event := InputEventAction.new()
	input_event.action = action
	input_event.pressed = pressed
	input_event.strength = 1.0 if pressed else 0.0
	Input.parse_input_event(input_event)

func _on_mouse_button(action: String, pressed: bool) -> void:
	if pressed:
		_mouse_actions[action] = true
		_send_action(action, true)
	else:
		_mouse_actions.erase(action)
		if not _action_holders.has(action):
			_send_action(action, false)

func _release_all() -> void:
	_joystick_finger = -1
	_set_joystick_axis(0)
	for action in _action_holders.keys():
		if not _mouse_actions.has(action):
			_send_action(str(action), false)
	_touch_owner.clear()
	_action_holders.clear()

func _exit_tree() -> void:
	_release_all()
	for action in _mouse_actions.keys():
		_send_action(str(action), false)
	_mouse_actions.clear()
