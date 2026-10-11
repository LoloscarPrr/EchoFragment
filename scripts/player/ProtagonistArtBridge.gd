class_name ProtagonistArtBridge
extends Node2D

## Opt-in renderer for the original hand-drawn protagonist SpriteFrames.
## Existing procedural art is the fallback until the resource is produced.
const FRAMES_PATH := "res://assets/characters/portador_eco/portador_eco_frames.tres"

var has_art := false
var _sprite: AnimatedSprite2D

func _ready() -> void:
	if not ResourceLoader.exists(FRAMES_PATH):
		return
	var candidate: Resource = load(FRAMES_PATH)
	if not candidate is SpriteFrames:
		push_warning("EchoFragment: protagonist visual asset must be a SpriteFrames resource.")
		return
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = candidate as SpriteFrames
	_sprite.centered = true
	_sprite.offset = Vector2(0.0, -5.0)
	add_child(_sprite)
	has_art = true

func configure(state: StringName, drawing_index: int, facing: float) -> void:
	if not has_art or not is_instance_valid(_sprite):
		return
	var available: SpriteFrames = _sprite.sprite_frames
	var chosen: StringName = state
	if not available.has_animation(chosen):
		chosen = &"idle_ready"
	if not available.has_animation(chosen):
		_sprite.visible = false
		return
	var count: int = available.get_frame_count(chosen)
	if count <= 0:
		_sprite.visible = false
		return
	_sprite.visible = true
	if _sprite.animation != chosen:
		_sprite.animation = chosen
	_sprite.frame = clampi(drawing_index, 0, count - 1)
	_sprite.flip_h = facing < 0.0
