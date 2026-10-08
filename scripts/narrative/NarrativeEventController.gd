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
	_register_traveler()
	_register_old_shrine()
	_register_collapsed_passage()

func _register_traveler() -> void:
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

func _register_old_shrine() -> void:
	var event := NarrativeEvent.new()
	event.id = &"old_shrine"
	event.title = "Santuario quebrado"
	event.body = "Un santuario de piedra emerge entre raíces negras. Su cuenco conserva ceniza tibia pese a los años."

	var study := EventChoice.new()
	study.id = &"study_shrine"
	study.text = "[Intelecto 6] Leer las runas erosionadas"
	study.required_stat = &"intellect"
	study.required_value = 6
	study.grants_flag = &"shrine_understood"

	var pray := EventChoice.new()
	pray.id = &"pray_shrine"
	pray.text = "Dejar una moneda imaginaria y guardar silencio"
	pray.grants_flag = &"shrine_respected"

	var disturb := EventChoice.new()
	disturb.id = &"disturb_shrine"
	disturb.text = "[Fuerza 7] Apartar la losa sellada"
	disturb.required_stat = &"strength"
	disturb.required_value = 7
	disturb.grants_flag = &"shrine_opened"

	event.choices = [study, pray, disturb]
	_events[event.id] = event

func _register_collapsed_passage() -> void:
	var event := NarrativeEvent.new()
	event.id = &"collapsed_passage"
	event.title = "Paso derrumbado"
	event.body = "La antigua calzada termina bajo vigas rotas y piedra húmeda. Más allá se ven las primeras murallas de Valle Gris."

	var force := EventChoice.new()
	force.id = &"force_passage"
	force.text = "[Fuerza 7] Apartar los escombros"
	force.required_stat = &"strength"
	force.required_value = 7
	force.grants_flag = &"passage_forced"

	var hidden := EventChoice.new()
	hidden.id = &"hidden_route"
	hidden.text = "[Huellas descubiertas] Seguir el sendero de los emboscadores"
	hidden.required_flag = &"ambush_discovered"
	hidden.grants_flag = &"hidden_route_found"

	var turn_back := EventChoice.new()
	turn_back.id = &"turn_back"
	turn_back.text = "Retroceder y buscar otra forma"
	turn_back.grants_flag = &"passage_refused"

	event.choices = [force, hidden, turn_back]
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
	event_started.emit(event.id, event.title, event.body, event.available_choices(character_stats, world_state))

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

	event_resolved.emit(event_id, choice_id, _result_text(choice_id))

func _result_text(choice_id: StringName) -> String:
	match choice_id:
		&"help":
			return "El viajero te entrega una pequeña bolsa y promete recordar tu rostro."
		&"investigate":
			return "Descubres huellas recientes: la emboscada aún no ha terminado. Ahora puedes prepararte."
		&"intimidate":
			return "El hombre, aterrorizado, te entrega la carta sellada."
		&"leave":
			return "Te alejas. Detrás de ti, los ruidos del bosque se acercan al carro."
		&"study_shrine":
			return "Las runas hablan de un acceso secundario usado por antiguos guardianes."
		&"pray_shrine":
			return "El silencio pesa distinto al retirarte. Algo parece haberte reconocido."
		&"disturb_shrine":
			return "Bajo la losa encuentras restos de un antiguo escondite."
		&"force_passage":
			return "Con esfuerzo logras abrir un hueco entre los escombros."
		&"hidden_route":
			return "Las huellas te conducen por un sendero lateral que evita el derrumbe."
		&"turn_back":
			return "Decides no arriesgarte todavía."
	return "La decisión queda registrada."
