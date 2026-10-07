extends CharacterBody2D

@export var move_speed: float = 220.0
@export var acceleration: float = 1400.0
@export var deceleration: float = 1800.0
@export var jump_velocity: float = -460.0
@export var gravity: float = 1200.0
@export var max_health: int = 100

var health: int
var facing: float = 1.0
var can_control := true

func _ready() -> void:
	health = max_health

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := 0.0
	if can_control:
		direction = Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		facing = sign(direction)
		velocity.x = move_toward(velocity.x, direction * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

	if can_control and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()

func take_damage(amount: int) -> void:
	health = maxi(0, health - amount)
	if health == 0:
		die()

func die() -> void:
	can_control = false
	velocity = Vector2.ZERO
