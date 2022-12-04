extends CharacterState
class_name StandState

var jump_buffered: bool = false

func get_transition() -> CharacterState:
	if not body.rope_contacts.is_empty() and \
		(Input.is_action_pressed("move_up") or \
		(not body.is_on_floor() and Input.is_action_pressed("move_down"))):
		return $"../ClimbRopeState"
	if Input.is_action_just_pressed('jump') or jump_buffered:
		return $"../JumpState"
	if not body.is_on_floor():
		return $"../FallState"
	return self

func enter_state(previous_state: CharacterState, _delta: float):
	jump_buffered = previous_state is FallState and previous_state.jump_buffered() 

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
