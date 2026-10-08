class_name NarrativeInteractable
extends Area2D

signal interaction_requested(event_id: StringName)

@export var event_id: StringName
@export var prompt_text := "Interactuar"

func interact() -> void:
	interaction_requested.emit(event_id)
