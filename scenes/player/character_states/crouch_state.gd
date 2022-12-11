extends CharacterState
class_name CrouchState

var jump_buffered: bool = false

func get_transition() -> CharacterState:
	if has_climb_input() and body.can_climb_rope():
		return $"../ClimbRopeState"
	if has_climb_input() and body.can_climb_ladder():
		return $"../ClimbLadderState"
	if (Input.is_action_just_pressed('jump') or jump_buffered) \
		and not Input.is_action_pressed("move_down"):
		return $"../JumpState"
	if not body.is_on_floor():
		return $"../FallState"
	if not Input.is_action_pressed("move_down"):
		return $"../StandState"
	return self

func enter_state(previous_state: CharacterState, _delta: float):
	jump_buffered = previous_state is FallState and previous_state.jump_buffered()
	anim_playback.travel("crawl")
	
	body.collision_shape.shape = RectangleShape2D.new()
	body.collision_shape.shape.size = body.hit_box_crouch
	body.collision_shape.position = Vector2(0, - body.hit_box_crouch.y / 2)

func exit_state(_next_state: CharacterState, _delta: float):
	body.collision_shape.shape = RectangleShape2D.new()
	body.collision_shape.shape.size = body.hit_box
	body.collision_shape.position = Vector2(0, - body.hit_box.y / 2)

func handle_physics(delta: float):
	apply_gravity(delta)
	apply_friction()
	
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		body.velocity.x = input_direction * body.crawl_speed
		body.handle_turn(sign(input_direction))

	body.move_and_slide()
	
	handle_drop_through_platform_input()
	handle_rope_input()

	if input_direction:
		anim_tree.set("parameters/crawl/TimeScale/scale", 1)
	else:
		anim_tree.set("parameters/crawl/TimeScale/scale", 0)
