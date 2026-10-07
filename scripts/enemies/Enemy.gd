extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 60
@export var move_speed: float = 95.0
@export var gravity: float = 1250.0
@export var detection_range: float = 430.0
@export var attack_range: float = 72.0
@export var attack_damage: int = 12
@export var attack_cooldown: float = 1.15

var health: int
var _last_attack_ms: int = -99999
var _dead := false
var target: CharacterBody2D

@onready var visual: Polygon2D = $Visual

func _ready() -> void:
	health = max_health
	target = get_tree().get_first_node_in_group("player") as CharacterBody2D

func _physics_process(delta: float) -> void:
	if _dead:
		return
	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as CharacterBody2D
		move_and_slide()
		return

	var distance_x := target.global_position.x - global_position.x
	var absolute_distance := absf(distance_x)

	if absolute_distance <= detection_range and absolute_distance > attack_range:
		velocity.x = sign(distance_x) * move_speed
	elif absolute_distance <= attack_range:
		velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
		_try_attack()
	else:
		velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)

	move_and_slide()

func _try_attack() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_attack_ms < int(attack_cooldown * 1000.0):
		return
	_last_attack_ms = now
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(attack_damage, global_position)

	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.16, 0.88), 0.08)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.14)

func take_damage(amount: int, source_position := Vector2.ZERO) -> void:
	if _dead:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)

	var knock_dir := 1.0
	if source_position != Vector2.ZERO:
		knock_dir = sign(global_position.x - source_position.x)
		if knock_dir == 0.0:
			knock_dir = 1.0
	velocity.x = knock_dir * 210.0

	var tween := create_tween()
	tween.tween_property(visual, "modulate:a", 0.3, 0.05)
	tween.tween_property(visual, "modulate:a", 1.0, 0.10)

	if health == 0:
		_die()

func _die() -> void:
	_dead = true
	collision_layer = 0
	collision_mask = 0
	died.emit()
	var tween := create_tween()
	tween.tween_property(visual, "rotation", 1.55, 0.25)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
