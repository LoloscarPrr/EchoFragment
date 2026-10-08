class_name CombatHurtbox
extends Area2D

@export var receiver_path: NodePath = NodePath("..")

func receive_hit(amount: int, source_position: Vector2, knockback: float = 200.0) -> void:
	var receiver := get_node_or_null(receiver_path)
	if receiver == null:
		return
	if receiver.has_method("can_receive_damage") and not receiver.can_receive_damage():
		return
	if receiver.has_method("take_damage"):
		receiver.take_damage(amount, source_position, knockback)
