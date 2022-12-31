extends CharacterBody2D
class_name RopeBundle

@onready var level: Level = $"/root/Play/Level"
const rope_scene = preload("rope.tscn")

@export var speed: float = 0.3 * 60 * globals.tile_size
@export var throw_distance: float = 6 * globals.tile_size

var starting_position: Vector2


func throw(pos: Vector2):
	starting_position = pos
	position = pos
	velocity = Vector2(0, -speed)


func _physics_process(_delta: float):
	if get_slide_collision_count() > 0 or position.distance_to(starting_position) >= throw_distance:
		var rope: Rope = rope_scene.instantiate()
		get_parent().add_child(rope)
		rope.position = position
		rope.unroll()
		call_deferred("queue_free")
	
	move_and_slide()
