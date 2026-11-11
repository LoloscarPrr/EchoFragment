class_name PortadorPoseVisual
extends PortadorFullRigV02

## Coherent whole-body pixel poses replace the mismatched v0.3 cutout drawing.
## Inherits the existing configure(state, progress, facing) gameplay contract.
## This is a pose library, not a finished skeletal rig or final animation set.
const ATLAS_PATH := "res://assets/player/portador_pixel_v04/poses.webp"
const MANIFEST_PATH := "res://assets/player/portador_pixel_v04/poses.json"
var _pose_sprite: Sprite2D
var _frames: Array = []
var _pose_clock := 0.0
var frame_index := 0

func _ready() -> void:
	demo_cycle = false
	if not ResourceLoader.exists(ATLAS_PATH) or not FileAccess.file_exists(MANIFEST_PATH):
		missing_files.append(ATLAS_PATH)
		return
	var metadata = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if not metadata is Dictionary or not metadata.get("frames") is Array:
		return
	_frames = metadata["frames"]
	if _frames.size() != 12:
		return
	_pose_sprite = Sprite2D.new()
	_pose_sprite.name = "PortadorPixelPoses"
	_pose_sprite.texture = load(ATLAS_PATH) as Texture2D
	_pose_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_pose_sprite.centered = false
	_pose_sprite.region_enabled = true
	_pose_sprite.region_filter_clip_enabled = true
	add_child(_pose_sprite)
	art_loaded = true
	_apply_pose()

func configure(new_state: StringName, progress: float, direction: float = 1.0) -> void:
	if state != new_state:
		_pose_clock = 0.0
	state = new_state
	state_progress = clampf(progress, 0.0, 1.0)
	facing = -1.0 if direction < 0.0 else 1.0
	_apply_pose()

func _process(delta: float) -> void:
	_pose_clock += delta
	_apply_pose()

func _apply_pose() -> void:
	if not art_loaded or not is_instance_valid(_pose_sprite):
		return
	frame_index = 0
	match state:
		&"run_forward": frame_index = 1 + int(_pose_clock * 10.0) % 4
		&"jump_start": frame_index = 5
		&"jump_rise": frame_index = 5
		&"jump_apex": frame_index = 6
		&"jump_fall": frame_index = 7
		&"land_light": frame_index = 7 if state_progress < 0.5 else 0
		&"attack_light":
			# Same startup / active / recovery phases as the 18-tick attack.
			if state_progress < float(TajoDelEcoTimeline.ACTIVE_START_TICK) / float(TajoDelEcoTimeline.ATTACK_TICKS):
				frame_index = 8
			elif state_progress < float(TajoDelEcoTimeline.ACTIVE_END_TICK + 1) / float(TajoDelEcoTimeline.ATTACK_TICKS):
				frame_index = 9
			else:
				frame_index = 10
		&"dodge": frame_index = 11
	var frame: Dictionary = _frames[frame_index]
	var region: Array = frame["region"]
	var pivot: Array = frame["pivot"]
	_pose_sprite.region_rect = Rect2(region[0], region[1], region[2], region[3])
	var draw_scale: float = float(frame["scale"])
	_pose_sprite.scale = Vector2(facing * draw_scale, draw_scale)
	_pose_sprite.position = Vector2(-float(pivot[0]) * draw_scale * facing, -float(pivot[1]) * draw_scale)
