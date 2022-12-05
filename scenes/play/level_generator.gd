extends Node2D
class_name LevelGenerator

@onready var level: Level = $"../Level"
@onready var level_file: LevelFile = $"../LevelFile"


func _ready():
	generate_level()


func generate_level():
	for i in range(10):
		pass
		# level.set_tile(i, i, 'dirt')
