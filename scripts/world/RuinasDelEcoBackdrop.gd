extends Node2D
## First playable art pass from the approved gothic mockup.
## One environment plate, mirrored at tile boundaries; no painted HUD or actors.
## Collision and actors remain in Main. Later passes can split distant layers.
const PLATE: Texture2D = preload("res://assets/world/ruinas_del_eco/environment_plate_v1.webp")
const TILE_WIDTH := 1635.0
const PLATE_HEIGHT := 920.0
const WALK_SURFACE := 0.695
const GROUND_Y := 640.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _draw() -> void:
	# Main's floor collider is centered on y=680 with a height of 80.
	# Align the painted bridge to its TOP (640), not its center.
	var top := GROUND_Y - PLATE_HEIGHT * WALK_SURFACE
	for tile in range(3):
		var left := float(tile) * TILE_WIDTH
		if tile % 2 == 1:
			draw_texture_rect(PLATE, Rect2(left + TILE_WIDTH, top, -TILE_WIDTH, PLATE_HEIGHT), false)
		else:
			draw_texture_rect(PLATE, Rect2(left, top, TILE_WIDTH, PLATE_HEIGHT), false)
