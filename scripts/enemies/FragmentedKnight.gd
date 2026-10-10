class_name FragmentedKnight
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal phase_changed(phase: int)
signal broken
signal died

enum State { DORMANT, CHASE, WINDUP, LUNGE, RECOVER, PHASE_SHIFT, BROKEN, DEAD }

@export var max_health := 320
@export var gravity := 1250.0
@export var detection_range := 560.0
@export var break_threshold := 72

var health: int
var phase := 1
var state := State.DORMANT
var target: CharacterBody2D
var _state_until := 0.0
var _attack_index := 0
var _broken_emitted := false

@onready var visual: Polygon2D = $Visual
@onready var hitbox: CombatHitbox = $AttackHitbox
var telegraph: Node2D

func _ready() -> void:
	health = max_health
	telegraph = Node2D.new()
	telegraph.set_script(preload("res://scripts/enemies/KnightTelegraph.gd"))
	add_child(telegraph)
	target = get_tree().get_first_node_in_group("player") as CharacterBody2D
	health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
	if state == State.DEAD or state == State.BROKEN:
		return
	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as CharacterBody2D
		move_and_slide()
		return

	var now: float = Time.get_ticks_msec() / 1000.0
	var dx: float = target.global_position.x - global_position.x
	var distance: float = absf(dx)

	match state:
		State.DORMANT:
			velocity.x = 0.0
			if distance <= detection_range:
				state = State.CHASE
		State.CHASE:
			var speed: float = 86.0 if phase == 1 else 132.0
			if distance <= (118.0 if phase == 1 else 148.0):
				_begin_windup(now, dx)
			else:
				velocity.x = sign(dx) * speed
		State.WINDUP:
			velocity.x = move_toward(velocity.x, 0.0, 1500.0 * delta)
			if now >= _state_until:
				_perform_attack(now, dx)
		State.LUNGE:
			if now >= _state_until:
				state = State.RECOVER
				_state_until = now + (0.48 if phase == 1 else 0.30)
		State.RECOVER:
			velocity.x = move_toward(velocity.x, 0.0, 1000.0 * delta)
			if now >= _state_until:
				state = State.CHASE
		State.PHASE_SHIFT:
			velocity.x = 0.0
			if now >= _state_until:
				state = State.CHASE

	if is_instance_valid(telegraph):
		telegraph.active = state == State.WINDUP
		telegraph.shifting = state == State.PHASE_SHIFT
		telegraph.phase = phase
		if state == State.WINDUP:
			var duration := 0.46 if phase == 1 else 0.26
			telegraph.windup_ratio = clampf(1.0 - (_state_until - now) / duration, 0.0, 1.0)
	move_and_slide()

func _begin_windup(now: float, dx: float) -> void:
	state = State.WINDUP
	_attack_index += 1
	var windup: float = 0.46 if phase == 1 else 0.26
	_state_until = now + windup
	hitbox.position.x = 76.0 * sign(dx)
	if is_instance_valid(telegraph):
		telegraph.attack_direction = signf(dx) if dx != 0.0 else 1.0
		telegraph.windup_ratio = 0.0

	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(0.88, 1.14), windup * 0.7)
	tween.tween_property(visual, "scale", Vector2.ONE, windup * 0.3)

func _perform_attack(now: float, dx: float) -> void:
	var direction: float = signf(dx)
	if direction == 0.0:
		direction = 1.0

	if phase == 1:
		hitbox.damage = 22
		hitbox.knockback = 310.0
		hitbox.position.x = 78.0 * direction
		hitbox.strike(global_position)
		state = State.RECOVER
		_state_until = now + 0.52
	else:
		if _attack_index % 3 == 0:
			hitbox.damage = 34
			hitbox.knockback = 430.0
			hitbox.position.x = 94.0 * direction
			velocity.x = direction * 420.0
			hitbox.strike(global_position)
			state = State.LUNGE
			_state_until = now + 0.22
		else:
			hitbox.damage = 25
			hitbox.knockback = 350.0
			hitbox.position.x = 82.0 * direction
			hitbox.strike(global_position)
			state = State.RECOVER
			_state_until = now + 0.30

	var tween := create_tween()
	tween.tween_property(visual, "rotation", 0.18 * direction, 0.07)
	tween.tween_property(visual, "rotation", 0.0, 0.14)

func can_receive_damage() -> bool:
	return state != State.DEAD and state != State.BROKEN and state != State.PHASE_SHIFT

func take_damage(amount: int, source_position := Vector2.ZERO, knockback := 160.0) -> void:
	if not can_receive_damage():
		return

	health = maxi(break_threshold, health - amount)
	health_changed.emit(health, max_health)

	if phase == 1 and health <= int(max_health * 0.5):
		phase = 2
		state = State.PHASE_SHIFT
		_state_until = Time.get_ticks_msec() / 1000.0 + 0.85
		phase_changed.emit(phase)
		var shift := create_tween()
		shift.tween_property(visual, "scale", Vector2(1.20, 1.20), 0.20)
		shift.tween_property(visual, "scale", Vector2.ONE, 0.45)

	if health <= break_threshold and not _broken_emitted:
		_broken_emitted = true
		state = State.BROKEN
		velocity = Vector2.ZERO
		broken.emit()
		var tween := create_tween()
		tween.tween_property(visual, "rotation", -0.28, 0.30)
		tween.parallel().tween_property(visual, "modulate", Color(0.68, 0.68, 0.76, 1.0), 0.30)
		return

	if source_position != Vector2.ZERO:
		var dir: float = signf(global_position.x - source_position.x)
		velocity.x = dir * minf(knockback, 180.0)

func resolve_as_killed() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	collision_layer = 0
	collision_mask = 0
	died.emit()
	var tween := create_tween()
	tween.tween_property(visual, "rotation", 1.45, 0.45)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, 0.65)
	tween.tween_callback(queue_free)

func resolve_as_released() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	collision_layer = 0
	collision_mask = 0
	var tween := create_tween()
	tween.tween_property(visual, "modulate", Color(0.62, 0.78, 0.92, 0.0), 1.0)
	tween.tween_callback(queue_free)
