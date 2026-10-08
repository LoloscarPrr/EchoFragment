class_name Inventory
extends Resource

signal changed
signal equipped_weapon_changed(weapon_id: StringName)

@export var items: Dictionary = {}
@export var equipped_weapon: StringName = &"rusted_sword"

func add_item(item_id: StringName, amount: int = 1) -> void:
	items[item_id] = int(items.get(item_id, 0)) + amount
	changed.emit()

func remove_item(item_id: StringName, amount: int = 1) -> bool:
	var current := int(items.get(item_id, 0))
	if current < amount:
		return false
	current -= amount
	if current <= 0:
		items.erase(item_id)
	else:
		items[item_id] = current
	changed.emit()
	return true

func has_item(item_id: StringName, amount: int = 1) -> bool:
	return int(items.get(item_id, 0)) >= amount

func equip_weapon(item_id: StringName) -> bool:
	if not has_item(item_id):
		return false
	equipped_weapon = item_id
	equipped_weapon_changed.emit(item_id)
	changed.emit()
	return true
