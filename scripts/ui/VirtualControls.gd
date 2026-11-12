extends CanvasLayer

# Direct multi-finger touchscreen controller. Each touch ID is independent.
# GUI buttons remain as visual targets but do not intercept Android fingers.
const ACTIONS := ["move_left", "move_right", "jump", "attack", "dodge", "interact", "inventory", "skills", "weapon_secondary", "weapon_guard"]
var _buttons: Array[Button] = []
var _touch_owner: Dictionary = {}
var _action_holders: Dictionary = {}
var _mouse_actions: Dictionary = {}
var _joystick: Control
var _joystick_finger := -1
var _joystick_axis := 0
var _secondary_button: Button
var _guard_button: Button
var _current_mode := -1

func _ready() -> void:
	_secondary_button = _create_combat_button("Secondary", -132.0, -265.0, -32.0, -165.0)
	_guard_button = _create_combat_button("Guard", -242.0, -265.0, -142.0, -165.0)
	_buttons = [$Root/Left, $Root/Right, $Root/Jump, $Root/Attack, $Root/Dodge, $Root/Interact, $Root/Inventory, $Root/Skills, _secondary_button, _guard_button]
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
		_joystick.anchor_left = 0.0
		_joystick.anchor_right = 0.0
		_joystick.anchor_top = 1.0
		_joystick.anchor_bottom = 1.0
		_joystick.offset_left = 22.0
		_joystick.offset_right = 242.0
		_joystick.offset_top = -226.0
		_joystick.offset_bottom = -16.0
		_joystick.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _create_combat_button(label: String, left: float, top: float, right: float, bottom: float) -> Button:
	var button := Button.new()
	button.name = label
	button.anchor_left = 1.0
	button.anchor_right = 1.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = left
	button.offset_top = top
	button.offset_right = right
	button.offset_bottom = bottom
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	$Root.add_child(button)
	return button


func set_weapon_mode(mode: int) -> void:
	if _current_mode == mode:
		return
	_release_all()
	for action in _mouse_actions.keys():
		_send_action(str(action), false)
	_mouse_actions.clear()
	_current_mode = mode
	_refresh_combat_labels()


func _process(_delta: float) -> void:
	if not visible:
		if not _touch_owner.is_empty() or _joystick_axis != 0:
			_release_all()
		return
	_refresh_combat_labels()


func _refresh_combat_labels() -> void:
	var player = get_parent().get_node_or_null("Player")
	if player == null or not player.has_method("get_weapon_action_status"):
		return
	var status: Dictionary = player.get_weapon_action_status()
	if status.is_empty():
		return
	$Root/Attack.text = str(status.get("primary", "GOLPE"))
	_secondary_button.visible = bool(status.get("secondary_visible", false))
	_guard_button.visible = bool(status.get("guard_visible", false))
	_secondary_button.text = str(status.get("secondary", ""))
	_guard_button.text = str(status.get("guard", ""))
	var remaining: float = float(status.get("guard_cd", 0.0))
	var shield_hits: int = int(status.get("shield_hits", 0))
	if remaining > 0.0 and shield_hits <= 0 and _guard_button.visible:
		_guard_button.text += "\n%.1fs" % remaining
	if shield_hits > 0 and _guard_button.visible:
		_guard_button.text += "\n%d golpes" % shield_hits
	var dagger_count := int(status.get("ready", 1))
	var secondary_cd: float = float(status.get("secondary_cd", 0.0))
	if _current_mode == 3 and dagger_count == 0 and secondary_cd > 0.0:
		_secondary_button.text += "\n%.1fs" % secondary_cd
	_secondary_button.disabled = (_current_mode == 3 and dagger_count == 0)
	_guard_button.disabled = remaining > 0.0 and shield_hits == 0


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
		_joystick.set("axis", float(axis))
		_joystick.queue_redraw()

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
		if button.is_visible_in_tree() and not button.disabled and button.get_global_rect().has_point(screen_position):
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
