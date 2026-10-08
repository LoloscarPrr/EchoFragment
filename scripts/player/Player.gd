extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal stamina_changed(current: float, maximum: float)
signal combo_changed(step: int)
signal weapon_changed(display_name: String)
signal died

enum WeaponMode { SWORD, BOW, STAFF, DAGGERS }

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
var weapon_mode := WeaponMode.SWORD

var _combo_step := 0
var _last_attack_time := -99.0
var _attack_locked_until := 0.0
var _dodge_until := 0.0
var _invulnerable_until := 0.0
var _visual_base_scale := Vector2.ONE

@onready var visual: Polygon2D = $Visual
@onready var hitbox: CombatHitbox = $AttackHitbox
@onready var projectile_origin: Marker2D = $ProjectileOrigin

var arrow_scene := preload("res://scenes/combat/Arrow.tscn")
var arcane_scene := preload("res://scenes/combat/ArcaneBolt.tscn")

func _ready() -> void:
	health = max_health
	stamina = max_stamina
	_visual_base_scale = visual.scale
	health_changed.emit(health, max_health)
	stamina_changed.emit(stamina, max_stamina)
	weapon_changed.emit(_weapon_name())

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

	if can_control and Input.is_action_just_pressed("weapon_next"):
		cycle_weapon()

	if can_control and Input.is_action_just_pressed("attack"):
		_try_attack(now)

	move_and_slide()
	_update_visual(delta)

func cycle_weapon() -> void:
	if Time.get_ticks_msec() / 1000.0 < _attack_locked_until:
		return
	weapon_mode = (weapon_mode + 1) % 4
	_combo_step = 0
	combo_changed.emit(0)
	weapon_changed.emit(_weapon_name())
	_apply_weapon_visual()

func _weapon_name() -> String:
	match weapon_mode:
		WeaponMode.SWORD:
			return "Espada"
		WeaponMode.BOW:
			return "Arco"
		WeaponMode.STAFF:
			return "Báculo"
		WeaponMode.DAGGERS:
			return "Dagas"
	return "Desconocida"

func _apply_weapon_visual() -> void:
	var weapon_visual := $Visual/Weapon as Polygon2D
	match weapon_mode:
		WeaponMode.SWORD:
			weapon_visual.polygon = PackedVector2Array(18,-7,74,-3,74,3,18,7)
			weapon_visual.color = Color(0.72,0.77,0.82,1)
		WeaponMode.BOW:
			weapon_visual.polygon = PackedVector2Array(20,-26,28,-20,32,0,28,20,20,26,24,0)
			weapon_visual.color = Color(0.55,0.34,0.18,1)
		WeaponMode.STAFF:
			weapon_visual.polygon = PackedVector2Array(21,-34,27,-34,27,34,21,34)
			weapon_visual.color = Color(0.45,0.58,0.96,1)
		WeaponMode.DAGGERS:
			weapon_visual.polygon = PackedVector2Array(18,-16,48,-12,48,-6,18,-4,18,4,48,6,48,12,18,16)
			weapon_visual.color = Color(0.82,0.82,0.86,1)

func _regen_stamina(delta: float, now: float) -> void:
	if now < _dodge_until:
		return
	var previous := stamina
	stamina = minf(max_stamina, stamina + stamina_regen_per_second * delta)
	if not is_equal_approx(previous, stamina):
		stamina_changed.emit(stamina, max_stamina)

func _spend_stamina(amount: float) -> bool:
	if stamina < amount:
		return false
	stamina -= amount
	stamina_changed.emit(stamina, max_stamina)
	return true

func _try_dodge(direction: float, now: float) -> void:
	if now < _attack_locked_until or not _spend_stamina(dodge_cost):
		return

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
	match weapon_mode:
		WeaponMode.SWORD:
			_attack_sword(now)
		WeaponMode.BOW:
			_attack_bow(now)
		WeaponMode.STAFF:
			_attack_staff(now)
		WeaponMode.DAGGERS:
			_attack_daggers(now)

func _attack_sword(now: float) -> void:
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

func _attack_daggers(now: float) -> void:
	if not _spend_stamina(8.0):
		return
	if now - _last_attack_time <= 0.38:
		_combo_step = (_combo_step % 4) + 1
	else:
		_combo_step = 1
	_last_attack_time = now
	combo_changed.emit(_combo_step)

	hitbox.damage = 9 + (_combo_step * 2)
	hitbox.knockback = 90.0
	hitbox.position.x = 46.0 * facing
	_attack_locked_until = now + 0.14
	hitbox.strike(global_position)
	velocity.x += facing * 35.0

	var tween := create_tween()
	tween.tween_property(visual, "rotation", 0.14 * facing * (1 if _combo_step % 2 == 1 else -1), 0.05)
	tween.tween_property(visual, "rotation", 0.0, 0.08)

func _attack_bow(now: float) -> void:
	if not _spend_stamina(12.0):
		return
	_combo_step = 0
	combo_changed.emit(0)
	_last_attack_time = now
	_attack_locked_until = now + 0.48
	_spawn_projectile(arrow_scene, 20, 650.0, 130.0)

	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(0.96,1.04), 0.10)
	tween.tween_property(visual, "scale", _visual_base_scale, 0.18)

func _attack_staff(now: float) -> void:
	if not _spend_stamina(20.0):
		return
	_combo_step = 0
	combo_changed.emit(0)
	_last_attack_time = now
	_attack_locked_until = now + 0.62
	_spawn_projectile(arcane_scene, 28, 430.0, 230.0)

	var tween := create_tween()
	tween.tween_property(visual, "rotation", -0.14 * facing, 0.15)
	tween.tween_property(visual, "rotation", 0.0, 0.22)

func _spawn_projectile(scene: PackedScene, damage: int, speed: float, knockback: float) -> void:
	var projectile := scene.instantiate() as CombatProjectile
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = projectile_origin.global_position + Vector2(24.0 * facing, -6.0)
	projectile.configure(facing, damage, speed, knockback, global_position)

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
