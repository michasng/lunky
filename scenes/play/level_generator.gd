extends Node2D
class_name LevelGenerator

@export var level: Level


func _ready():
	generate_level()


func generate_level():
	for i in range(10):
		pass
		# level.set_tile(i, i, 'dirt')
