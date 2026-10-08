extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

enum State { IDLE, CHASE, WINDUP, RECOVER, BACKSTEP, DEAD }

@export var max_health := 78
@export var move_speed := 100.0
@export var gravity := 1250.0
@export var detection_range := 460.0
@export var attack_range := 84.0
@export var preferred_range := 118.0
@export var attack_damage := 14

var health: int
var state := State.IDLE
var target: CharacterBody2D
var _state_until := 0.0
var _attack_counter := 0

@onready var visual: Polygon2D = $Visual
@onready var hitbox: CombatHitbox = $AttackHitbox

func _ready() -> void:
	health = max_health
	target = get_tree().get_first_node_in_group("player") as CharacterBody2D

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as CharacterBody2D
		move_and_slide()
		return

	var now := Time.get_ticks_msec() / 1000.0
	var distance_x := target.global_position.x - global_position.x
	var distance := absf(distance_x)

	match state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
			if distance <= detection_range:
				state = State.CHASE
		State.CHASE:
			if distance > detection_range * 1.2:
				state = State.IDLE
			elif distance <= attack_range:
				_begin_windup(now, distance_x)
			else:
				velocity.x = sign(distance_x) * move_speed
		State.WINDUP:
			velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)
			if now >= _state_until:
				_perform_attack(now, distance_x)
		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
			if now >= _state_until:
				_attack_counter += 1
				if _attack_counter % 3 == 0 and distance < preferred_range:
					state = State.BACKSTEP
					_state_until = now + 0.28
				else:
					state = State.CHASE
		State.BACKSTEP:
			velocity.x = -sign(distance_x) * move_speed * 1.7
			if now >= _state_until:
				state = State.CHASE

	move_and_slide()

func _begin_windup(now: float, distance_x: float) -> void:
	state = State.WINDUP
	_state_until = now + 0.42
	hitbox.position.x = 58.0 * sign(distance_x)
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(0.88, 1.12), 0.18)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.20)

func _perform_attack(now: float, distance_x: float) -> void:
	hitbox.position.x = 58.0 * sign(distance_x)
	hitbox.damage = attack_damage
	hitbox.knockback = 250.0
	hitbox.strike(global_position)
	state = State.RECOVER
	_state_until = now + 0.62

	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.20, 0.84), 0.08)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.16)

func can_receive_damage() -> bool:
	return state != State.DEAD

func take_damage(amount: int, source_position := Vector2.ZERO, knockback := 220.0) -> void:
	if state == State.DEAD:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)

	var knock_dir := 1.0
	if source_position != Vector2.ZERO:
		knock_dir = sign(global_position.x - source_position.x)
		if knock_dir == 0.0:
			knock_dir = 1.0
	velocity.x = knock_dir * knockback

	var tween := create_tween()
	tween.tween_property(visual, "modulate:a", 0.2, 0.05)
	tween.tween_property(visual, "modulate:a", 1.0, 0.10)

	if health == 0:
		_die()
	else:
		state = State.RECOVER
		_state_until = Time.get_ticks_msec() / 1000.0 + 0.22

func _die() -> void:
	state = State.DEAD
	collision_layer = 0
	collision_mask = 0
	died.emit()
	var tween := create_tween()
	tween.tween_property(visual, "rotation", 1.55, 0.25)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
