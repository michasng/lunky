extends Node2D
class_name LevelGenerator

@onready var level: Level = $"../Level"
@onready var level_file: LevelFile = $"../LevelFile"
var pixel_per_meter = ProjectSettings.get_setting("global/pixel_per_meter")

@export var debug_labels: bool = false
@export var debug_logging: bool = false

const room_size = Vector2i(10, 8)

var entrance_room: Vector2i
var exit_room: Vector2i
var grid_size: Vector2i
# 2D matrixes of Vector2i (no deeply nested types supported)
var room_exits: Array[Array] = [] # direction, each room leads to
var room_entrances: Array[Array] = [] # direction, each room was entered from
var rng = RandomNumberGenerator.new()


func _ready():
	grid_size = level_file.level_settings["size"]
	generate_level()


func generate_level():
	_init_empty_grid()
	_generate_critical_path()
	for row in grid_size.y:
		for col in grid_size.x:
			var grid_coords = Vector2i(col, row)
			var _template_types = _valid_template_types(grid_coords)
			_place_template_type(_template_types.pick_random(), grid_coords * room_size)


func _init_empty_grid():
	room_exits.resize(grid_size.y)
	for row in grid_size.y:
		room_exits[row] = []
		room_exits[row].resize(grid_size.x)
		for col in grid_size.x:
			room_exits[row][col] = Vector2i.ZERO
	room_entrances = room_exits.duplicate(true)


func _generate_critical_path():
	entrance_room = Vector2i(randi_range(0, grid_size.x - 1), 0)
	
	var previous_room: Vector2i = entrance_room
	var previous_room_direction: Vector2i = Vector2.ZERO
	while (previous_room + previous_room_direction).y < grid_size.y:
		var current_room = previous_room + previous_room_direction
		var possible_directions = [Vector2i.DOWN]
		if previous_room_direction != Vector2i.LEFT and current_room.x < grid_size.x - 1:
			possible_directions.append(Vector2i.RIGHT)
		if previous_room_direction != Vector2i.RIGHT and current_room.x > 0:
			possible_directions.append(Vector2i.LEFT)
		var room_direction: Vector2i = possible_directions.pick_random()
		room_entrances[current_room.y][current_room.x] = previous_room_direction
		room_exits[current_room.y][current_room.x] = room_direction
		if debug_logging:
			print("enter: ", previous_room_direction, ", exit: ", room_direction)
		previous_room = current_room
		previous_room_direction = room_direction
	exit_room = previous_room


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


func _valid_template_types(room: Vector2i) -> Array[String]:
	var previous_room_direction = room_entrances[room.y][room.x]
	var room_direction = room_exits[room.y][room.x]
	_spawn_label_at_tile(str(previous_room_direction) + ", " + str(room_direction), room * room_size + room_size / 2)
	# order is important, entrance and exit need to be checked first
	if room == entrance_room:
		if room_direction == Vector2i.DOWN:
			return ["entrance_drop"]
		return ["entrance", "entrance_drop"]
	if room == exit_room:
		if previous_room_direction == Vector2i.DOWN:
			return ["exit_notop"]
		return ["exit", "exit_notop"]
	if room_direction == Vector2i.LEFT || room_direction == Vector2i.RIGHT:
		if previous_room_direction == Vector2i.DOWN:
			return ["path_notop"]
		return ["path_normal"]
	if room_direction == Vector2i.DOWN:
		if previous_room_direction == Vector2i.DOWN:
			return ["path_drop_notop"]
		return ["path_drop"]
	return ["side"]


func _spawn_label_at_tile(text: String, tile_coords: Vector2i):
	if debug_labels:
		var label = Label.new()
		label.text = text
		label.position = tile_coords * pixel_per_meter
		label.label_settings = LabelSettings.new()
		label.label_settings.font_size = 48
		label.z_index = 1 # show in front of the level
		add_child(label)


func _place_template_type(template_type: String, croner_tile_coords: Vector2i):
	var templates_of_type = level_file.templates[template_type]
	templates_of_type = templates_of_type.filter(
		func(template):
			return not (template['settings'] as Array).has("ignore")
	)
	var template = templates_of_type.pick_random()
	_place_template(template, croner_tile_coords)
	_spawn_label_at_tile(template_type, croner_tile_coords)


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
