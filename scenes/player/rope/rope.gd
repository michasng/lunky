extends Node2D
class_name Rope

@onready var level: Level = $"/root/Play/Level"
const rope_anchor_scene = preload("rope_anchor.tscn")
const rope_segment_scene = preload("rope_segment.tscn")
var pixel_per_meter = ProjectSettings.get_setting("global/pixel_per_meter")

@export var max_rope_segments = 8

var segment_count: int = 0

func unroll():
	# center the rope on the tile
	var tile: Vector2i = level.local_to_map(position)
	var tile_center: Vector2 = level.map_to_local(tile)
	position = tile_center
	spawn_segment(rope_anchor_scene, Vector2.ZERO)


func _on_segment_unrolled():
	if segment_count < max_rope_segments:
		spawn_segment(rope_segment_scene, Vector2(0, segment_count * pixel_per_meter))


func spawn_segment(segment_scene, relative_position: Vector2) -> RopeSegment:
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
	return segment
