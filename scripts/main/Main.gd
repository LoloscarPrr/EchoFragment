extends Node2D

@onready var player = $Player
@onready var health_bar: ProgressBar = $UI/HUD/HealthBar
@onready var health_label: Label = $UI/HUD/HealthLabel
@onready var stamina_bar: ProgressBar = $UI/HUD/StaminaBar
@onready var stamina_label: Label = $UI/HUD/StaminaLabel
@onready var combo_label: Label = $UI/HUD/ComboLabel
@onready var status_label: Label = $UI/HUD/StatusLabel
@onready var enemy = $Enemy

func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.stamina_changed.connect(_on_player_stamina_changed)
	player.combo_changed.connect(_on_combo_changed)
	player.died.connect(_on_player_died)
	enemy.died.connect(_on_enemy_died)
	_on_player_health_changed(player.health, player.max_health)
	_on_player_stamina_changed(player.stamina, player.max_stamina)

func _on_player_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "VIDA %d / %d" % [current, maximum]

func _on_player_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	stamina_label.text = "AGUANTE %d / %d" % [roundi(current), roundi(maximum)]

func _on_combo_changed(step: int) -> void:
	combo_label.text = "COMBO x%d" % step

func _on_player_died() -> void:
	status_label.text = "Has caído — prototipo 0.3"

func _on_enemy_died() -> void:
	status_label.text = "Enemigo derrotado · combo y esquiva activos"
