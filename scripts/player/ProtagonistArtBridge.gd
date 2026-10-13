class_name ProtagonistArtBridge
extends Node2D

## Multi-atlas visual bridge. Physics, input and combat remain in Player.gd.
## If art is missing or a state is not ready, Player shows its procedural art.
const IDLE_RUN_ATLAS := "res://assets/characters/portador_eco/portador_idle_run_atlas.png"
const MOTION_ATLAS := "res://assets/characters/portador_eco/portador_p0_motion_atlas.png"
const IDLE_RUN_CELL := Vector2i(88, 94)
const MOTION_CELL := Vector2i(96, 86)
const IDLE_RUN_RANGES := {
	&"idle_ready": Vector2i(0, 2),
	&"run_forward": Vector2i(2, 3)
}
# Absolute frame index and number of frames in the motion atlas (7 columns).
const MOTION_RANGES := {
	&"jump_start": Vector2i(0, 1),
	&"jump_rise": Vector2i(1, 1),
	&"jump_apex": Vector2i(2, 1),
	&"jump_fall": Vector2i(3, 1),
	&"land_light": Vector2i(4, 1),
	&"attack_light": Vector2i(5, 2),
	&"hit_light": Vector2i(7, 1),
	&"dodge": Vector2i(8, 2)
}

var has_art := false
var _sprite: AnimatedSprite2D

func _ready() -> void:
	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	_import_sheet(frames, IDLE_RUN_ATLAS, IDLE_RUN_CELL, 5, IDLE_RUN_RANGES)
	_import_sheet(frames, MOTION_ATLAS, MOTION_CELL, 5, MOTION_RANGES)
	if frames.get_animation_names().is_empty():
		return
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = frames
	_sprite.centered = true
	_sprite.offset = Vector2(0.0, -2.0)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.visible = false
	add_child(_sprite)
	has_art = true

func _import_sheet(frames: SpriteFrames, path: String, cell: Vector2i, columns: int, ranges: Dictionary) -> void:
	if not ResourceLoader.exists(path):
		return
	var texture := load(path) as Texture2D
	if texture == null:
		push_warning("EchoFragment P0: unsupported visual texture: " + path)
		return
	for key in ranges.keys():
		var state: StringName = key
		var part: Vector2i = ranges[key]
		var last_index: int = part.x + part.y - 1
		if last_index < 0:
			continue
		var last_row: int = last_index / columns
		if texture.get_width() < columns * cell.x or texture.get_height() < (last_row + 1) * cell.y:
			push_warning("EchoFragment P0: truncated atlas: " + path)
			continue
		frames.add_animation(state)
		frames.set_animation_loop(state, state == &"idle_ready" or state == &"run_forward" or state == &"jump_rise" or state == &"jump_fall")
		frames.set_animation_speed(state, 10.0)
		for i in range(part.y):
			var index: int = part.x + i
			var tile := AtlasTexture.new()
			tile.atlas = texture
			tile.region = Rect2(Vector2i((index % columns) * cell.x, (index / columns) * cell.y), cell)
			tile.filter_clip = true
			frames.add_frame(state, tile)

## Returns true if a valid illustration exists for this specific state.
func configure(state: StringName, drawing_index: int, facing: float) -> bool:
	if not has_art or not is_instance_valid(_sprite):
		return false
	var frames := _sprite.sprite_frames
	if not frames.has_animation(state):
		_sprite.visible = false
		return false
	var count: int = frames.get_frame_count(state)
	if count <= 0:
		_sprite.visible = false
		return false
	var nominal: int = int(P0FrameLibrary.FRAME_COUNTS.get(state, count))
	var mapped: int = clampi(int(floor(float(drawing_index) * count / float(maxi(1, nominal)))), 0, count - 1)
	_sprite.animation = state
	_sprite.frame = mapped
	_sprite.flip_h = facing < 0.0
	# Source motion drawings are packed tighter than the original idle/run atlas.
	_sprite.scale = Vector2.ONE if state == &"idle_ready" or state == &"run_forward" else Vector2(1.42, 1.42)
	_sprite.visible = true
	return true
