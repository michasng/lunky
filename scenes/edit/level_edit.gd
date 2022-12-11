extends TileMap

enum DrawMode { DRAW, ERASE }

var draw_mode: DrawMode


func is_any_tile(coords: Vector2i):
	return get_cell_tile_data(0, coords) != null


func draw_tile(coords: Vector2i):
	if draw_mode == DrawMode.DRAW:
		set_cell(0, coords, 1, Vector2i(0, 0))
	elif draw_mode == DrawMode.ERASE:
		erase_cell(0, coords)


func _process(_delta: float):
	var tile_coords = local_to_map(get_viewport().get_mouse_position())
	if Input.is_action_just_pressed("mouse_left"):
		if is_any_tile(tile_coords):
			draw_mode = DrawMode.ERASE
		else:
			draw_mode = DrawMode.DRAW
	if Input.is_action_pressed("mouse_left"):
		draw_tile(tile_coords)
