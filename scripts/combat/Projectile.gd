class_name CombatProjectile
extends Area2D

@export var speed := 520.0
@export var damage := 18
@export var lifetime := 2.0
@export var knockback := 160.0

var direction := 1.0
var source_position := Vector2.ZERO
var _time_left := 0.0
var max_targets := 1
var _targets_hit: Dictionary = {}

func _ready() -> void:
	_time_left = lifetime

func configure(dir: float, dmg: int, projectile_speed: float, kb: float, source: Vector2, pierce_count: int = 1) -> void:
	max_targets = maxi(1, pierce_count)
	_targets_hit.clear()
	direction = sign(dir)
	if direction == 0.0:
		direction = 1.0
	damage = dmg
	speed = projectile_speed
	knockback = kb
	source_position = source

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
		return

	for area in get_overlapping_areas():
		if not area.has_method("receive_hit"):
			continue
		var id := area.get_instance_id()
		if _targets_hit.has(id):
			continue
		_targets_hit[id] = true
		area.receive_hit(damage, source_position, knockback)
		if _targets_hit.size() >= max_targets:
			queue_free()
			return
