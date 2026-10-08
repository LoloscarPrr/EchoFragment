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
@onready var enemy = $Enemy
@onready var traveler = $TravelerEvent
@onready var narrative_controller: NarrativeEventController = $NarrativeEventController
@onready var narrative_panel = $UI/NarrativePanel
@onready var virtual_controls = $VirtualControls

var _active_event_id: StringName = &""

func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.stamina_changed.connect(_on_player_stamina_changed)
	player.combo_changed.connect(_on_combo_changed)
	player.weapon_changed.connect(_on_weapon_changed)
	player.died.connect(_on_player_died)
	enemy.died.connect(_on_enemy_died)

	narrative_controller.event_started.connect(_on_event_started)
	narrative_controller.event_resolved.connect(_on_event_resolved)
	narrative_panel.choice_selected.connect(_on_choice_selected)
	narrative_panel.dismissed.connect(_on_narrative_dismissed)

	_on_player_health_changed(player.health, player.max_health)
	_on_player_stamina_changed(player.stamina, player.max_stamina)
	_on_weapon_changed("Espada")
	_refresh_flags()

func _process(_delta: float) -> void:
	if narrative_panel.visible:
		prompt_label.text = ""
		return

	var distance := player.global_position.distance_to(traveler.global_position)
	var can_interact := distance <= 120.0 and narrative_controller.can_start(traveler.event_id)
	if can_interact:
		prompt_label.text = "E / INTERACTUAR — Viajero herido"
		if Input.is_action_just_pressed("interact"):
			narrative_controller.start_event(traveler.event_id)
	else:
		prompt_label.text = ""

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

func _on_player_died() -> void:
	status_label.text = "Has caído — prototipo 0.5"

func _on_enemy_died() -> void:
	status_label.text = "Enemigo derrotado"

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

func _on_event_resolved(_event_id: StringName, choice_id: StringName, result_text: String) -> void:
	match choice_id:
		&"help":
			player.heal(25)
			traveler.modulate = Color(0.55, 0.85, 0.62, 1.0)
			status_label.text = "Ayudaste al viajero · vida restaurada"
		&"investigate":
			enemy.global_position.x = 1240.0
			traveler.modulate = Color(0.70, 0.82, 1.0, 1.0)
			status_label.text = "Emboscada descubierta · enemigo revelado a distancia"
		&"intimidate":
			traveler.modulate = Color(0.75, 0.55, 0.55, 1.0)
			status_label.text = "Conseguiste la carta sellada"
		&"leave":
			enemy.global_position.x = maxf(player.global_position.x + 330.0, 650.0)
			traveler.modulate = Color(0.42, 0.42, 0.42, 1.0)
			status_label.text = "Abandonaste al viajero · el peligro se acerca"

	narrative_panel.show_result(result_text)
	_refresh_flags()

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
