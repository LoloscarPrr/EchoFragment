extends Control

signal equip_requested(item_id: StringName)
signal closed

@onready var equipped_label: Label = $Panel/Margin/VBox/Equipped
@onready var list_box: VBoxContainer = $Panel/Margin/VBox/Items
@onready var close_button: Button = $Panel/Margin/VBox/Close

const WEAPON_ORDER := [&"rusted_sword", &"hunter_bow", &"apprentice_staff", &"shadow_daggers"]
const NAMES := {
	&"rusted_sword": "Espada oxidada",
	&"hunter_bow": "Arco de cazador",
	&"apprentice_staff": "Báculo de aprendiz",
	&"shadow_daggers": "Dagas sombrías"
}

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close)

func open_inventory(inventory: Inventory) -> void:
	_refresh(inventory)
	visible = true

func _refresh(inventory: Inventory) -> void:
	for child in list_box.get_children():
		child.queue_free()

	equipped_label.text = "Equipada: " + NAMES.get(inventory.equipped_weapon, String(inventory.equipped_weapon))

	for item in WEAPON_ORDER:
		var item_id: StringName = item
		if not inventory.has_item(item_id):
			continue
		var button: Button = Button.new()
		var is_equipped: bool = inventory.equipped_weapon == item_id
		button.text = (NAMES[item_id] as String) + ("  [EQUIPADA]" if is_equipped else "")
		button.custom_minimum_size.y = 48.0
		button.disabled = is_equipped
		button.focus_mode = Control.FOCUS_NONE
		var captured: StringName = item_id
		button.pressed.connect(func() -> void:
			equip_requested.emit(captured)
		)
		list_box.add_child(button)

func _on_close() -> void:
	visible = false
	closed.emit()
