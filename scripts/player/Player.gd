extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal stamina_changed(current: float, maximum: float)
signal combo_changed(step: int)
signal died

@export var move_speed := 230.0
@export var acceleration := 1500.0
@export var deceleration := 1900.0
@export var jump_velocity := -470.0
@export var gravity := 1250.0
@export var max_health := 100
@export var max_stamina := 100.0
@export var stamina_regen_per_second := 28.0
@export var dodge_cost := 30.0
@export var dodge_speed := 520.0
@export var dodge_duration := 0.18
@export var dodge_invulnerability := 0.28
@export var combo_window := 0.55

var health: int
var stamina: float
var facing := 1.0
var can_control := true

var _combo_step := 0
var _last_attack_time := -99.0
var _attack_locked_until := 0.0
var _dodge_until := 0.0
var _invulnerable_until := 0.0
var _visual_base_scale := Vector2.ONE

@onready var visual: Polygon2D = $Visual
@onready var hitbox: CombatHitbox = $AttackHitbox

func _ready() -> void:
	health = max_health
	stamina = max_stamina
	_visual_base_scale = visual.scale
	health_changed.emit(health, max_health)
	stamina_changed.emit(stamina, max_stamina)

func _physics_process(delta: float) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	_regen_stamina(delta, now)

	if not is_on_floor():
		velocity.y += gravity * delta

	if now < _dodge_until:
		move_and_slide()
		_update_visual(delta)
		return

	var direction := 0.0
	if can_control:
		direction = Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		facing = sign(direction)
		velocity.x = move_toward(velocity.x, direction * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

	if can_control and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if can_control and Input.is_action_just_pressed("dodge"):
		_try_dodge(direction, now)

	if can_control and Input.is_action_just_pressed("attack"):
		_try_attack(now)

	move_and_slide()
	_update_visual(delta)

func _regen_stamina(delta: float, now: float) -> void:
	if now < _dodge_until:
		return
	var previous := stamina
	stamina = minf(max_stamina, stamina + stamina_regen_per_second * delta)
	if not is_equal_approx(previous, stamina):
		stamina_changed.emit(stamina, max_stamina)

func _try_dodge(direction: float, now: float) -> void:
	if stamina < dodge_cost or now < _attack_locked_until:
		return
	stamina -= dodge_cost
	stamina_changed.emit(stamina, max_stamina)

	var dodge_direction := direction
	if dodge_direction == 0.0:
		dodge_direction = facing
	else:
		facing = sign(dodge_direction)

	velocity.x = dodge_direction * dodge_speed
	velocity.y = 0.0
	_dodge_until = now + dodge_duration
	_invulnerable_until = now + dodge_invulnerability

	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.28, 0.72), 0.07)
	tween.tween_property(visual, "scale", _visual_base_scale, 0.11)

func _try_attack(now: float) -> void:
	if now < _attack_locked_until:
		return

	if now - _last_attack_time <= combo_window:
		_combo_step = (_combo_step % 3) + 1
	else:
		_combo_step = 1

	_last_attack_time = now
	combo_changed.emit(_combo_step)

	var damage_values := [18, 22, 34]
	var lock_values := [0.24, 0.28, 0.40]
	var reach_values := [58.0, 64.0, 72.0]

	hitbox.damage = damage_values[_combo_step - 1]
	hitbox.knockback = 180.0 + (_combo_step * 35.0)
	hitbox.position.x = reach_values[_combo_step - 1] * facing
	_attack_locked_until = now + lock_values[_combo_step - 1]
	hitbox.strike(global_position)

	var angles := [0.18, -0.26, 0.42]
	var tween := create_tween()
	visual.rotation = 0.0
	tween.tween_property(visual, "rotation", angles[_combo_step - 1] * facing, 0.07)
	tween.tween_property(visual, "rotation", 0.0, lock_values[_combo_step - 1] - 0.07)

func _update_visual(delta: float) -> void:
	if absf(velocity.x) > 15.0 and is_on_floor():
		var bob := sin(Time.get_ticks_msec() * 0.018) * 2.0
		visual.position.y = move_toward(visual.position.y, bob, 40.0 * delta)
	else:
		visual.position.y = move_toward(visual.position.y, 0.0, 40.0 * delta)

	var target_scale := _visual_base_scale
	if not is_on_floor():
		target_scale = Vector2(0.94, 1.06)
	elif absf(velocity.x) > 20.0:
		target_scale = Vector2(1.04, 0.96)
	visual.scale = visual.scale.lerp(target_scale, minf(1.0, 9.0 * delta))

func can_receive_damage() -> bool:
	return health > 0 and Time.get_ticks_msec() / 1000.0 >= _invulnerable_until

func take_damage(amount: int, source_position := Vector2.ZERO, knockback := 220.0) -> void:
	if not can_receive_damage():
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)

	if source_position != Vector2.ZERO:
		var knock_dir := sign(global_position.x - source_position.x)
		if knock_dir == 0.0:
			knock_dir = -facing
		velocity.x = knock_dir * knockback
		velocity.y = -120.0

	var tween := create_tween()
	tween.tween_property(visual, "modulate:a", 0.2, 0.05)
	tween.tween_property(visual, "modulate:a", 1.0, 0.10)

	if health == 0:
		die()

func die() -> void:
	can_control = false
	velocity = Vector2.ZERO
	died.emit()
	var tween := create_tween()
	tween.tween_property(visual, "rotation", 1.45 * facing, 0.35)
	tween.parallel().tween_property(visual, "modulate:a", 0.35, 0.35)
