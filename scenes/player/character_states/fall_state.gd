extends CharacterState
class_name FallState

# avoid getting stuck on a ledge and being unable to drop
@export var ledge_cooloff_frames: int = 10
# allows jumping slightly after leaving the ground for better play-feel
@export var coyote_frames = 4
# buffer jumps slightly before reaching the ground for better play-feel
@export var jump_buffer_frames = 4

var can_coyote_jump: bool
var jump_pressed_frame: int

func jump_buffered() -> bool:
	return jump_pressed_frame != -1 and \
		frame_count - jump_pressed_frame <= jump_buffer_frames

func get_transition() -> CharacterState:
	if not body.rope_contacts.is_empty() and not Input.is_action_pressed("jump") and \
		(Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down")):
		return $"../ClimbRopeState"
	if can_coyote_jump and \
		frame_count <= coyote_frames and \
		Input.is_action_just_pressed('jump'):
		return $"../JumpState"
	if body.is_on_floor():
		return $"../StandState"
	if (not body.previous_state is LedgeState or frame_count > ledge_cooloff_frames) and \
		not body.tile_above.get_collider() and body.tile_in_front.get_collider():
		return $"../LedgeState"
	return self

func enter_state(previous_state: CharacterState, _delta: float):
	anim_playback.travel("jump_fall")
	jump_pressed_frame = -1
	can_coyote_jump = previous_state is StandState or previous_state is LedgeState

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(delta: float):
	default_physics(delta)
	if Input.is_action_just_pressed("jump"):
		jump_pressed_frame = frame_count
