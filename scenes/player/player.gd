extends CharacterBody2D
class_name Player

const rope_bundle_scene = preload("rope/rope_bundle.tscn")
const rope_scene = preload("rope/rope.tscn")
@export var level: Level
@onready var movement_state_machine: StateMachine = $"MovementStateMachine"
@onready var attack_state_machine: StateMachine = $"AttackStateMachine"
@onready var collision_shape: CollisionShape2D = $"CollisionShape2D"
@onready var hit_box: Vector2 = collision_shape.shape.get_rect().size
@onready var hit_box_crouch: Vector2 = Vector2(hit_box.x, 64)
@onready var sprite: Sprite2D = $"Sprite2D"
@onready var anim_playback: AnimationNodeStateMachinePlayback = $"AnimationTree".get("parameters/playback")
@onready var tile_above: RayCast2D = $"TileAbove"
@onready var tile_above_default_target_pos: Vector2i = tile_above.target_position
@onready var tile_in_front: RayCast2D = $"TileInFront"
@onready var tile_in_front_default_target_pos: Vector2i = tile_in_front.target_position
@onready var tile_below_center: RayCast2D = $"TileBelowCenter"
@onready var tile_below_back: RayCast2D = $"TileBelowBack"
@onready var tile_below_back_default_pos: Vector2i = tile_below_back.position

# values taken from the real game
@export var friction: float = 0.015 * globals.tile_size * globals.physics_fps
@export var acceleration: float = 0.032 * globals.tile_size * pow(globals.physics_fps, 2)
@export var max_speed: float = 0.0725 * globals.tile_size * globals.physics_fps
@export var sprint_factor: float = 2
@export var jump_power: float = 0.18 * globals.tile_size * pow(globals.physics_fps, 2)
# @export var gravity: float = 0.01 * globals.tile_size * pow(globals.physics_fps, 2)

# there may be a way to calculate this from the other values
@export var crawl_speed: float = 0.029 * globals.tile_size * globals.physics_fps

@export var debug_logging: bool = false

const LEFT = -1
const RIGHT = 1
var view_dir: int = 0
var rope_contacts: Array = []


func _ready():
	movement_state_machine.set_state(movement_state_machine.get_node("EnterState"))
	attack_state_machine.set_state(attack_state_machine.get_node("IdleAttackState"))


func _physics_process(_delta: float):
	if debug_logging and velocity != Vector2.ZERO:
		print(
			"vel: " , velocity / globals.physics_fps / globals.tile_size,
			" pos: ", position / globals.tile_size
		)


func apply_velocity():
	velocity = Vector2(
		clampf(velocity.x, -globals.linear_speed_limit, globals.linear_speed_limit),
		clampf(velocity.y, -globals.linear_speed_limit, globals.linear_speed_limit)
	)
	move_and_slide()


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
	position.x = floor(position.x / globals.tile_size) * globals.tile_size + globals.tile_size / 2


func handle_turn(turn_dir: int):
	if view_dir == turn_dir:
		return
	view_dir = turn_dir
	sprite.flip_h = turn_dir < 0
	tile_above.target_position = view_dir * tile_above_default_target_pos
	tile_in_front.target_position = view_dir * tile_in_front_default_target_pos
	tile_below_back.position = view_dir * tile_below_back_default_pos
