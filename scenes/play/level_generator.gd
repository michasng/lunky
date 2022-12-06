extends Node2D
class_name LevelGenerator

@onready var level: Level = $"../Level"
@onready var level_file: LevelFile = $"../LevelFile"

const grid_cell_size_tiles = Vector2i(10, 8)

var entrance_cell: Vector2i
var exit_cell: Vector2i
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
			var _template_types = _pick_template_types(previous_grid_coords, grid_coords)
			previous_grid_coords = grid_coords
			var template_type = _template_types.pick_random()
			var templates_of_type = level_file.templates[template_type]
			var template =  templates_of_type.pick_random()
			_place_template(template, grid_coords)


func _init_empty_grid():
	grid.resize(grid_size.y)
	for row in grid_size.y:
		grid[row] = []
		grid[row].resize(grid_size.x)
		for col in grid_size.x:
			grid[row][col] = Vector2i.ZERO


func _generate_critical_path():
	entrance_cell = Vector2i(randi_range(0, grid_size.x - 1), 0)
	
	var current_cell: Vector2i = entrance_cell
	var next_cell: Vector2i = current_cell
	while next_cell.y < grid_size.y:
		current_cell = next_cell
		var room_direction: Vector2i = _random_room_direction()
		next_cell = current_cell + room_direction
		if next_cell.x < 0 || next_cell.x >= grid_size.x:
			room_direction = Vector2i.DOWN
			next_cell = current_cell + room_direction
		grid[current_cell.y][current_cell.x] = room_direction
	exit_cell = current_cell


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
	if grid_coords == entrance_cell:
		if room_direction == Vector2i.DOWN:
			return ["entrance_drop"]
		return ["entrance", "entrance_drop"]
	if grid_coords == exit_cell:
		if previous_direction == Vector2i.DOWN:
			return ["exit_notop"]
		return ["exit", "exit_notop"]
	if room_direction == Vector2i.LEFT || Vector2i.RIGHT:
		if previous_direction == Vector2i.DOWN:
			return ["path_notop"]
		return ["path_normal"]
	if room_direction == Vector2i.DOWN:
		if previous_direction == Vector2i.DOWN:
			return ["path_drop_notop"]
		return ["path_drop"]
	return ["side"]


func _place_template(template: Dictionary, grid_coords: Vector2i):
	var cell_corner_tile_coords = grid_coords * grid_cell_size_tiles
	for row in grid_cell_size_tiles.y:
		for col in grid_cell_size_tiles.x:
			var tile_coords_in_cell = Vector2i(col, row)
			var tile_code = template["tiles"][row][col]
			if tile_code == "1":
				level.set_tile(cell_corner_tile_coords + tile_coords_in_cell, "floor")
