class_name ProtagonistArtBridge
extends Node2D

## P0 asset bridge. A real sprite atlas can replace procedural frames state by
## state, without changing movement, combat, hitboxes, or input handling.
const SHEET_PATH := "res://assets/characters/portador_eco/portador_idle_run_atlas.png"
const CELL_SIZE := Vector2(88, 94)
const ANIMATION_RANGES := {
	&"idle_ready": Vector2i(0, 2),
	&"run_forward": Vector2i(2, 3)
}

var has_art := false
var _sprite: AnimatedSprite2D

func _ready() -> void:
	if not ResourceLoader.exists(SHEET_PATH):
		return
	var texture := load(SHEET_PATH) as Texture2D
	if texture == null:
		push_warning("EchoFragment P0: invalid sprite atlas; procedural visuals will remain active.")
		return
	var required_width := int(CELL_SIZE.x) * 5
	if texture.get_width() < required_width or texture.get_height() < int(CELL_SIZE.y):
		push_warning("EchoFragment P0: unexpected atlas dimensions; procedural visuals will remain active.")
		return

	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	for state in ANIMATION_RANGES:
		var part: Vector2i = ANIMATION_RANGES[state]
		frames.add_animation(state)
		frames.set_animation_loop(state, true)
		frames.set_animation_speed(state, 10.0)
		for index in range(part.y):
			var tile := AtlasTexture.new()
			tile.atlas = texture
			tile.region = Rect2(float(part.x + index) * CELL_SIZE.x, 0.0, CELL_SIZE.x, CELL_SIZE.y)
			tile.filter_clip = true
			frames.add_frame(state, tile)
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = frames
	_sprite.centered = true
	_sprite.offset = Vector2(0.0, -2.0)
	_sprite.visible = false
	add_child(_sprite)
	has_art = true

## Returns true if this particular state has finished sprites, allowing
## the procedural renderer to remain active for jumping, attacks, and dodge.
func configure(state: StringName, drawing_index: int, facing: float) -> bool:
	if not has_art or not is_instance_valid(_sprite):
		return false
	var frames := _sprite.sprite_frames
	if not frames.has_animation(state):
		_sprite.visible = false
		return false
	var frame_count := frames.get_frame_count(state)
	if frame_count <= 0:
		_sprite.visible = false
		return false
	var nominal_count: int = int(P0FrameLibrary.FRAME_COUNTS.get(state, frame_count))
	var mapped_index := clampi(int(floor(float(drawing_index) * frame_count / float(maxi(1, nominal_count)))), 0, frame_count - 1)
	_sprite.animation = state
	_sprite.frame = mapped_index
	_sprite.flip_h = facing < 0.0
	_sprite.visible = true
	return true
