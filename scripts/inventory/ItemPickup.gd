class_name ItemPickup
extends Area2D

signal picked_up(item_id: StringName, amount: int)

@export var item_id: StringName
@export var display_name := "Objeto"
@export var amount := 1

func pick_up() -> void:
	picked_up.emit(item_id, amount)
	queue_free()
