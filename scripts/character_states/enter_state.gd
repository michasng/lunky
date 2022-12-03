extends CharacterState
class_name EnterState

func get_transition() -> CharacterState:
	var anim_node = str(anim_tree.get_current_node())
	if not anim_node in ['', 'enter', 'leave']:
		return $"../StandState"
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	anim_tree.travel('enter')

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(_delta: float):
	pass
