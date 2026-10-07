class_name EventChoice
extends Resource

@export var id: StringName
@export_multiline var text: String
@export var required_stat: StringName
@export var required_value: int = 0
@export var required_flag: StringName
@export var grants_flag: StringName
@export var next_event: StringName

func is_available(stats: CharacterStats, world: WorldState) -> bool:
	if required_stat != &"" and not stats.meets_requirement(required_stat, required_value):
		return false
	if required_flag != &"" and not world.has_flag(required_flag):
		return false
	return true
