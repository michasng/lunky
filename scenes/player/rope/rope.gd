extends Node2D
class_name Rope

@onready var level: Level = $"/root/Play/Level"
@onready var collision_shape: CollisionShape2D = $"Area2D/CollisionShape2D"
const rope_anchor_scene = preload("rope_anchor.tscn")
const rope_segment_scene = preload("rope_segment.tscn")
var pixel_per_meter = ProjectSettings.get_setting("global/pixel_per_meter")

@export var max_rope_segments = 6

var segment_count: int = 0
var _width: float

func _ready():
	_width = collision_shape.shape.get_rect().size.x

func unroll():
	# center the rope on the tile
	var tile: Vector2i = level.local_to_map(position)
	var tile_center: Vector2 = level.map_to_local(tile)
	position = tile_center
	spawn_segment(rope_anchor_scene, Vector2.ZERO)


func _on_segment_unrolled():
	_update_collision_shape()
	if segment_count < max_rope_segments:
		spawn_segment(rope_segment_scene, Vector2(0, segment_count * pixel_per_meter))


func spawn_segment(segment_scene, relative_position: Vector2):
	var tile_coords: Vector2i = level.local_to_map(relative_position + position)
	if level.is_tile(tile_coords):
		return
	segment_count += 1
	var segment = segment_scene.instantiate()
	add_child(segment)
	segment.position = relative_position
	var next_tile_coords = tile_coords + Vector2i(0, 1)
	segment.unroll(segment_count >= max_rope_segments or level.is_tile(next_tile_coords))
	segment.connect("unrolled", _on_segment_unrolled)


func _update_collision_shape():
	var height = segment_count * pixel_per_meter
	# create a new shape, so ropes are independent of each other
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(_width, height)
	collision_shape.position = Vector2(0, height / 2 - pixel_per_meter / 2)


func _on_body_entered(body: PhysicsBody2D):
	if body is Player:
		body.rope_contacts.append(self)


func _on_body_exited(body: PhysicsBody2D):
	if body is Player:
		body.rope_contacts.erase(self)
