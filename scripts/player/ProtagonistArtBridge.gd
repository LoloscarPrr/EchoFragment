class_name ProtagonistArtBridge
extends Node2D

## P0.3 sprite stabilizer. The source sheets are prototypes with very tight
## 88/96-pixel cells: attack glows and sword tips used to touch cell borders.
## Create generously padded, root-aligned frames at load time instead of
## displaying clipped AtlasTexture regions. This never changes collision.
const IDLE_RUN_ATLAS := "res://assets/characters/portador_eco/portador_idle_run_atlas.png"
const MOTION_ATLAS := "res://assets/characters/portador_eco/portador_p0_motion_atlas.png"
const IDLE_RUN_CELL := Vector2i(88, 94)
const MOTION_CELL := Vector2i(96, 86)
const OUTPUT_CELL := Vector2i(160, 140)
const ROOT_FOOT := Vector2i(80, 108)

const IDLE_RUN_RANGES := {
	&"idle_ready": Vector2i(0, 2),
	&"run_forward": Vector2i(2, 3)
}
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
## Per-drawing approximate anatomical root (not the alpha bounding box).
## The attack energy is deliberately NOT included in this anchor.
const IDLE_RUN_FEET := [
	Vector2i(50, 83), Vector2i(42, 83), Vector2i(42, 82),
	Vector2i(48, 79), Vector2i(49, 78)
]
const MOTION_FEET := [
	Vector2i(41, 76), Vector2i(49, 74), Vector2i(44, 65),
	Vector2i(45, 71), Vector2i(43, 76), Vector2i(42, 80),
	Vector2i(36, 80), Vector2i(34, 80), Vector2i(43, 80),
	Vector2i(33, 80)
]

var has_art := false
var _sprite: AnimatedSprite2D
var _active_state: StringName = &""
var _active_frame := -1
var _facing := 1.0

func _ready() -> void:
	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	_import_sheet(frames, IDLE_RUN_ATLAS, IDLE_RUN_CELL, 5, IDLE_RUN_RANGES, IDLE_RUN_FEET)
	_import_sheet(frames, MOTION_ATLAS, MOTION_CELL, 5, MOTION_RANGES, MOTION_FEET)
	if frames.get_animation_names().is_empty():
		return
	_sprite = AnimatedSprite2D.new()
	_sprite.name = "P0ArtSprite"
	_sprite.sprite_frames = frames
	_sprite.centered = true
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.visible = false
	add_child(_sprite)
	has_art = true

func _import_sheet(frames: SpriteFrames, path: String, cell: Vector2i, columns: int, ranges: Dictionary, feet: Array) -> void:
	if not ResourceLoader.exists(path):
		return
	var texture := load(path) as Texture2D
	if texture == null:
		push_warning("EchoFragment P0.3: unsupported atlas: " + path)
		return
	var source := texture.get_image()
	if source == null:
		push_warning("EchoFragment P0.3: no image bytes in " + path)
		return
	source.convert(Image.FORMAT_RGBA8)
	for key in ranges.keys():
		var state: StringName = key
		var part: Vector2i = ranges[key]
		var last_index: int = part.x + part.y - 1
		if last_index < 0 or last_index >= feet.size():
			push_warning("EchoFragment P0.3: missing pose root in " + path)
			continue
		var needed_rows: int = (last_index / columns) + 1
		if source.get_width() < columns * cell.x or source.get_height() < needed_rows * cell.y:
			push_warning("EchoFragment P0.3: truncated atlas: " + path)
			continue
		frames.add_animation(state)
		frames.set_animation_loop(state, state == &"idle_ready" or state == &"run_forward" or state == &"jump_rise" or state == &"jump_fall")
		frames.set_animation_speed(state, 10.0)
		for i in range(part.y):
			var index: int = part.x + i
			var source_corner := Vector2i((index % columns) * cell.x, (index / columns) * cell.y)
			var frame := Image.create(OUTPUT_CELL.x, OUTPUT_CELL.y, false, Image.FORMAT_RGBA8)
			frame.fill(Color.TRANSPARENT)
			var destination: Vector2i = ROOT_FOOT - feet[index]
			frame.blit_rect(source, Rect2i(source_corner, cell), destination)
			var frame_texture := ImageTexture.create_from_image(frame)
			frames.add_frame(state, frame_texture)

## Sprite layout is slightly different across the source pilot atlases.
## Use consistent world feet for all frames while preserving legible stature.
func configure(state: StringName, drawing_index: int, facing: float) -> bool:
	if not has_art or not is_instance_valid(_sprite):
		return false
	var frames := _sprite.sprite_frames
	if not frames.has_animation(state):
		_sprite.visible = false
		_set_active(&"", -1, facing)
		return false
	var count: int = frames.get_frame_count(state)
	if count <= 0:
		_sprite.visible = false
		_set_active(&"", -1, facing)
		return false
	var nominal: int = int(P0FrameLibrary.FRAME_COUNTS.get(state, count))
	var mapped: int = clampi(int(floor(float(drawing_index) * count / float(maxi(1, nominal)))), 0, count - 1)
	_sprite.animation = state
	_sprite.frame = mapped
	_sprite.flip_h = facing < 0.0
	if state == &"idle_ready" or state == &"run_forward":
		_sprite.scale = Vector2.ONE * 1.16
		_sprite.offset = Vector2.ZERO
	else:
		_sprite.scale = Vector2.ONE * 1.43
		_sprite.offset = Vector2(0.0, -8.0)
	_sprite.visible = true
	_set_active(state, mapped, facing)
	return true

func _set_active(state: StringName, frame: int, facing: float) -> void:
	var new_facing := -1.0 if facing < 0.0 else 1.0
	if _active_state == state and _active_frame == frame and _facing == new_facing:
		return
	_active_state = state
	_active_frame = frame
	_facing = new_facing
	queue_redraw()

func _draw() -> void:
	# The attack slash is drawn outside the sprite frame, deliberately.
	# It should never be clipped by the source atlas or sheet-cell borders.
	if _active_state != &"attack_light" or _active_frame != 1:
		return
	var trail := PackedVector2Array()
	for step in range(27):
		var theta := lerpf(-1.05, 0.90, float(step) / 26.0)
		trail.append(Vector2(9.0 + cos(theta) * 81.0 * _facing, -12.0 + sin(theta) * 74.0))
	draw_polyline(trail, Color(0.88, 0.06, 0.12, 0.18), 15.0, true)
	draw_polyline(trail, Color(0.95, 0.12, 0.19, 0.55), 6.0, true)
	draw_polyline(trail, Color(1.0, 0.55, 0.55, 0.42), 2.0, true)
