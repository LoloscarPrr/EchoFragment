extends SceneTree

func _initialize() -> void:
	# Regression for the blank 2nd background tile seen on Android.
	var source := FileAccess.get_file_as_string("res://scripts/world/RuinasDelEcoBackdrop.gd")
	assert(not source.is_empty())
	assert(source.contains("draw_set_transform(Vector2(left + TILE_WIDTH"))
	assert(source.contains("Vector2(-1.0, 1.0)"))
	assert(source.contains("Rect2(0.0, top, TILE_WIDTH, PLATE_HEIGHT)"))
	assert(not source.contains("-TILE_WIDTH, PLATE_HEIGHT"))

	var backdrop_script = load("res://scripts/world/RuinasDelEcoBackdrop.gd")
	assert(backdrop_script != null)
	var plate = backdrop_script.new()
	assert(plate.PLATE != null)
	assert(plate.PLATE.get_width() > 1000)
	var world_length := 4200.0
	var tile_length: float = plate.TILE_WIDTH
	for index in range(3):
		var left := float(index) * tile_length
		var right := left + tile_length
		assert(right > left)
		if index > 0:
			assert(is_equal_approx(left, float(index - 1) * tile_length + tile_length))
	assert(3.0 * tile_length >= world_length)
	plate.free()
	print("RuinasDelEco tiles cover the entire stage without negative-width draw rectangles")
	quit(0)
