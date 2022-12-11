extends CharacterBody2D
class_name Player

const rope_bundle_scene = preload("rope/rope_bundle.tscn")
const rope_scene = preload("rope/rope.tscn")
@onready var level: Level = $"/root/Play/Level"
@onready var collision_shape: CollisionShape2D = $"CollisionShape2D"
@onready var hit_box: Vector2 = collision_shape.shape.get_rect().size
@onready var hit_box_crouch: Vector2 = Vector2(hit_box.x, 64)
@onready var sprite: Sprite2D = $"Sprite2D"
@onready var tile_above: RayCast2D = $"TileAbove"
@onready var tile_above_default_target_pos: Vector2i = tile_above.target_position
@onready var tile_in_front: RayCast2D = $"TileInFront"
@onready var tile_in_front_default_target_pos: Vector2i = tile_in_front.target_position
@onready var tile_below_center: RayCast2D = $"TileBelowCenter"
@onready var tile_below_back: RayCast2D = $"TileBelowBack"
@onready var tile_below_back_default_pos: Vector2i = tile_below_back.position

var pixel_per_meter = ProjectSettings.get_setting("global/pixel_per_meter")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# values taken from the real game
@export var spelunky2_fps = 60 # number of physics calculations per second, actually
@export var friction: float = 0.015 * spelunky2_fps * pixel_per_meter
@export var acceleration: float = 0.032 * pow(spelunky2_fps, 2) * pixel_per_meter
@export var max_speed: float = 0.0725 * spelunky2_fps * pixel_per_meter
@export var sprint_factor: float = 2
@export var jump_power: float = 0.18 * pow(spelunky2_fps, 2) * pixel_per_meter
# @export var gravity: float = 0.01 * pow(spelunky2_fps, 2) * pixel_per_meter

# there may be a way to calculate this from the other values
@export var crawl_speed: float = 0.029 * spelunky2_fps * pixel_per_meter

@export var debug_logging: bool = false

@onready var current_state: CharacterState = $"States/EnterState"
@onready var previous_state: CharacterState = current_state

const LEFT = -1
const RIGHT = 1
var view_dir: int = 0
var rope_contacts: Array = []


func _ready():
	current_state.enter_state(previous_state, 0)


func _physics_process(delta: float):
	# first transition then physics for responsiveness
	var next_state = current_state.get_transition()
	if next_state != current_state:
		set_state(next_state, delta)

	current_state.frame_count += 1
	current_state.handle_physics(delta)
	
	if debug_logging and velocity != Vector2.ZERO:
		print(
			"vel: " , velocity / spelunky2_fps / pixel_per_meter,
			" pos: ", position / pixel_per_meter
		)


func set_state(next_state: CharacterState, delta: float):
	# print(state_names[next_state])
	previous_state = current_state
	current_state = next_state
	previous_state.exit_state(current_state, delta)
	current_state.enter_state(previous_state, delta)
	current_state.frame_count = 0


func throw_rope():
	var rope_bundle = rope_bundle_scene.instantiate()
	get_parent().add_child(rope_bundle)
	rope_bundle.throw(position - Vector2(0, hit_box.y / 2))


func drop_rope(offset: Vector2):
	var rope = rope_scene.instantiate()
	get_parent().add_child(rope)
	var tile = level.local_to_map(get_center())
	var origin = level.map_to_local(tile)
	rope.position = origin + offset * Vector2(view_dir, 1)
	rope.unroll()


func can_climb_ladder() -> bool:
	var tile = level.local_to_map(get_center())
	return level.is_ladder(tile)


func can_climb_rope() -> bool:
	return not rope_contacts.is_empty()


func is_on_platform() -> bool:
	var tile = level.local_to_map(get_center())
	var tile_below = tile + Vector2i.DOWN
	return level.is_platform(tile_below)


func get_center() -> Vector2:
	return position - Vector2(0, hit_box.y / 2)


func center_on_tile_horizontally():
	position.x = floor(position.x / pixel_per_meter) * pixel_per_meter + pixel_per_meter / 2


func handle_turn(turn_dir: int):
	if view_dir == turn_dir:
		return
	view_dir = turn_dir
	sprite.flip_h = turn_dir < 0
	tile_above.target_position = view_dir * tile_above_default_target_pos
	tile_in_front.target_position = view_dir * tile_in_front_default_target_pos
	tile_below_back.position = view_dir * tile_below_back_default_pos
