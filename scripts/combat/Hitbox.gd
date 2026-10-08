class_name CombatHitbox
extends Area2D

@export var damage: int = 10
@export var knockback: float = 200.0

func strike(source_position: Vector2) -> int:
	var hit_count := 0
	var already_hit: Dictionary = {}
	for area in get_overlapping_areas():
		if not area.has_method("receive_hit"):
			continue
		var key := area.get_instance_id()
		if already_hit.has(key):
			continue
		already_hit[key] = true
		area.receive_hit(damage, source_position, knockback)
		hit_count += 1
	return hit_count
