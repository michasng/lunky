extends Node
class_name BaseState

var frame_count: int = 0

func get_transition() -> BaseState:
	return self

func enter_state(_previous_state: BaseState, _delta: float):
	pass

func exit_state(_next_state: BaseState, _delta: float):
	pass

func handle_physics(_delta: float):
	pass
