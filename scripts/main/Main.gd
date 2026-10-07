extends Node2D

@onready var player = $Player
@onready var health_bar: ProgressBar = $UI/HUD/HealthBar
@onready var health_label: Label = $UI/HUD/HealthLabel
@onready var status_label: Label = $UI/HUD/StatusLabel
@onready var enemy = $Enemy

func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	enemy.died.connect(_on_enemy_died)
	_on_player_health_changed(player.health, player.max_health)

func _on_player_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "VIDA %d / %d" % [current, maximum]

func _on_player_died() -> void:
	status_label.text = "Has caído — prototipo 0.2"

func _on_enemy_died() -> void:
	status_label.text = "Enemigo derrotado"
