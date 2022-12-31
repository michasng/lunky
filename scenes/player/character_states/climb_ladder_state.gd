extends CharacterState
class_name ClimbLadderState


func get_transition() -> CharacterState:
	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("move_down"):
			return $"../FallState"
		return $"../JumpState"
	if body.is_on_floor():
		return $"../StandState"
	if not body.can_climb_ladder():
		if has_climb_input() and body.can_climb_rope():
			return $"../ClimbRopeState"
		return $"../FallState"
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	body.center_on_tile_horizontally()
	anim_playback.travel('climb_ladder')
	anim_tree.set("parameters/climb_ladder/TimeScale/scale", 1)
	body.set_collision_mask_value(globals.platform_layer, false)

func exit_state(_next_state: CharacterState, _delta: float):
	body.set_collision_mask_value(globals.platform_layer, true)

func handle_physics(_delta: float):
	var input_direction = Input.get_axis("move_up", "move_down")
	if input_direction:
		body.velocity = Vector2(0, input_direction * body.max_speed)
		if input_direction < 0:
			anim_tree.set("parameters/climb_ladder/TimeScale/scale", 1)
		elif input_direction > 0:
			anim_tree.set("parameters/climb_ladder/TimeScale/scale", -1)
	else:
		body.velocity = Vector2.ZERO
		anim_tree.set("parameters/climb_ladder/TimeScale/scale", 0)
	
	body.apply_velocity()
	
	handle_rope_input()

func handle_rope_input():
	if Input.is_action_just_pressed("rope"):
		body.throw_rope()
