extends CharacterBody2D
class_name Player

const rope_bundle_scene = preload("rope/rope_bundle.tscn")
const rope_scene = preload("rope/rope.tscn")
@onready var hit_box: Vector2 = $"HitBox".shape.get_rect().size

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

@onready var current_state: CharacterState = $"States/EnterState"
@onready var previous_state: CharacterState = current_state

const LEFT = -1
const RIGHT = 1
var view_dir = 0
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
	
	if Input.is_action_just_pressed("rope"):
		if Input.is_action_pressed("move_down"):
			drop_rope()
		else:
			throw_rope()


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


func drop_rope():
	var rope = rope_scene.instantiate()
	get_parent().add_child(rope)
	rope.position = position + Vector2(view_dir * pixel_per_meter, pixel_per_meter)
	rope.call_deferred("unroll")


func center_on_tile_horizontally():
	position.x = floor(position.x / pixel_per_meter) * pixel_per_meter + pixel_per_meter / 2

