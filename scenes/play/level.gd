extends TileMap
class_name Level

enum atlas {
	DWELLING = 1,
}

const tiles: Dictionary = {
	'floor': [atlas.DWELLING, Vector2i(0, 0)],
}


func is_tile(coords: Vector2i):
	return get_cell_source_id(0, coords) != -1


func set_tile(coords: Vector2i, tile: String):
	if tile == "empty":
		return
	if not tiles.has(tile):
		print("unknown tile: ", tile)
		return
	set_cell(0, coords, tiles[tile][0], tiles[tile][1])


# func print_level():
# get_used_rect()
