extends CharacterBody2D
class_name Player

var pixel_per_meter = ProjectSettings.get_setting("global/pixel_per_meter")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# values taken from the real game
var spelunky2_fps = 60 # number of physics calculations per second, actually
var friction: float = 0.015 * spelunky2_fps * pixel_per_meter
var acceleration: float = 0.032 * pow(spelunky2_fps, 2) * pixel_per_meter
var max_speed: float = 0.0725 * spelunky2_fps * pixel_per_meter
var sprint_factor: float = 2
var jump_power: float = 0.18 * pow(spelunky2_fps, 2) * pixel_per_meter
# var gravity: float = 0.01 * pow(spelunky2_fps, 2) * pixel_per_meter

@onready var current_state: CharacterState = $"States/EnterState"
@onready var previous_state: CharacterState = current_state

const LEFT = -1
const RIGHT = 1
var view_dir = 0

func _physics_process(delta: float):
	# first transition then physics for responsiveness
	var next_state = current_state.get_transition()
	if next_state != current_state:
		set_state(next_state, delta)

	current_state.frame_count += 1
	current_state.handle_physics(delta)

func set_state(next_state: CharacterState, delta: float):
	# print(state_names[next_state])
	previous_state = current_state
	current_state = next_state
	previous_state.exit_state(current_state, delta)
	current_state.enter_state(previous_state, delta)
	current_state.frame_count = 0
