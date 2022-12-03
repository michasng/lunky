extends CharacterState
class_name FallState

@onready var tile_above: RayCast2D = $"../../TileAbove"
@onready var tile_above_default_target_pos: Vector2i = tile_above.target_position
@onready var tile_in_front: RayCast2D = $"../../TileInFront"
@onready var tile_in_front_default_target_pos: Vector2i = tile_in_front.target_position

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
	if can_coyote_jump and \
		frame_count <= coyote_frames and \
		Input.is_action_just_pressed('jump'):
		return $"../JumpState"
	if body.is_on_floor():
		return $"../StandState"
	if (not body.previous_state is LedgeState or frame_count > ledge_cooloff_frames) and \
		not tile_above.get_collider() and tile_in_front.get_collider():
		return $"../LedgeState"
	return self

func enter_state(previous_state: CharacterState, _delta: float):
	anim_tree.travel("jump_fall")
	jump_pressed_frame = -1
	can_coyote_jump = previous_state is StandState or previous_state is LedgeState

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(delta: float):
	default_physics(delta)
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		tile_above.target_position = input_direction * tile_above_default_target_pos
		tile_in_front.target_position = input_direction * tile_in_front_default_target_pos
	if Input.is_action_just_pressed("jump"):
		jump_pressed_frame = frame_count
