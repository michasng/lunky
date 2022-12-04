extends Node2D
class_name Rope

@onready var level: Level = $"/root/Play/Level"
@onready var collision_shape: CollisionShape2D = $"Area2D/CollisionShape2D"
const rope_anchor_scene = preload("rope_anchor.tscn")
const rope_segment_scene = preload("rope_segment.tscn")
var pixel_per_meter = ProjectSettings.get_setting("global/pixel_per_meter")

@export var max_rope_segments = 6
@export var touch_force = 100

var _width: float
var _segments: Array[PhysicsBody2D] = []


func _ready():
	_width = collision_shape.shape.get_rect().size.x


func unroll():
	# center the rope on the tile
	var tile: Vector2i = level.local_to_map(position)
	var tile_center: Vector2 = level.map_to_local(tile)
	position = tile_center
	spawn_segment(rope_anchor_scene, Vector2.ZERO)
	$StaticBody2D/PinJoint2D.node_b = _segments.back().get_path()
	


func _on_segment_unrolled():
	_update_collision_shape()
	if _segments.size() < max_rope_segments:
		var previous_segment = _segments.back()
		var segment = spawn_segment(rope_segment_scene, Vector2(0, _segments.size() * pixel_per_meter))
		if segment:
			var pin_joint = PinJoint2D.new()
			# add joint to the bottom of the previous segment
			previous_segment.add_child(pin_joint)
			pin_joint.position = Vector2(0, pixel_per_meter / 2)
			pin_joint.node_a = previous_segment.get_path()
			pin_joint.node_b = segment.get_path()


func spawn_segment(segment_scene, relative_position: Vector2) -> PhysicsBody2D:
	var tile_coords: Vector2i = level.local_to_map(relative_position + position)
	if level.is_tile(tile_coords):
		return
	var segment = segment_scene.instantiate()
	_segments.append(segment)
	add_child(segment)
	segment.position = relative_position
	var next_tile_coords = tile_coords + Vector2i(0, 1)
	segment.unroll(_segments.size() >= max_rope_segments or level.is_tile(next_tile_coords))
	segment.connect("unrolled", _on_segment_unrolled)
	return segment


func _update_collision_shape():
	var height = _segments.size() * pixel_per_meter
	# create a new shape, so ropes are independent of each other
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(_width, height)
	collision_shape.position = Vector2(0, height / 2 - pixel_per_meter / 2)


func _on_body_entered(body: PhysicsBody2D):
	if body is Player:
		body.rope_contacts.append(self)
		var direction = sign(position.x - body.position.x)
		for segment in _segments:
			if segment is RigidBody2D:
				segment.apply_force(Vector2(direction * touch_force, 0), body.position)


func _on_body_exited(body: PhysicsBody2D):
	if body is Player:
		body.rope_contacts.erase(self)

