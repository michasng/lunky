extends Node
class_name StateMachine

var current_state: BaseState
var previous_state: BaseState


func _physics_process(delta: float):
	if not current_state:
		return

	# first transition then physics for responsiveness
	var next_state = current_state.get_transition()
	if next_state != current_state:
		set_state(next_state, delta)

	current_state.frame_count += 1
	current_state.handle_physics(delta)


func set_state(next_state: BaseState, delta: float = 0.0):
	# print(state_names[next_state])
	previous_state = current_state
	current_state = next_state
	if previous_state:
		previous_state.exit_state(current_state, delta)
	if current_state:
		current_state.enter_state(previous_state, delta)
	current_state.frame_count = 0

