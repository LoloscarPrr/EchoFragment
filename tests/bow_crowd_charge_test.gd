extends SceneTree

class DummyTarget:
	extends Area2D
	var hits := 0
	var last_damage := 0
	var last_knockback := 0.0

	func receive_hit(amount: int, _source: Vector2, impulse: float) -> void:
		hits += 1
		last_damage = amount
		last_knockback = impulse


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	assert(is_equal_approx(BowCharge.fraction(0.0), 0.0))
	assert(is_equal_approx(BowCharge.fraction(0.60), 0.5))
	assert(is_equal_approx(BowCharge.fraction(2.0), 1.0))
	assert(BowCharge.damage(20, 1.0) == 50)
	assert(BowCharge.knockback(130.0, 1.0) == 310.0)
	assert(BowCharge.speed(650.0, 1.0) == 840.0)

	var stage := Node2D.new()
	root.add_child(stage)
	var hitbox := CombatHitbox.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 32
	hitbox.monitoring = true
	hitbox.monitorable = false
	hitbox.damage = 18
	hitbox.knockback = 480.0
	stage.add_child(hitbox)
	var hit_shape := CollisionShape2D.new()
	var attack_rect := RectangleShape2D.new()
	attack_rect.size = Vector2(150, 88)
	hit_shape.shape = attack_rect
	hitbox.add_child(hit_shape)

	var targets: Array[DummyTarget] = []
	for x in [10.0, 42.0, 67.0]:
		var enemy := DummyTarget.new()
		enemy.position = Vector2(x, 0)
		enemy.collision_layer = 32
		enemy.collision_mask = 0
		enemy.monitorable = true
		enemy.monitoring = false
		stage.add_child(enemy)
		var shape := CollisionShape2D.new()
		var body_rect := RectangleShape2D.new()
		body_rect.size = Vector2(34, 60)
		shape.shape = body_rect
		enemy.add_child(shape)
		targets.append(enemy)

	await physics_frame
	await physics_frame
	await physics_frame
	assert(hitbox.strike(Vector2.ZERO) == 3, "The kick must connect with three enemies at once")
	for enemy in targets:
		assert(enemy.hits == 1, "Targets must be hit exactly once per attack")
		assert(enemy.last_damage == 18)
		assert(is_equal_approx(enemy.last_knockback, 480.0))

	print("Bow charge and 3-target kick assertions passed")
	stage.queue_free()
	quit(0)
