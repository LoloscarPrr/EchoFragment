class_name NarrativeEvent
extends Resource

@export var id: StringName
@export var title: String
@export_multiline var body: String
@export var choices: Array[EventChoice] = []
@export var one_shot := true

func available_choices(stats: CharacterStats, world: WorldState) -> Array[EventChoice]:
	var result: Array[EventChoice] = []
	for choice in choices:
		if choice != null and choice.is_available(stats, world):
			result.append(choice)
	return result
