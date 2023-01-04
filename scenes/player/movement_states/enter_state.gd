extends MovementState
class_name EnterState

func get_transition() -> BaseState:
	if anim_handler.is_current_done_playing():
		return $"../StandState"
	return self

func enter_state(_previous_state: BaseState, _delta: float):
	anim_handler.travel('enter')

func exit_state(_next_state: BaseState, _delta: float):
	pass

func handle_physics(_delta: float):
	pass
