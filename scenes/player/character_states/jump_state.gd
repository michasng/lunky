extends CharacterState
class_name JumpState

func get_transition() -> CharacterState:
	if not body.rope_contacts.is_empty() and not Input.is_action_pressed("jump") and \
		(Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down")):
		return $"../ClimbRopeState"
	if body.is_on_floor():
		return $"../StandState"
	if body.velocity.y > 0:
		return $"../FallState"
	return self

func enter_state(_previous_state: CharacterState, delta: float):
	body.velocity.y = min(body.velocity.y, 0) # stop any downward movement first
	body.velocity.y -= body.jump_power * delta
	anim_playback.travel("jump_rise")

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(delta: float):
	if Input.is_action_just_released("jump"):
		body.velocity.y /= 2
	default_physics(delta)
