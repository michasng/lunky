extends TileMap
class_name Level

@export var debug_logging: bool = false

# enum values correspond to atlas IDs
enum atlas {
	MISC = 0,
	DWELLING = 1,
	WOOD = 2,
}

const tiles: Dictionary = {
	'floor': [atlas.DWELLING, Vector2i(0, 0)],
	'minewood_floor': [atlas.WOOD, Vector2i(7, 2)],
	'bone_block': [atlas.DWELLING, Vector2i(10, 2)],
	'spikes': [atlas.DWELLING, Vector2i(5, 9)],
	'push_block': [atlas.DWELLING, Vector2i(7, 0)],
	'ladder': [atlas.DWELLING, Vector2i(4, 1)],
	'ladder_plat': [atlas.DWELLING, Vector2i(4, 2)],
	'platform': [atlas.MISC, Vector2i(0, 1)],
}


func is_tile(coords: Vector2i):
	return get_cell_source_id(0, coords) != -1


func set_tile(coords: Vector2i, tile: String, chance_percent: int):
	if tile == "empty":
		return
	if chance_percent != 100 and randi_range(1, 100) > chance_percent:
		return
	if not tiles.has(tile):
		if debug_logging: print("unknown tile: ", tile)
		return
	set_cell(0, coords, tiles[tile][0], tiles[tile][1])


# func print_level():
# get_used_rect()
