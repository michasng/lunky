extends MovementState
class_name EnterState

func get_transition() -> BaseState:
	var anim_node = str(anim_playback.get_current_node())
	if not anim_node in ['', 'enter', 'leave']:
		return $"../StandState"
	return self

func enter_state(_previous_state: BaseState, _delta: float):
	anim_playback.travel('enter')

func exit_state(_next_state: BaseState, _delta: float):
	pass

func handle_physics(_delta: float):
	pass
