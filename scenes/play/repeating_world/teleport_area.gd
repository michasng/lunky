extends Area2D
class_name TeleportArea

@export var size: Vector2: set=set_size
@export var teleport_movement: Vector2

@onready var shape: CollisionShape2D = $CollisionShape2D


func set_size(value: Vector2):
	size = value
	var update_children = func():
		shape.shape = RectangleShape2D.new()
		shape.shape.size = size
		shape.position = size / 2
	update_children.call_deferred()


func _physics_process(_delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if contains_point(body.position):
			body.position += teleport_movement


func contains_point(point: Vector2) -> bool:
	var rect = Rect2(position, size)
	return rect.has_point(point)

