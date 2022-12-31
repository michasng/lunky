extends Node
class_name StateMachine

@onready var current_state: CharacterState = $"EnterState"
@onready var previous_state: CharacterState = current_state


func _ready():
	current_state.enter_state(previous_state, 0)


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

