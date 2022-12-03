extends CharacterState
class_name StandState

func get_transition() -> CharacterState:
	if Input.is_action_just_pressed('jump'):
		return $"../JumpState"
	if not body.is_on_floor():
		return $"../FallState"
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	pass

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(delta: float):
	default_physics(delta)
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		if Input.is_action_pressed("sneak"):
			anim_tree.travel("sneak")
		else:
			anim_tree.travel("walk")
	else:
		anim_tree.travel("idle")
