class_name CharacterStats
extends Resource

@export var strength: int = 5
@export var dexterity: int = 5
@export var constitution: int = 5
@export var intellect: int = 5
@export var willpower: int = 5
@export var presence: int = 5

func meets_requirement(stat_name: StringName, required_value: int) -> bool:
	match stat_name:
		&"strength":
			return strength >= required_value
		&"dexterity":
			return dexterity >= required_value
		&"constitution":
			return constitution >= required_value
		&"intellect":
			return intellect >= required_value
		&"willpower":
			return willpower >= required_value
		&"presence":
			return presence >= required_value
		_:
			return false
