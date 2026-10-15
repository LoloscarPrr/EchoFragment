class_name CanonicalProtagonistVisual
extends Node2D

## EchoFragment Fase 1.2: first visible integration of the canonical Portador del Eco.
## The textures are isolated still poses from the *original* concept sheet.
## They are NOT the finished 16-frame animation; preserving that distinction is deliberate.
const IDLE_TEXTURE: Texture2D = preload("res://assets/player/portador_eco/idle_profile.webp")
const GUARD_TEXTURE: Texture2D = preload("res://assets/player/portador_eco/guard.webp")
const SLASH_TEXTURE: Texture2D = preload("res://assets/player/portador_eco/slash.webp")

const FEET_Y := 49.0
const IDLE_PIVOT := Vector2(97.0, 510.0)
const GUARD_PIVOT := Vector2(290.0, 218.0)
const SLASH_PIVOT := Vector2(313.0, 216.0)
const IDLE_SCALE := 0.21
const ATTACK_SCALE := 0.46

var _sprite: Sprite2D
var _elapsed := 0.0
var _state: StringName = &"idle_ready"
var _stance: StringName = &"idle"
var _facing := 1.0
var _base_y := 0.0

func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.name = "PortadorDelEco_OriginalArt"
	_sprite.centered = false
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_sprite)
	_update_sprite()

func _process(delta: float) -> void:
	_elapsed += delta
	if not is_instance_valid(_sprite):
		return
	# Only a subtle body animation until proper running/jump frames are drawn.
	# Never modify the player root, collision shapes, or physical jumping velocity.
	if _state == &"run_forward":
		_sprite.position.y = _base_y - absf(sin(_elapsed * 12.0)) * 1.5
	else:
		_sprite.position.y = _base_y

func configure(state: StringName, _progress: float, facing: float, reference_frame: int = -1) -> void:
	_state = state
	_facing = signf(facing) if facing != 0.0 else 1.0
	var next_stance: StringName = &"idle"
	if state == &"attack_light":
		# A small true-to-source pose library, not synthetic rotations of body pieces.
		# Gameplay's full 18-tick rhythm/hitbox timing is unchanged.
		if reference_frame >= 6 and reference_frame <= 10:
			next_stance = &"slash"
		elif reference_frame >= 1 and reference_frame <= 14:
			next_stance = &"guard"
	if next_stance != _stance:
		_stance = next_stance
	_update_sprite()
	else:
		_update_facing_and_anchor()

func _update_sprite() -> void:
	if not is_instance_valid(_sprite):
		return
	match _stance:
		&"guard":
			_sprite.texture = GUARD_TEXTURE
			_sprite.scale = Vector2.ONE * ATTACK_SCALE
		&"slash":
			_sprite.texture = SLASH_TEXTURE
			_sprite.scale = Vector2.ONE * ATTACK_SCALE
		_:
			_sprite.texture = IDLE_TEXTURE
			_sprite.scale = Vector2.ONE * IDLE_SCALE
	_update_facing_and_anchor()

func _update_facing_and_anchor() -> void:
	if not is_instance_valid(_sprite) or _sprite.texture == null:
		return
	var pivot := IDLE_PIVOT
	var texture_faces_right := false
	if _stance == &"guard":
		pivot = GUARD_PIVOT
		texture_faces_right = true
	elif _stance == &"slash":
		pivot = SLASH_PIVOT
		texture_faces_right = true
	var want_right := _facing > 0.0
	var mirrored := want_right != texture_faces_right
	_sprite.flip_h = mirrored
	var actual_pivot_x := float(_sprite.texture.get_width()) - pivot.x if mirrored else pivot.x
	var s := _sprite.scale.x
	_sprite.position = Vector2(-actual_pivot_x * s, FEET_Y - pivot.y * s)
	_base_y = _sprite.position.y