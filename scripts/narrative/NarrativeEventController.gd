class_name NarrativeEventController
extends Node

signal event_started(event_id: StringName, title: String, body: String, choices: Array)
signal event_resolved(event_id: StringName, choice_id: StringName, result_text: String)

var world_state := WorldState.new()
var character_stats := CharacterStats.new()

var _events: Dictionary = {}

func _ready() -> void:
	character_stats.strength = 7
	character_stats.dexterity = 6
	character_stats.intellect = 6
	character_stats.presence = 5
	_register_prototype_events()

func _register_prototype_events() -> void:
	var event := NarrativeEvent.new()
	event.id = &"wounded_traveler"
	event.title = "El viajero herido"
	event.body = "Junto a un carro volcado, un hombre herido aprieta una carta ensangrentada contra el pecho. Oyes movimiento entre los árboles."

	var help := EventChoice.new()
	help.id = &"help"
	help.text = "Ayudar al viajero"
	help.grants_flag = &"traveler_helped"

	var investigate := EventChoice.new()
	investigate.id = &"investigate"
	investigate.text = "[Intelecto 6] Examinar las huellas alrededor del carro"
	investigate.required_stat = &"intellect"
	investigate.required_value = 6
	investigate.grants_flag = &"ambush_discovered"

	var intimidate := EventChoice.new()
	intimidate.id = &"intimidate"
	intimidate.text = "[Fuerza 7] Exigirle la carta antes de ayudarlo"
	intimidate.required_stat = &"strength"
	intimidate.required_value = 7
	intimidate.grants_flag = &"letter_taken"

	var leave := EventChoice.new()
	leave.id = &"leave"
	leave.text = "Ignorarlo y continuar"
	leave.grants_flag = &"traveler_abandoned"

	event.choices = [help, investigate, intimidate, leave]
	_events[event.id] = event

func can_start(event_id: StringName) -> bool:
	if not _events.has(event_id):
		return false
	var event: NarrativeEvent = _events[event_id]
	if event.one_shot and world_state.completed_events.has(event_id):
		return false
	return true

func start_event(event_id: StringName) -> void:
	if not can_start(event_id):
		return
	var event: NarrativeEvent = _events[event_id]
	var visible_choices := event.available_choices(character_stats, world_state)
	event_started.emit(event.id, event.title, event.body, visible_choices)

func resolve_choice(event_id: StringName, choice_id: StringName) -> void:
	if not _events.has(event_id):
		return
	var event: NarrativeEvent = _events[event_id]
	var selected: EventChoice = null
	for choice in event.available_choices(character_stats, world_state):
		if choice.id == choice_id:
			selected = choice
			break
	if selected == null:
		return

	if selected.grants_flag != &"":
		world_state.set_flag(selected.grants_flag, true)

	if not world_state.completed_events.has(event_id):
		world_state.completed_events.append(event_id)

	var result_text := _result_text(choice_id)
	event_resolved.emit(event_id, choice_id, result_text)

func _result_text(choice_id: StringName) -> String:
	match choice_id:
		&"help":
			return "El viajero te entrega una pequeña bolsa y promete recordar tu rostro."
		&"investigate":
			return "Descubres huellas recientes: la emboscada aún no ha terminado. Ahora puedes prepararte."
		&"intimidate":
			return "El hombre, aterrorizado, te entrega la carta sellada. No olvidará cómo la conseguiste."
		&"leave":
			return "Te alejas. Detrás de ti, los ruidos del bosque se acercan al carro."
	return "La decisión queda registrada."
