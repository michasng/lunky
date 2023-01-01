extends MovementState
class_name FallState

# avoid getting stuck on a ledge and being unable to drop
@export var ledge_cooloff_frames: int = 10
# allows jumping slightly after leaving the ground for better play-feel
@export var coyote_frames = 4
# buffer jumps slightly before reaching the ground for better play-feel
@export var jump_buffer_frames = 4

var can_coyote_jump: bool
var jump_pressed_frame: int

var was_previously_hanging_on_ledge: bool
var was_previously_climbing: bool
var drop_key_released: bool

func jump_buffered() -> bool:
	return jump_pressed_frame != -1 and \
		frame_count - jump_pressed_frame <= jump_buffer_frames

func get_transition() -> BaseState:
	var can_climb_again = not was_previously_climbing or drop_key_released
	if can_climb_again and has_climb_input():
		if body.can_climb_rope():
			return $"../ClimbRopeState"
		if body.can_climb_ladder():
			return $"../ClimbLadderState"
	if can_coyote_jump and \
		frame_count <= coyote_frames and \
		Input.is_action_just_pressed('jump'):
		return $"../JumpState"
	if body.is_on_floor():
		return $"../StandState"
	if (not was_previously_hanging_on_ledge or frame_count > ledge_cooloff_frames) and \
		not body.tile_above.get_collider() and body.tile_in_front.get_collider():
		return $"../LedgeState"
	return self

func enter_state(previous_state: BaseState, _delta: float):
	was_previously_climbing = (
		previous_state is ClimbRopeState or \
		previous_state is ClimbLadderState
	)
	was_previously_hanging_on_ledge = previous_state is LedgeState
	drop_key_released = false
	anim_playback.travel("jump_fall")
	jump_pressed_frame = -1
	can_coyote_jump = previous_state is StandState or previous_state is LedgeState

func exit_state(_next_state: BaseState, _delta: float):
	body.set_collision_mask_value(globals.platform_layer, true)

func handle_physics(delta: float):
	default_physics(delta)
	if Input.is_action_just_released("move_down"):
		drop_key_released = true
	if Input.is_action_just_pressed("jump"):
		jump_pressed_frame = frame_count
	if Input.is_action_just_released("jump"):
		body.set_collision_mask_value(globals.platform_layer, true)
	if body.velocity.y == globals.linear_speed_limit:
		anim_playback.travel("long_fall")

