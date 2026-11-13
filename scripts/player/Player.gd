extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal stamina_changed(current: float, maximum: float)
signal combo_changed(step: int)
signal weapon_changed(display_name: String)
signal inventory_changed
signal progression_changed
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
@export var bow_melee_trigger_range := 112.0
@export var bow_combo_window := 1.0
@export var enable_articulated_visual := true
@export var articulated_scale := 1.0
@export var articulated_anchor := Vector2(0, 42)

var health: int
var stamina: float
var facing := 1.0
var can_control := true
var weapon_mode := WeaponMode.SWORD
var inventory := Inventory.new()
var progression := Progression.new()
var animation_controller := CharacterAnimationController.new()
var proxy_visual: ProtagonistProxyVisual
var canonical_visual: CanonicalProtagonistVisual
var articulated_visual: PortadorFullRigV02
var combat_effects: P0CombatEffects
var _sword_hit_committed := false
var _hitstop_active := false

var _combo_step := 0
var _last_attack_time := -99.0
var _attack_locked_until := 0.0
var _dodge_until := 0.0
var _invulnerable_until := 0.0
var _visual_base_scale := Vector2.ONE
var _bow_combo_step := 0
var _bow_combo_deadline := -1.0
var _bow_melee_queued_at := -1.0
var _bow_projectile_queued_at := -1.0
var _bow_projectile_damage := 20
var _bow_projectile_speed := 650.0
var _bow_projectile_knockback := 130.0
var _bow_projectile_charge := 0.0
var _bow_hold_since := -1.0
var _bow_hold_is_melee := false
var _bow_hold_is_finisher := false
var _bow_queued_charge := -1.0
var _bow_queued_finisher := false
var _bow_attack_shape: RectangleShape2D
var _bow_projectile_pierce := 1
var _dagger_ready_at: Array[float] = [0.0, 0.0]
var _shield_hits := 0
var _shield_until := -1.0
var _shield_cooldown_until := 0.0

@onready var visual: Polygon2D = $Visual
@onready var hitbox: CombatHitbox = $AttackHitbox
@onready var projectile_origin: Marker2D = $ProjectileOrigin

var arrow_scene := preload("res://scenes/combat/Arrow.tscn")
var arcane_scene := preload("res://scenes/combat/ArcaneBolt.tscn")
var fire_scene := preload("res://scenes/combat/Firebolt.tscn")
var thrown_dagger_scene := preload("res://scenes/combat/ThrownDagger.tscn")

func _ready() -> void:
	health = max_health
	stamina = max_stamina
	_visual_base_scale = visual.scale
	# This scene reuses the same shape resource for enemy hitboxes.
	# Duplicate the player's shape before expanding the bow sweep.
	var bow_shape_node := hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if bow_shape_node != null and bow_shape_node.shape is RectangleShape2D:
		_bow_attack_shape = bow_shape_node.shape.duplicate() as RectangleShape2D
		bow_shape_node.shape = _bow_attack_shape
	proxy_visual = ProtagonistProxyVisual.new()
	add_child(proxy_visual)
	canonical_visual = CanonicalProtagonistVisual.new()
	add_child(canonical_visual)
	# Load rig only as an opt-in rendering layer. If any PNG is missing,
	# preserve the existing canonical character and combat animations.
	articulated_visual = PortadorPoseVisual.new()
	articulated_visual.name = "ArticulatedVisual"
	articulated_visual.demo_cycle = false
	articulated_visual.scale = Vector2.ONE * articulated_scale
	articulated_visual.position = articulated_anchor
	add_child(articulated_visual)
	articulated_visual.visible = false
	proxy_visual.visible = false
	combat_effects = P0CombatEffects.new()
	add_child(combat_effects)
	visual.visible = false
	health_changed.emit(health, max_health)
	stamina_changed.emit(stamina, max_stamina)
	inventory.add_item(&"rusted_sword")
	inventory.equipped_weapon_changed.connect(_on_equipped_weapon_changed)
	progression.experience_changed.connect(func(_current: int, _required: int) -> void: progression_changed.emit())
	progression.level_changed.connect(func(_level: int, _points: int) -> void: progression_changed.emit())
	progression.skill_points_changed.connect(func(_points: int) -> void: progression_changed.emit())
	progression.skill_unlocked.connect(_on_skill_unlocked)
	weapon_changed.emit(_weapon_name())

func _physics_process(delta: float) -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	_tick_weapon_actions(now)
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
		# Keep directional finger input independent from jump/attack input events.
		var touch_controls := get_node_or_null("../VirtualControls")
		if touch_controls != null and touch_controls.has_method("get_touch_axis"):
			var touch_direction: float = touch_controls.get_touch_axis()
			if touch_direction != 0.0:
				direction = touch_direction

	if direction != 0.0:
		facing = sign(direction)
		velocity.x = move_toward(velocity.x, direction * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

	if can_control and Input.is_action_just_pressed("jump"):
		animation_controller.buffer_action(&"jump")

	if can_control and animation_controller.has_buffered(&"jump") and (is_on_floor() or animation_controller.can_coyote_jump()):
		animation_controller.consume_buffered(&"jump")
		animation_controller.start_jump()
		velocity.y = jump_velocity

	if can_control and Input.is_action_just_pressed("dodge"):
		_try_dodge(direction, now)

	_tick_bow_hold(now)
	if can_control and Input.is_action_just_pressed("attack"):
		# Allow arrow stab -> kick to queue during recovery; drawing is separate.
		animation_controller.buffer_action(&"attack", 32 if weapon_mode == WeaponMode.BOW else 6)

	if can_control and animation_controller.has_buffered(&"attack") and now >= _attack_locked_until:
		animation_controller.consume_buffered(&"attack")
		_try_attack(now)
	_process_queued_bow_shot(now)

	move_and_slide()
	animation_controller.tick(is_on_floor(), velocity)
	_process_animation_combat()
	_process_pending_bow_attack(now)
	_update_visual(delta)

func equip_weapon(item_id: StringName) -> bool:
	return inventory.equip_weapon(item_id)

func add_item(item_id: StringName, amount: int = 1) -> void:
	inventory.add_item(item_id, amount)
	inventory_changed.emit()

func _on_equipped_weapon_changed(item_id: StringName) -> void:
	match item_id:
		&"rusted_sword":
			weapon_mode = WeaponMode.SWORD
		&"hunter_bow":
			weapon_mode = WeaponMode.BOW
		&"apprentice_staff":
			weapon_mode = WeaponMode.STAFF
		&"shadow_daggers":
			weapon_mode = WeaponMode.DAGGERS
		_:
			return
	_cancel_bow_attack()
	_shield_hits = 0
	_shield_until = -1.0
	queue_redraw()
	if _bow_attack_shape != null:
		_bow_attack_shape.size = Vector2(86.0, 66.0)
	_combo_step = 0
	combo_changed.emit(0)
	weapon_changed.emit(_weapon_name())
	_apply_weapon_visual()
	inventory_changed.emit()

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
			weapon_visual.polygon = PackedVector2Array([Vector2(18, -7), Vector2(74, -3), Vector2(74, 3), Vector2(18, 7)])
			weapon_visual.color = Color(0.72,0.77,0.82,1)
		WeaponMode.BOW:
			weapon_visual.polygon = PackedVector2Array([Vector2(20, -26), Vector2(28, -20), Vector2(32, 0), Vector2(28, 20), Vector2(20, 26), Vector2(24, 0)])
			weapon_visual.color = Color(0.55,0.34,0.18,1)
		WeaponMode.STAFF:
			weapon_visual.polygon = PackedVector2Array([Vector2(21, -34), Vector2(27, -34), Vector2(27, 34), Vector2(21, 34)])
			weapon_visual.color = Color(0.45,0.58,0.96,1)
		WeaponMode.DAGGERS:
			weapon_visual.polygon = PackedVector2Array([Vector2(18, -16), Vector2(48, -12), Vector2(48, -6), Vector2(18, -4), Vector2(18, 4), Vector2(48, 6), Vector2(48, 12), Vector2(18, 16)])
			weapon_visual.color = Color(0.82,0.82,0.86,1)

func _regen_stamina(delta: float, now: float) -> void:
	if now < _dodge_until:
		return
	var previous := stamina
	var regen := stamina_regen_per_second + (8.0 if progression.has_skill(&"survival_breath") else 0.0)
	stamina = minf(max_stamina, stamina + regen * delta)
	if not is_equal_approx(previous, stamina):
		stamina_changed.emit(stamina, max_stamina)

func _spend_stamina(amount: float) -> bool:
	if stamina < amount:
		return false
	stamina -= amount
	stamina_changed.emit(stamina, max_stamina)
	return true

func _try_dodge(direction: float, now: float) -> void:
	var actual_dodge_cost := dodge_cost - (8.0 if progression.has_skill(&"cunning_step") else 0.0)
	if now < _attack_locked_until or not _spend_stamina(actual_dodge_cost):
		return

	var dodge_direction := direction
	if dodge_direction == 0.0:
		dodge_direction = facing
	else:
		facing = sign(dodge_direction)

	_cancel_bow_attack()
	velocity.x = dodge_direction * dodge_speed
	velocity.y = 0.0
	var duration_bonus := 0.05 if progression.has_skill(&"cunning_step") else 0.0
	_dodge_until = now + dodge_duration + duration_bonus
	_invulnerable_until = now + dodge_invulnerability + duration_bonus

	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector2(1.28, 0.72), 0.07)
	tween.tween_property(visual, "scale", _visual_base_scale, 0.11)

# Actions sent by the dynamic mobile HUD. Holding is independently captured
# per finger; joystick, jump and dodge are unaffected.
func _tick_weapon_actions(now: float) -> void:
	if _shield_hits > 0:
		if now >= _shield_until:
			_shield_hits = 0
		queue_redraw()
	if not can_control:
		return
	if Input.is_action_just_pressed("weapon_guard"):
		_try_guard(now)
	if weapon_mode != WeaponMode.BOW and Input.is_action_just_pressed("weapon_secondary"):
		_try_secondary_action(now)


func _try_secondary_action(now: float) -> void:
	if now < _attack_locked_until:
		return
	match weapon_mode:
		WeaponMode.SWORD:
			if not _spend_stamina(18.0):
				return
			_spawn_projectile(fire_scene, 32 + (5 if progression.has_skill(&"sword_edge") else 0), 610.0, 250.0)
			_attack_locked_until = now + 0.42
		WeaponMode.DAGGERS:
			var slot := WeaponActionRules.ready_dagger_slot(_dagger_ready_at, now)
			if slot < 0 or not _spend_stamina(8.0):
				return
			var recharge := 3.05 if progression.has_skill(&"daggers_flurry") else WeaponActionRules.DAGGER_RECHARGE
			_dagger_ready_at[slot] = now + recharge
			var blade_damage := 22 + (5 if progression.has_skill(&"daggers_precision") else 0)
			_spawn_projectile(thrown_dagger_scene, blade_damage, 760.0, 180.0)
			_attack_locked_until = now + 0.21


func _try_guard(now: float) -> void:
	if now < _shield_cooldown_until or _shield_hits > 0:
		return
	match weapon_mode:
		WeaponMode.SWORD:
			if not _spend_stamina(16.0):
				return
			_shield_hits = 1
			_shield_until = now + WeaponActionRules.SWORD_BLOCK_DURATION
			_shield_cooldown_until = now + 5.5
		WeaponMode.STAFF:
			var cost := 19.0 if progression.has_skill(&"staff_focus") else 25.0
			if not _spend_stamina(cost):
				return
			_shield_hits = 3
			_shield_until = now + WeaponActionRules.STAFF_BARRIER_DURATION
			_shield_cooldown_until = now + (7.0 if progression.has_skill(&"staff_channel") else 9.0)
		_:
			return
	queue_redraw()


func get_weapon_action_status() -> Dictionary:
	var now: float = Time.get_ticks_msec() / 1000.0
	var guard_cd := WeaponActionRules.cooldown_remaining(_shield_cooldown_until, now)
	match weapon_mode:
		WeaponMode.SWORD:
			return {"primary": "ESPADA", "secondary": "FUEGO", "guard": "BLOQUEO", "secondary_visible": true, "guard_visible": true, "guard_cd": guard_cd, "shield_hits": _shield_hits}
		WeaponMode.BOW:
			var charge := get_bow_charge_fraction()
			return {"primary": "FLECHA", "secondary": ("CARGA %d%%" % roundi(charge * 100.0)) if _bow_hold_since >= 0.0 else "DISPARO", "guard": "", "secondary_visible": true, "guard_visible": false, "charge": charge}
		WeaponMode.DAGGERS:
			var ready := WeaponActionRules.daggers_available(_dagger_ready_at, now)
			var next_ready := minf(_dagger_ready_at[0], _dagger_ready_at[1])
			return {"primary": "DAGAS", "secondary": "LANZAR %d/2" % ready, "guard": "", "secondary_visible": true, "guard_visible": false, "ready": ready, "secondary_cd": WeaponActionRules.cooldown_remaining(next_ready, now)}
		WeaponMode.STAFF:
			return {"primary": "HECHIZO", "secondary": "", "guard": "ESCUDO", "secondary_visible": false, "guard_visible": true, "guard_cd": guard_cd, "shield_hits": _shield_hits}
	return {}


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
	animation_controller.start_light_attack()
	_sword_hit_committed = false
	if now - _last_attack_time <= combo_window:
		_combo_step = (_combo_step % 3) + 1
	else:
		_combo_step = 1
	_last_attack_time = now
	combo_changed.emit(_combo_step)

	var finisher_damage := 46 if progression.has_skill(&"sword_riposte") else 34
	var damage_values := [18, 22, finisher_damage]
	var lock_values := [0.24, 0.28, 0.40]
	var reach_values := [58.0, 64.0, 72.0]
	var base_bonus := 4 if progression.has_skill(&"sword_edge") else 0
	var final_bonus := 14 if _combo_step == 3 and progression.has_skill(&"sword_finale") else 0
	hitbox.damage = damage_values[_combo_step - 1] + base_bonus + final_bonus
	hitbox.knockback = 180.0 + (_combo_step * 35.0)
	if progression.has_skill(&"sword_stagger"):
		hitbox.knockback += 60.0
	if _combo_step == 3 and progression.has_skill(&"sword_riposte"):
		hitbox.knockback += 80.0
	hitbox.position.x = reach_values[_combo_step - 1] * facing
	_attack_locked_until = now + lock_values[_combo_step - 1]

	var angles := [0.18, -0.26, 0.42]
	var tween := create_tween()
	visual.rotation = 0.0
	tween.tween_property(visual, "rotation", angles[_combo_step - 1] * facing, 0.07)
	tween.tween_property(visual, "rotation", 0.0, lock_values[_combo_step - 1] - 0.07)

func _attack_daggers(now: float) -> void:
	var dagger_cost := 5.0 if progression.has_skill(&"daggers_flurry") else 8.0
	if not _spend_stamina(dagger_cost):
		return
	if now - _last_attack_time <= 0.38:
		_combo_step = (_combo_step % 4) + 1
	else:
		_combo_step = 1
	_last_attack_time = now
	combo_changed.emit(_combo_step)

	hitbox.damage = 9 + (_combo_step * 2)
	if progression.has_skill(&"daggers_precision"):
		hitbox.damage += 4
	if _combo_step == 4 and progression.has_skill(&"daggers_execution"):
		hitbox.damage += 8
	hitbox.knockback = 90.0
	hitbox.position.x = 46.0 * facing
	_attack_locked_until = now + (0.10 if progression.has_skill(&"daggers_flurry") else 0.14)
	hitbox.strike(global_position)
	velocity.x += facing * (68.0 if progression.has_skill(&"daggers_lunge") else 35.0)

	var tween := create_tween()
	tween.tween_property(visual, "rotation", 0.14 * facing * (1 if _combo_step % 2 == 1 else -1), 0.05)
	tween.tween_property(visual, "rotation", 0.0, 0.08)

func _tick_bow_hold(now: float) -> void:
	if not can_control or weapon_mode != WeaponMode.BOW:
		return
	# The secondary button handles hold/release. Melee always uses the primary.
	if Input.is_action_just_pressed("weapon_secondary"):
		_bow_hold_since = now
		if now >= _attack_locked_until:
			animation_controller.set_state(&"bow_draw")
	if _bow_hold_since >= 0.0 and _bow_combo_step == BowCombo.PUSH_KICK:
		# Preserve the kick finisher while the player holds to charge.
		_bow_combo_deadline = now + 0.30
	if Input.is_action_just_released("weapon_secondary") and _bow_hold_since >= 0.0:
		_bow_queued_charge = BowCharge.fraction(now - _bow_hold_since)
		_bow_queued_finisher = _bow_combo_step == BowCombo.PUSH_KICK and now <= _bow_combo_deadline
		_bow_hold_since = -1.0
	_bow_hold_is_melee = false
	if _bow_hold_since >= 0.0 and now >= _attack_locked_until:
		if animation_controller.state != &"bow_draw":
			animation_controller.set_state(&"bow_draw")


func _process_queued_bow_shot(now: float) -> void:
	if not can_control or weapon_mode != WeaponMode.BOW:
		return
	if _bow_queued_charge < 0.0 or now < _attack_locked_until:
		return
	var charge := _bow_queued_charge
	var is_finisher := _bow_queued_finisher
	_bow_queued_charge = -1.0
	_bow_queued_finisher = false
	if not _spend_stamina(12.0 + 6.0 * charge):
		_reset_bow_combo()
		return
	if is_finisher:
		_bow_combo_step = BowCombo.FINISHER_SHOT
		combo_changed.emit(_bow_combo_step)
	else:
		_reset_bow_combo()
	_queue_bow_shot(now, is_finisher, charge)


func get_bow_charge_fraction() -> float:
	if weapon_mode == WeaponMode.BOW and _bow_hold_since >= 0.0 and not _bow_hold_is_melee:
		return BowCharge.fraction(Time.get_ticks_msec() / 1000.0 - _bow_hold_since)
	return 0.0


func _attack_bow(now: float) -> void:
	# Independent short-range button: hand-held arrow -> broad push kick.
	var is_kick := _bow_combo_step == BowCombo.ARROW_STAB and now <= _bow_combo_deadline
	if is_kick:
		if not _spend_stamina(7.0):
			return
		_bow_combo_step = BowCombo.PUSH_KICK
		_attack_locked_until = now + 0.36
		animation_controller.set_state(&"bow_kick")
		_queue_bow_melee(now, 0.13, 18, 480.0, 62.0)
	else:
		if not _spend_stamina(4.0):
			return
		_bow_combo_step = BowCombo.ARROW_STAB
		_attack_locked_until = now + 0.26
		animation_controller.set_state(&"bow_stab")
		_queue_bow_melee(now, 0.09, 14, 75.0, 50.0)
	_bow_combo_deadline = now + bow_combo_window
	combo_changed.emit(_bow_combo_step)


func _bow_target_in_melee_range() -> bool:
	var candidates := get_tree().get_nodes_in_group("enemy")
	# The boss does not belong to the regular enemy group.
	var boss := get_parent().get_node_or_null("FragmentedKnight")
	if is_instance_valid(boss):
		candidates.append(boss)
	for candidate in candidates:
		if not is_instance_valid(candidate):
			continue
		if not candidate.has_method("can_receive_damage") or not candidate.can_receive_damage():
			continue
		var target_body := candidate as Node2D
		if target_body == null:
			continue
		var delta: Vector2 = target_body.global_position - global_position
		if BowCombo.is_target_close(delta, facing, bow_melee_trigger_range):
			return true
	return false


func _queue_bow_melee(now: float, delay: float, damage: int, knockback: float, reach: float) -> void:
	# Wider contact areas intentionally allow one kick or stab to hit a crowd.
	# The geometry is private to the player; enemy hitboxes are not modified.
	if _bow_attack_shape != null:
		_bow_attack_shape.size = Vector2(150.0, 88.0) if knockback >= 350.0 else Vector2(110.0, 78.0)
	if progression.has_skill(&"bow_sweep"):
		damage += 4
		knockback += 70.0
		reach += 22.0
	hitbox.damage = damage
	hitbox.knockback = knockback
	hitbox.position.x = reach * facing
	_bow_melee_queued_at = now + delay


func _queue_bow_shot(now: float, finisher: bool = false, charge: float = 0.0) -> void:
	animation_controller.set_state(&"bow_shot")
	var recovery := 0.46 if finisher else 0.48
	if progression.has_skill(&"bow_quickdraw"):
		recovery = 0.38 if finisher else 0.36
	_attack_locked_until = now + recovery
	var base_damage := (34 if finisher else 28) if progression.has_skill(&"bow_piercing") else (26 if finisher else 20)
	_bow_projectile_damage = BowCharge.damage(base_damage, charge)
	_bow_projectile_speed = BowCharge.speed(780.0 if progression.has_skill(&"bow_piercing") else 650.0, charge)
	_bow_projectile_knockback = BowCharge.knockback((220.0 if finisher else 160.0) if progression.has_skill(&"bow_piercing") else (200.0 if finisher else 130.0), charge)
	_bow_projectile_charge = charge
	_bow_projectile_pierce = WeaponActionRules.bow_piercing(charge, progression.has_skill(&"bow_piercing"))
	if finisher and progression.has_skill(&"bow_finisher"):
		_bow_projectile_damage += 12
		_bow_projectile_speed += 65.0
	_bow_projectile_queued_at = now + (0.11 if progression.has_skill(&"bow_quickdraw") else 0.17)


func _process_pending_bow_attack(now: float) -> void:
	if not can_control:
		_cancel_bow_attack()
		return
	if _bow_melee_queued_at >= 0.0 and now >= _bow_melee_queued_at:
		_bow_melee_queued_at = -1.0
		var hits := hitbox.strike(global_position)
		if hits > 0:
			if is_instance_valid(combat_effects):
				combat_effects.play_impact(Vector2(hitbox.position.x, -6.0))
			_apply_hit_stop(0.035)
	if _bow_projectile_queued_at >= 0.0 and now >= _bow_projectile_queued_at:
		_bow_projectile_queued_at = -1.0
		_spawn_projectile(arrow_scene, _bow_projectile_damage, _bow_projectile_speed, _bow_projectile_knockback, _bow_projectile_charge, _bow_projectile_pierce)
		_reset_bow_combo()
	if _bow_combo_step > 0 and now > _bow_combo_deadline and _bow_projectile_queued_at < 0.0 and _bow_queued_charge < 0.0 and _bow_hold_since < 0.0:
		_reset_bow_combo()


func _reset_bow_combo() -> void:
	if _bow_combo_step != 0:
		_bow_combo_step = 0
		combo_changed.emit(0)
	_bow_combo_deadline = -1.0


func _cancel_bow_attack() -> void:
	_bow_hold_since = -1.0
	_bow_hold_is_melee = false
	_bow_hold_is_finisher = false
	_bow_queued_charge = -1.0
	_bow_queued_finisher = false
	_bow_melee_queued_at = -1.0
	_bow_projectile_queued_at = -1.0
	_reset_bow_combo()

func _attack_staff(now: float) -> void:
	var cost := 14.0 if progression.has_skill(&"staff_focus") else 20.0
	if not _spend_stamina(cost):
		return
	_combo_step = 0
	combo_changed.emit(0)
	_last_attack_time = now
	_attack_locked_until = now + (0.50 if progression.has_skill(&"staff_channel") else 0.62)
	var spell_damage := 40 if progression.has_skill(&"staff_overcharge") else 28
	var spell_knockback := 320.0 if progression.has_skill(&"staff_overcharge") else 230.0
	var spell_speed := 430.0
	if progression.has_skill(&"staff_echo"):
		spell_damage += 10
		spell_knockback += 90.0
		spell_speed += 80.0
	_spawn_projectile(arcane_scene, spell_damage, spell_speed, spell_knockback)

	var tween := create_tween()
	tween.tween_property(visual, "rotation", -0.14 * facing, 0.15)
	tween.tween_property(visual, "rotation", 0.0, 0.22)

func _spawn_projectile(scene: PackedScene, damage: int, speed: float, knockback: float, charge: float = 0.0, pierce_count: int = 1) -> void:
	var projectile := scene.instantiate() as CombatProjectile
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = projectile_origin.global_position + Vector2(24.0 * facing, -6.0)
	projectile.configure(facing, damage, speed, knockback, global_position, pierce_count)
	if charge > 0.1:
		projectile.modulate = Color(1.0, 0.48 + 0.52 * (1.0 - charge), 0.58 + 0.42 * (1.0 - charge), 1.0)
		projectile.scale *= 1.0 + charge * 0.45

func _update_visual(delta: float) -> void:
	# Switch only the drawing layer; keep movement, attack hitboxes and timing.
	var sword_equipped := weapon_mode == WeaponMode.SWORD
	var rig_ready := enable_articulated_visual and is_instance_valid(articulated_visual) and articulated_visual.art_loaded
	var show_canonical := sword_equipped and not rig_ready and is_instance_valid(canonical_visual)
	if is_instance_valid(articulated_visual):
		articulated_visual.visible = rig_ready
		if rig_ready:
			# Dodge runs on physical time, independently of the animation controller.
			var animation_state: StringName = animation_controller.state
			var animation_progress := animation_controller.state_progress()
			var now := Time.get_ticks_msec() / 1000.0
			if now < _dodge_until:
				animation_state = &"dodge"
				var duration := dodge_duration + (0.05 if progression.has_skill(&"cunning_step") else 0.0)
				animation_progress = clampf(1.0 - (_dodge_until - now) / maxf(0.01, duration), 0.0, 1.0)
			articulated_visual.configure(animation_state, animation_progress, facing)
	if is_instance_valid(canonical_visual):
		canonical_visual.visible = show_canonical
		if show_canonical:
			canonical_visual.configure(animation_controller.state, animation_controller.state_progress(), facing, animation_controller.attack_reference_frame_index())
	if is_instance_valid(proxy_visual):
		proxy_visual.visible = not sword_equipped and not rig_ready
		if not sword_equipped and not rig_ready:
			proxy_visual.configure(animation_controller.state, animation_controller.state_progress(), facing, animation_controller.drawing_index(), weapon_mode == WeaponMode.BOW, get_bow_charge_fraction())
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

func _draw() -> void:
	if _shield_hits <= 0 or Time.get_ticks_msec() / 1000.0 >= _shield_until:
		return
	var arcane := weapon_mode == WeaponMode.STAFF
	var interior := Color(0.46, 0.67, 1.0, 0.20) if arcane else Color(1.0, 0.29, 0.27, 0.19)
	var outline := Color(0.55, 0.77, 1.0, 0.92) if arcane else Color(1.0, 0.33, 0.31, 0.94)
	draw_circle(Vector2(0, -24), 52.0, interior)
	draw_arc(Vector2(0, -24), 52.0, 0.0, TAU, 48, outline, 4.0, true)


func can_receive_damage() -> bool:
	return health > 0 and Time.get_ticks_msec() / 1000.0 >= _invulnerable_until

func take_damage(amount: int, source_position := Vector2.ZERO, knockback := 220.0) -> void:
	if not can_receive_damage():
		return
	var now: float = Time.get_ticks_msec() / 1000.0
	if _shield_hits > 0 and now < _shield_until:
		_shield_hits -= 1
		_invulnerable_until = now + 0.20
		queue_redraw()
		if is_instance_valid(combat_effects):
			combat_effects.play_impact(Vector2(0, -22))
		return
	_cancel_bow_attack()
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)

	if source_position != Vector2.ZERO:
		var knock_dir: float = signf(global_position.x - source_position.x)
		if knock_dir == 0.0:
			knock_dir = -facing
		velocity.x = knock_dir * knockback
		velocity.y = -120.0

	animation_controller.start_light_hit()
	var tween := create_tween()
	tween.tween_property(proxy_visual, "modulate:a", 0.25, 0.05)
	tween.tween_property(proxy_visual, "modulate:a", 1.0, 0.10)

	if health == 0:
		die()

func die() -> void:
	can_control = false
	velocity = Vector2.ZERO
	died.emit()
	var tween := create_tween()
	tween.tween_property(visual, "rotation", 1.45 * facing, 0.35)
	tween.parallel().tween_property(visual, "modulate:a", 0.35, 0.35)


func heal(amount: int) -> void:
	if health <= 0:
		return
	health = mini(max_health, health + amount)
	health_changed.emit(health, max_health)


func add_experience(amount: int) -> void:
	progression.add_experience(amount)
	progression_changed.emit()

func unlock_skill(skill_id: StringName) -> bool:
	var item: StringName = SkillCatalog.weapon_item(skill_id)
	if item != &"" and not inventory.has_item(item):
		return false
	var unlocked: bool = progression.unlock(skill_id)
	if unlocked:
		progression_changed.emit()
	return unlocked

func _on_skill_unlocked(skill_id: StringName) -> void:
	if skill_id == &"survival_breath":
		max_stamina += 20.0
		stamina = minf(max_stamina, stamina + 20.0)
		stamina_changed.emit(stamina, max_stamina)
	progression_changed.emit()


func _process_animation_combat() -> void:
	if weapon_mode != WeaponMode.SWORD:
		return
	if animation_controller.state != &"attack_light":
		_sword_hit_committed = false
		return
	if _sword_hit_committed:
		return

	var tick := animation_controller.state_tick
	if not TajoDelEcoTimeline.strike_is_ready(tick):
		return

	_sword_hit_committed = true
	# The canonical slash pose already contains its red Echo energy. Avoid
	# layering the old generic painted arc on top of the real illustration.
	if is_instance_valid(combat_effects) and not (is_instance_valid(canonical_visual) and canonical_visual.visible):
		combat_effects.play_slash(facing)

	var hit_count := hitbox.strike(global_position)
	if hit_count > 0:
		if is_instance_valid(combat_effects):
			combat_effects.play_impact(Vector2(hitbox.position.x, -6.0))
		_apply_hit_stop(0.055)

func _apply_hit_stop(duration: float) -> void:
	if _hitstop_active:
		return
	_hitstop_active = true
	var previous_scale := Engine.time_scale
	Engine.time_scale = 0.08
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = previous_scale
	_hitstop_active = false
