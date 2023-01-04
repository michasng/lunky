extends MovementState
class_name JumpState

func get_transition() -> BaseState:
	if body.is_on_floor():
		return $"../StandState"
	if body.velocity.y > 0:
		if has_climb_input():
			if body.can_climb_rope():
				return $"../ClimbRopeState"
			if body.can_climb_ladder():
				return $"../ClimbLadderState"
		return $"../FallState"
	return self

func enter_state(_previous_state: BaseState, delta: float):
	body.velocity.y = min(body.velocity.y, 0) # stop any downward movement first
	body.velocity.y -= body.jump_power * delta
	anim_handler.travel("jump_rise")

func exit_state(_next_state: BaseState, _delta: float):
	pass

func handle_physics(delta: float):
	if Input.is_action_just_released("jump"):
		body.velocity.y /= 2
	default_physics(delta)
