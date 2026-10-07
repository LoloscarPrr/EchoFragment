class_name WeaponData
extends Resource

enum WeaponFamily {
	SWORD,
	BOW,
	STAFF,
	DAGGERS
}

@export var id: StringName
@export var display_name: String
@export var family: WeaponFamily = WeaponFamily.SWORD
@export var base_damage: int = 10
@export var attack_cooldown: float = 0.5
@export var stamina_cost: float = 10.0
@export var range: float = 64.0
