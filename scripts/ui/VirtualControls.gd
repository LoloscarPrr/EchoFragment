extends CanvasLayer

# Direct multi-finger touchscreen controller. Each touch ID is independent.
# GUI buttons remain as visual targets but do not intercept Android fingers.
const ACTIONS := ["move_left", "move_right", "jump", "attack", "dodge", "interact", "inventory", "skills"]
var _buttons: Array[Button] = []
var _touch_owner: Dictionary = {}
var _action_holders: Dictionary = {}
var _mouse_actions: Dictionary = {}

func _ready() -> void:
	_buttons = [$Root/Left, $Root/Right, $Root/Jump, $Root/Attack, $Root/Dodge, $Root/Interact, $Root/Inventory, $Root/Skills]
	for index in range(_buttons.size()):
		var button: Button = _buttons[index]
		var action: String = ACTIONS[index]
		button.focus_mode = Control.FOCUS_NONE
		if OS.has_feature("mobile"):
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			button.button_down.connect(_on_mouse_button.bind(action, true))
			button.button_up.connect(_on_mouse_button.bind(action, false))

func _input(event: InputEvent) -> void:
	if not OS.has_feature("mobile"):
		return
	if not visible:
		_release_all()
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		_set_touch(touch.index, _find_action(touch.position) if touch.pressed else "")
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		var held: String = str(_touch_owner.get(drag.index, ""))
		if held == "":
			return
		if held == "move_left" or held == "move_right":
			var target: String = _find_action(drag.position)
			if target == "move_left" or target == "move_right":
				_set_touch(drag.index, target)
		# Keep each action captured until its finger is lifted.

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
