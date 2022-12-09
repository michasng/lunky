extends CharacterState
class_name ExitState

func get_transition() -> CharacterState:
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	anim_playback.travel('exit')

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(_delta: float):
	pass
