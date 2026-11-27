class_name BowApprovedFrames
extends Sprite2D

# The two 3x3 illustrations approved by the player, nine cells per atlas.
# Optional while migrating assets: keep the old Portador art as fallback
# when combo.png and charged.png have not yet been committed to the project.
const COMBO := "res://assets/player/portador_bow_v054/combo.png"
const CHARGED := "res://assets/player/portador_bow_v054/charged.png"
const CELL := 448
const ART_SCALE := 0.62

var is_loaded := false
var _combo_tex: Texture2D
var _charge_tex: Texture2D
var last_frame := -1
var last_sheet := ""

func _ready() -> void:
	is_loaded = ResourceLoader.exists(COMBO) and ResourceLoader.exists(CHARGED)
	if not is_loaded:
		visible = false
		return
	_combo_tex = load(COMBO) as Texture2D
	_charge_tex = load(CHARGED) as Texture2D
	is_loaded = _combo_tex != null and _charge_tex != null
	visible = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	centered = false
	region_enabled = true
	region_filter_clip_enabled = true

func update_bow(state: StringName, progress: float, facing: float, charge: float) -> void:
	if not is_loaded:
		visible = false
		return
	var index := 0
	var sheet := "combo"
	var p := clampf(progress, 0.0, 1.0)
	var tension := clampf(charge, 0.0, 1.0)
	match state:
		&"idle_ready":
			index = 0
		&"run_forward":
			index = 1 # Approved step-forward pose. Later frames can extend this.
		&"bow_punch":
			index = 2 if p < 0.33 else (3 if p < 0.72 else 4)
		&"bow_kick":
			index = 5 if p < 0.55 else 6
		&"bow_shot":
			if tension >= 0.25:
				sheet = "charged"
				index = 7 if p < 0.48 else 8
			else:
				index = 7 if p < 0.50 else 8
		&"bow_draw":
			sheet = "charged"
			index = clampi(1 + int(tension * 6.9), 1, 7)
		&"jump_start", &"jump_rise", &"jump_apex", &"jump_fall":
			index = 1
		&"dodge":
			index = 1
		&"hit_light":
			index = 0
		_:
			index = 0
	texture = _charge_tex if sheet == "charged" else _combo_tex
	region_rect = Rect2((index % 3) * CELL, int(index / 3) * CELL, CELL, CELL)
	scale = Vector2(( -ART_SCALE if facing < 0.0 else ART_SCALE), ART_SCALE)
	# Body alignment is stable even when an arrow trail expands to the right.
	# The character stays centered on x=224; boots align to y=400.
	position = Vector2(-224.0 * scale.x, -400.0 * ART_SCALE)
	last_frame = index
	last_sheet = sheet
	visible = true
