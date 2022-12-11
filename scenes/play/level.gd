extends TileMap
class_name Level

@export var debug_logging: bool = false

@onready var h_borders: TileMap = $HBorders
@onready var v_borders: TileMap = $VBorders

enum TileMapLayers {
	BACKGROUND = 0,
	MAIN = 1,
	DECORATION = 2,
}

enum PhysicsLayers {
	SOLID = 0,
	PLATFORM = 1,
}

var map_size: Vector2i

# enum values correspond to atlas IDs
enum Atlas {
	MISC = 0,
	DWELLING = 1,
	WOOD = 2,
}

const ATLAS = "atlas"
const ATLAS_COORDS = "atlas_coords"
const BORDERS = "borders"
const BORDERS_TOP = "top"
const BORDERS_BOTTOM = "bottom"
const BORDERS_SIDE_TOP = "side_top"
const BORDERS_SIDE = "side"

const tiles: Dictionary = {
	'floor': {
		ATLAS: Atlas.DWELLING,
		ATLAS_COORDS: Vector2i(0, 0),
		BORDERS: {
			BORDERS_TOP: [Vector2i(5, 6), Vector2i(6, 6), Vector2i(7, 6)],
			BORDERS_BOTTOM: [Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7)],
			BORDERS_SIDE_TOP: [Vector2i(7, 5)],
			BORDERS_SIDE: [Vector2i(5, 5), Vector2i(6, 5)],
		},
	},
	'minewood_floor': {
		ATLAS: Atlas.WOOD,
		ATLAS_COORDS: Vector2i(7, 2),
	},
	'bone_block': {
		ATLAS: Atlas.DWELLING,
		ATLAS_COORDS: Vector2i(10, 2),
	},
	'spikes': {
		ATLAS: Atlas.DWELLING,
		ATLAS_COORDS: Vector2i(5, 9),
	},
	'push_block': {
		ATLAS: Atlas.DWELLING,
		ATLAS_COORDS: Vector2i(7, 0),
	},
	'ladder': {
		ATLAS: Atlas.DWELLING,
		ATLAS_COORDS: Vector2i(4, 1),
	},
	'ladder_plat': {
		ATLAS: Atlas.DWELLING,
		ATLAS_COORDS: Vector2i(4, 2),
	},
	'platform': {
		ATLAS: Atlas.MISC,
		ATLAS_COORDS: Vector2i(0, 1),
	},
}


func is_any_tile(coords: Vector2i):
	return get_cell_source_id(TileMapLayers.MAIN, coords) != -1


func is_solid_tile(coords: Vector2i):
	if not is_any_tile(coords):
		return false
	var tile_data = get_cell_tile_data(TileMapLayers.MAIN, coords)
	return tile_data.get_collision_polygons_count(PhysicsLayers.SOLID) > 0


func is_tile(tile: String, coords: Vector2i) -> bool:
	return get_cell_source_id(TileMapLayers.MAIN, coords) == tiles[tile][ATLAS] and \
		get_cell_atlas_coords(TileMapLayers.MAIN, coords) == tiles[tile][ATLAS_COORDS] 


func set_tile(coords: Vector2i, tile: String, chance_percent: int):
	if tile == "empty":
		return
	if chance_percent != 100 and randi_range(1, 100) > chance_percent:
		return
	if not tiles.has(tile):
		if debug_logging: print("unknown tile: ", tile)
		return
	set_cell(TileMapLayers.MAIN, coords, tiles[tile][ATLAS], tiles[tile][ATLAS_COORDS])


func for_each_tile(bounds: Vector2i, fn):
	for row in bounds.x:
		for col in bounds.y:
			fn.call(Vector2i(row, col))


func update_tile_borders(coords: Vector2i):
	if is_tile("floor", coords):
		var borders = tiles["floor"][BORDERS]
		var has_top_border = not is_tile("floor", coords + Vector2i.UP)
		if has_top_border:
			v_borders.set_cell(0, coords, Atlas.DWELLING, borders[BORDERS_TOP].pick_random())
		if not is_tile("floor", coords + Vector2i.DOWN):
			v_borders.set_cell(0, coords + Vector2i.DOWN, Atlas.DWELLING, borders[BORDERS_BOTTOM].pick_random())
		if not is_tile("floor", coords + Vector2i.LEFT):
			var left_border
			if has_top_border:
				left_border = borders[BORDERS_SIDE_TOP].pick_random()
			else:
				left_border = borders[BORDERS_SIDE].pick_random()
			h_borders.set_cell(0, coords, Atlas.DWELLING, left_border, 1)
		if not is_tile("floor", coords + Vector2i.RIGHT):
			var right_border
			if has_top_border:
				right_border = borders[BORDERS_SIDE_TOP].pick_random()
			else:
				right_border = borders[BORDERS_SIDE].pick_random()
			h_borders.set_cell(0, coords + Vector2i.RIGHT, Atlas.DWELLING, right_border)


func update_all_tile_borders():
	for_each_tile(map_size, update_tile_borders)


func decorate():
	update_all_tile_borders()
