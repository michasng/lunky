extends Node2D
class_name WorldProjection

@export var size: Vector2: set=set_size
@export var record_position: Vector2: set=set_record_position

@onready var viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var camera: Camera2D = $SubViewportContainer/SubViewport/Camera2D


func _ready():
	viewport.world_2d = get_viewport().world_2d


func set_size(value: Vector2):
	size = value
	var update_children = func():
		viewport.size = value
	update_children.call_deferred()


func set_record_position(value: Vector2):
	record_position = value
	var update_children = func():
		camera.position = value
	update_children.call_deferred()

