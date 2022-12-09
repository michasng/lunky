extends Node2D
class_name LevelGenerator

@onready var level: Level = $"../Level"
@onready var level_file: LevelFile = $"../LevelFile"

const room_size = Vector2i(10, 8)

var entrance_room: Vector2i
var exit_room: Vector2i
var grid_size: Vector2i
var grid: Array[Array] = [] # 2D matrix of Vector2i (no deeply nested types supported)
var rng = RandomNumberGenerator.new()


func _ready():
	grid_size = level_file.level_settings["size"]
	generate_level()


func generate_level():
	_init_empty_grid()
	_generate_critical_path()
	# print(level_file.templates.keys())
	var previous_grid_coords: Vector2i = Vector2i.ZERO
	for row in grid_size.y:
		for col in grid_size.x:
			var grid_coords = Vector2i(col, row)
			var room_corner_tile_coords = grid_coords * room_size
			var _template_types = _pick_template_types(previous_grid_coords, grid_coords)
			previous_grid_coords = grid_coords
			_place_template_type(_template_types.pick_random(), room_corner_tile_coords)


func _init_empty_grid():
	grid.resize(grid_size.y)
	for row in grid_size.y:
		grid[row] = []
		grid[row].resize(grid_size.x)
		for col in grid_size.x:
			grid[row][col] = Vector2i.ZERO


func _generate_critical_path():
	entrance_room = Vector2i(randi_range(0, grid_size.x - 1), 0)
	
	var current_room: Vector2i = entrance_room
	var next_room: Vector2i = current_room
	while next_room.y < grid_size.y:
		current_room = next_room
		var room_direction: Vector2i = _random_room_direction()
		next_room = current_room + room_direction
		if next_room.x < 0 || next_room.x >= grid_size.x:
			room_direction = Vector2i.DOWN
			next_room = current_room + room_direction
		grid[current_room.y][current_room.x] = room_direction
	exit_room = current_room


func _random_room_direction() -> Vector2i:
	match randi_range(0, 2):
		0:
			return Vector2i.DOWN
		1:
			return Vector2i.LEFT
		2:
			return Vector2i.RIGHT
	@warning_ignore(assert_always_false)
	assert(false, "unreachable code")
	return Vector2i.ZERO


func _pick_template_types(previous_grid_coords: Vector2i, grid_coords: Vector2i) -> Array[String]:
	var previous_direction = grid[previous_grid_coords.y][previous_grid_coords.x]
	var room_direction = grid[grid_coords.y][grid_coords.x]
	if grid_coords == entrance_room:
		if room_direction == Vector2i.DOWN:
			return ["entrance_drop"]
		return ["entrance", "entrance_drop"]
	if room_direction == Vector2i.LEFT || Vector2i.RIGHT:
		if previous_direction == Vector2i.DOWN:
			return ["path_notop"]
		return ["path_normal"]
	if room_direction == Vector2i.DOWN:
		if previous_direction == Vector2i.DOWN:
			return ["path_drop_notop"]
		return ["path_drop"]
	if grid_coords == exit_room:
		if previous_direction == Vector2i.DOWN:
			return ["exit_notop"]
		return ["exit", "exit_notop"]
	return ["side"]


func _place_template_type(template_type: String, croner_tile_coords: Vector2i):
	var templates_of_type = level_file.templates[template_type]
	var template = templates_of_type.pick_random()
	_place_template(template, croner_tile_coords)


func _place_template(template: Dictionary, croner_tile_coords: Vector2i):
	var tiles = template["tiles"]
	# TODO Fix: the size() also contains the background tiles
	for row in tiles.size():
		for col in tiles[row].size():
			var tile_coords_in_room = Vector2i(col, row)
			var tile_code = tiles[row][col]
			var tile = level_file.tile_codes[tile_code]
			if (tile["name"] as String).begins_with("chunk"):
				_place_template_type(tile["name"], croner_tile_coords + tile_coords_in_room)
			else:
				level.set_tile(
					croner_tile_coords + tile_coords_in_room,
					tile["name"],
					tile["chance"],
				)
