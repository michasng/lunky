extends CharacterState
class_name CrouchState

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
	if not Input.is_action_pressed("move_down"):
		return $"../StandState"
	return self

func enter_state(previous_state: CharacterState, _delta: float):
	jump_buffered = previous_state is FallState and previous_state.jump_buffered()
	anim_playback.travel("crawl")

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(delta: float):
	apply_gravity(delta)
	apply_friction()
	
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		body.velocity.x = input_direction * body.crawl_speed
		body.handle_turn(sign(input_direction))

	body.move_and_slide()
	
	handle_rope_input()

	if input_direction:
		anim_tree.set("parameters/crawl/TimeScale/scale", 1)
	else:
		anim_tree.set("parameters/crawl/TimeScale/scale", 0)
