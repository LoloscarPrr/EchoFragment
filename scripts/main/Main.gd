extends Node2D

@onready var player = $Player
@onready var health_bar: ProgressBar = $UI/HUD/HealthBar
@onready var health_label: Label = $UI/HUD/HealthLabel
@onready var stamina_bar: ProgressBar = $UI/HUD/StaminaBar
@onready var stamina_label: Label = $UI/HUD/StaminaLabel
@onready var combo_label: Label = $UI/HUD/ComboLabel
@onready var weapon_label: Label = $UI/HUD/WeaponLabel
@onready var status_label: Label = $UI/HUD/StatusLabel
@onready var prompt_label: Label = $UI/HUD/PromptLabel
@onready var flags_label: Label = $UI/HUD/FlagsLabel
@onready var level_label: Label = $UI/HUD/LevelLabel
@onready var xp_bar: ProgressBar = $UI/HUD/XPBar
@onready var narrative_controller: NarrativeEventController = $NarrativeEventController
@onready var narrative_panel = $UI/NarrativePanel
@onready var inventory_panel = $UI/InventoryPanel
@onready var skills_panel = $UI/SkillsPanel
@onready var virtual_controls = $VirtualControls
@onready var passage_barrier = $PassageBarrier

var _active_event_id: StringName = &""
var _nearby_pickup: ItemPickup = null
var _nearby_event: NarrativeInteractable = null

func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.stamina_changed.connect(_on_player_stamina_changed)
	player.combo_changed.connect(_on_combo_changed)
	player.weapon_changed.connect(_on_weapon_changed)
	player.inventory_changed.connect(_on_inventory_changed)
	player.progression_changed.connect(_refresh_progression)
	player.died.connect(_on_player_died)

	narrative_controller.event_started.connect(_on_event_started)
	narrative_controller.event_resolved.connect(_on_event_resolved)
	narrative_panel.choice_selected.connect(_on_choice_selected)
	narrative_panel.dismissed.connect(_on_narrative_dismissed)

	inventory_panel.equip_requested.connect(_on_inventory_equip_requested)
	inventory_panel.closed.connect(_on_inventory_closed)
	skills_panel.unlock_requested.connect(_on_skill_unlock_requested)
	skills_panel.closed.connect(_on_skills_closed)

	for pickup in get_tree().get_nodes_in_group("item_pickup"):
		pickup.picked_up.connect(_on_item_picked_up)

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)

	_on_player_health_changed(player.health, player.max_health)
	_on_player_stamina_changed(player.stamina, player.max_stamina)
	_on_weapon_changed("Espada")
	_refresh_flags()
	_refresh_progression()

func _process(_delta: float) -> void:
	if narrative_panel.visible or inventory_panel.visible or skills_panel.visible:
		prompt_label.text = ""
		return

	if Input.is_action_just_pressed("inventory"):
		_open_inventory()
		return

	if Input.is_action_just_pressed("skills"):
		_open_skills()
		return

	_nearby_pickup = _find_nearby_pickup()
	if _nearby_pickup != null:
		prompt_label.text = "E / USAR — Recoger " + _nearby_pickup.display_name
		if Input.is_action_just_pressed("interact"):
			_nearby_pickup.pick_up()
		return

	_nearby_event = _find_nearby_event()
	if _nearby_event != null:
		prompt_label.text = "E / USAR — " + _nearby_event.prompt_text
		if Input.is_action_just_pressed("interact"):
			narrative_controller.start_event(_nearby_event.event_id)
		return

	prompt_label.text = ""

func _find_nearby_pickup() -> ItemPickup:
	var nearest: ItemPickup = null
	var best_distance := 110.0
	for pickup in get_tree().get_nodes_in_group("item_pickup"):
		if not is_instance_valid(pickup):
			continue
		var distance := player.global_position.distance_to(pickup.global_position)
		if distance <= best_distance:
			best_distance = distance
			nearest = pickup
	return nearest

func _find_nearby_event() -> NarrativeInteractable:
	var nearest: NarrativeInteractable = null
	var best_distance := 125.0
	for event_node in get_tree().get_nodes_in_group("narrative_event"):
		if not is_instance_valid(event_node):
			continue
		if not narrative_controller.can_start(event_node.event_id):
			continue
		var distance := player.global_position.distance_to(event_node.global_position)
		if distance <= best_distance:
			best_distance = distance
			nearest = event_node
	return nearest

func _open_inventory() -> void:
	player.can_control = false
	player.velocity = Vector2.ZERO
	virtual_controls.visible = false
	inventory_panel.open_inventory(player.inventory)
	status_label.text = "Inventario abierto"

func _open_skills() -> void:
	player.can_control = false
	player.velocity = Vector2.ZERO
	virtual_controls.visible = false
	skills_panel.open_skills(player.progression)
	status_label.text = "Habilidades"

func _on_inventory_equip_requested(item_id: StringName) -> void:
	if player.equip_weapon(item_id):
		inventory_panel.open_inventory(player.inventory)
		status_label.text = "Arma equipada"

func _on_inventory_closed() -> void:
	player.can_control = true
	virtual_controls.visible = true
	status_label.text = "FASE 0.8 — Camino de Valle Gris"

func _on_skill_unlock_requested(skill_id: StringName) -> void:
	if player.unlock_skill(skill_id):
		skills_panel.open_skills(player.progression)
		status_label.text = "Habilidad aprendida"
		_refresh_progression()

func _on_skills_closed() -> void:
	player.can_control = true
	virtual_controls.visible = true
	status_label.text = "FASE 0.8 — Camino de Valle Gris"

func _on_item_picked_up(item_id: StringName, amount: int) -> void:
	player.add_item(item_id, amount)
	status_label.text = "Objeto recogido"
	_on_inventory_changed()

func _on_inventory_changed() -> void:
	if inventory_panel.visible:
		inventory_panel.open_inventory(player.inventory)

func _on_player_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "VIDA %d / %d" % [current, maximum]

func _on_player_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	stamina_label.text = "AGUANTE %d / %d" % [roundi(current), roundi(maximum)]

func _on_combo_changed(step: int) -> void:
	combo_label.text = "COMBO x%d" % step if step > 0 else ""

func _on_weapon_changed(display_name: String) -> void:
	weapon_label.text = "ARMA: " + display_name

func _refresh_progression() -> void:
	var progression := player.progression
	var required := progression.xp_required_for_level(progression.level)
	level_label.text = "NIVEL %d · PUNTOS %d" % [progression.level, progression.skill_points]
	xp_bar.max_value = required
	xp_bar.value = progression.experience

func _on_player_died() -> void:
	status_label.text = "Has caído — Camino de Valle Gris"

func _on_enemy_died() -> void:
	player.add_experience(70)
	status_label.text = "Enemigo derrotado · +70 EXP"
	_refresh_progression()

func _on_event_started(event_id: StringName, title: String, body: String, choices: Array) -> void:
	_active_event_id = event_id
	player.can_control = false
	player.velocity = Vector2.ZERO
	virtual_controls.visible = false
	narrative_panel.show_event(title, body, choices)
	status_label.text = "Decisión narrativa activa"

func _on_choice_selected(choice_id: StringName) -> void:
	if _active_event_id == &"":
		return
	narrative_controller.resolve_choice(_active_event_id, choice_id)

func _on_event_resolved(event_id: StringName, choice_id: StringName, result_text: String) -> void:
	player.add_experience(50)

	match choice_id:
		&"help":
			player.heal(25)
			$TravelerEvent.modulate = Color(0.55, 0.85, 0.62, 1.0)
		&"investigate":
			var ambusher = get_node_or_null("Ambusher")
			if ambusher != null:
				ambusher.global_position.x += 260.0
		&"intimidate":
			$TravelerEvent.modulate = Color(0.75, 0.55, 0.55, 1.0)
		&"leave":
			var ambusher = get_node_or_null("Ambusher")
			if ambusher != null:
				ambusher.global_position.x = maxf(player.global_position.x + 300.0, 850.0)
		&"study_shrine":
			player.add_experience(30)
			status_label.text = "Comprendiste las runas del santuario"
		&"pray_shrine":
			player.heal(15)
			status_label.text = "El santuario te devuelve algo de fuerza"
		&"disturb_shrine":
			player.add_item(&"apprentice_staff")
			status_label.text = "Hallaste un báculo bajo la losa"
		&"force_passage", &"hidden_route":
			_open_passage()
			status_label.text = "Ruta hacia Valle Gris abierta"
		&"turn_back":
			status_label.text = "El paso sigue bloqueado"

	narrative_panel.show_result(result_text + "

Has obtenido 50 EXP.")
	_refresh_flags()
	_refresh_progression()

func _open_passage() -> void:
	if is_instance_valid(passage_barrier):
		passage_barrier.queue_free()
	narrative_controller.world_state.set_flag(&"road_to_valle_gris_open", true)

func _on_narrative_dismissed() -> void:
	_active_event_id = &""
	player.can_control = true
	virtual_controls.visible = true
	_refresh_flags()

func _refresh_flags() -> void:
	var world := narrative_controller.world_state
	var names: Array[String] = []
	for key in world.flags.keys():
		if bool(world.flags[key]):
			names.append(String(key))
	flags_label.text = "MUNDO: " + (", ".join(names) if not names.is_empty() else "sin decisiones todavía")
