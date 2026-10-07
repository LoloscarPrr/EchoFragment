extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

@export var move_speed: float = 230.0
@export var acceleration: float = 1500.0
@export var deceleration: float = 1900.0
@export var jump_velocity: float = -470.0
@export var gravity: float = 1250.0
@export var max_health: int = 100
@export var attack_damage: int = 25
@export var attack_cooldown: float = 0.38

var health: int
var facing: float = 1.0
var can_control := true
var _last_attack_ms: int = -99999
var _visual_base_scale := Vector2.ONE

@onready var visual: Polygon2D = $Visual
@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	health = max_health
	_visual_base_scale = visual.scale
	health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

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

	if can_control and Input.is_action_just_pressed("attack"):
		_try_attack()

	move_and_slide()
	_update_visual(delta)

func _try_attack() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_attack_ms < int(attack_cooldown * 1000.0):
		return
	_last_attack_ms = now

	attack_area.position.x = 58.0 * facing
	for body in attack_area.get_overlapping_bodies():
		if body == self:
			continue
		if body.has_method("take_damage"):
			body.take_damage(attack_damage, global_position)

	var tween := create_tween()
	visual.rotation = 0.0
	tween.tween_property(visual, "rotation", 0.22 * facing, 0.07)
	tween.tween_property(visual, "rotation", -0.10 * facing, 0.08)
	tween.tween_property(visual, "rotation", 0.0, 0.09)

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

func take_damage(amount: int, source_position := Vector2.ZERO) -> void:
	if health <= 0:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)

	if source_position != Vector2.ZERO:
		var knock_dir := sign(global_position.x - source_position.x)
		if knock_dir == 0.0:
			knock_dir = -facing
		velocity.x = knock_dir * 260.0
		velocity.y = -120.0

	var tween := create_tween()
	tween.tween_property(visual, "modulate:a", 0.25, 0.05)
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
