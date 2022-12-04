extends TileMap
class_name Level

enum atlas {
	DWELLING = 1,
}

const tiles = {
	'dirt': [atlas.DWELLING, Vector2i(0, 0)],
}


func set_tile(col: int, row: int, tile: String):
	set_cell(0, Vector2i(col, row), tiles[tile][0], tiles[tile][1])


# func print_level():
# get_used_rect()