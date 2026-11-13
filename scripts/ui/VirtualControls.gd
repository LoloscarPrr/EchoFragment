extends CanvasLayer

# Direct multi-finger touchscreen controller. Each touch ID is independent.
# GUI buttons remain as visual targets but do not intercept Android fingers.
const ACTIONS := ["move_left", "move_right", "jump", "attack", "dodge", "interact", "inventory", "skills", "weapon_secondary", "weapon_guard"]
@export var touch_controls_preview := false

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
	_secondary_button = _new_combat_button("Secondary")
	_guard_button = _new_combat_button("Guard")
	_buttons = [$Root/Left, $Root/Right, $Root/Jump, $Root/Attack, $Root/Dodge, $Root/Interact, $Root/Inventory, $Root/Skills, _secondary_button, _guard_button]
	for index in range(_buttons.size()):
		var button: Button = _buttons[index]
		var action: String = ACTIONS[index]
		button.focus_mode = Control.FOCUS_NONE
		_skin_action_button(button)
		if (OS.has_feature("mobile") or touch_controls_preview):
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if index < 2:
				button.visible = false
		else:
			button.button_down.connect(_on_mouse_button.bind(action, true))
			button.button_up.connect(_on_mouse_button.bind(action, false))

	# The joystick occupies the old left/right area, with generous thumb travel.
	if (OS.has_feature("mobile") or touch_controls_preview):
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

func _new_combat_button(label: String) -> Button:
	var button := Button.new()
	button.name = label
	button.anchor_left = 1.0
	button.anchor_right = 1.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.focus_mode = Control.FOCUS_NONE
	button.text = label
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
	_refresh_weapon_labels()


func _process(_delta: float) -> void:
	if not visible:
		if not _touch_owner.is_empty() or _joystick_axis != 0:
			_release_all()
		return
	_refresh_weapon_labels()


func _refresh_weapon_labels() -> void:
	var fighter = get_parent().get_node_or_null("Player")
	if fighter == null or not fighter.has_method("get_weapon_action_status"):
		return
	var status: Dictionary = fighter.get_weapon_action_status()
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
		_guard_button.text += "\n%d impactos" % shield_hits
	var dagger_count := int(status.get("ready", 1))
	var secondary_cd: float = float(status.get("secondary_cd", 0.0))
	if _current_mode == 3 and dagger_count == 0 and secondary_cd > 0.0:
		_secondary_button.text += "\n%.1fs" % secondary_cd
	_secondary_button.disabled = (_current_mode == 3 and dagger_count == 0)
	_guard_button.disabled = remaining > 0.0 or shield_hits > 0


func _input(event: InputEvent) -> void:
	if not (OS.has_feature("mobile") or touch_controls_preview):
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
	if not visible or not (OS.has_feature("mobile") or touch_controls_preview):
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

# Circular controls follow the approved mockup while retaining actual actions.
func _skin_action_button(button: Button) -> void:
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.10, 0.07, 0.13, 0.68)
		style.border_color = Color("a88a9b")
		if state_name == "pressed":
			style.bg_color = Color(0.42, 0.08, 0.15, 0.85)
			style.border_color = Color("e6b2bb")
		style.set_border_width_all(2)
		style.set_corner_radius_all(64)
		button.add_theme_stylebox_override(state_name, style)
	button.add_theme_color_override("font_color", Color("e0cbd5"))
	button.add_theme_font_size_override("font_size", 16)
	# Small menu controls sit above the action cluster, not across the world.
	var layout := {
		# Keep the visual language of the approved mockup: circular right-hand actions.
		# Position touch targets without overlapping while showing three weapon actions.
		"Attack": Rect2(-142, -148, 112, 112),
		"Secondary": Rect2(-259, -273, 90, 90),
		"Guard": Rect2(-375, -248, 90, 90),
		"Jump": Rect2(-120, -288, 88, 88),
		"Dodge": Rect2(-265, -150, 88, 88),
		"Skills": Rect2(-185, -380, 80, 56),
		"Inventory": Rect2(-285, -385, 80, 56),
	}
	if layout.has(button.name):
		var box: Rect2 = layout[button.name]
		button.offset_left = box.position.x
		button.offset_top = box.position.y
		button.offset_right = box.end.x
		button.offset_bottom = box.end.y
