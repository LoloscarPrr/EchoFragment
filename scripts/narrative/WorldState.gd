class_name WorldState
extends Resource

@export var flags: Dictionary = {}
@export var relationships: Dictionary = {}
@export var discovered_locations: Array[StringName] = []
@export var completed_events: Array[StringName] = []

func set_flag(flag: StringName, value = true) -> void:
	flags[flag] = value

func has_flag(flag: StringName) -> bool:
	return bool(flags.get(flag, false))

func set_relationship(character_id: StringName, value: int) -> void:
	relationships[character_id] = value

func get_relationship(character_id: StringName) -> int:
	return int(relationships.get(character_id, 0))
