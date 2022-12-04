extends CharacterState
class_name ClimbRopeState


func get_transition() -> CharacterState:
	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("move_down"):
			return $"../FallState"
		return $"../JumpState"
	if body.is_on_floor():
		return $"../StandState"
	if body.rope_contacts.is_empty():
		return $"../FallState"
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	body.center_on_tile_horizontally()
	anim_tree.travel('climb_rope')

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(_delta: float):
	var input_direction = Input.get_axis("move_up", "move_down")
	if input_direction:
		body.velocity = Vector2(0, input_direction * body.max_speed)
	else:
		body.velocity = Vector2.ZERO
	
	body.move_and_slide()
