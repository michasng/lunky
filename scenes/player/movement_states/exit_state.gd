extends MovementState
class_name ExitState

func get_transition() -> BaseState:
	return self

func enter_state(_previous_state: BaseState, _delta: float):
	anim_handler.travel('exit')

func exit_state(_next_state: BaseState, _delta: float):
	pass

func handle_physics(_delta: float):
	pass
