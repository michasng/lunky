extends Node
class_name CharacterState

@onready var body: Player = $"../.."
@onready var anim_tree: AnimationTree = $"../../AnimationTree"
@onready var anim_playback: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

var frame_count: int = 0

func get_transition() -> CharacterState:
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	pass

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(_delta: float):
	pass

func default_physics(delta: float):
	apply_gravity(delta)
	apply_friction()

	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		var factor = 1.0 if Input.is_action_pressed("sneak") else body.sprint_factor
		body.velocity.x = move_toward(
			body.velocity.x,
			input_direction * body.max_speed * factor,
			body.acceleration * delta * factor
		)
		body.handle_turn(sign(input_direction))

	body.apply_velocity()
	
	handle_drop_through_platform_input()
	handle_rope_input()


func handle_drop_through_platform_input():
	if Input.is_action_pressed("move_down") and Input.is_action_just_pressed("jump"):
		body.set_collision_mask_value(globals.platform_layer, false)

func apply_gravity(delta: float):
	if not body.is_on_floor():
		body.velocity.y += globals.gravity * delta

func apply_friction():
	body.velocity.x = move_toward(body.velocity.x, 0, body.friction)

func handle_rope_input():
	if Input.is_action_just_pressed("rope"):
		if Input.is_action_pressed("move_down"):
			body.drop_rope(drop_rope_offset())
		else:
			body.throw_rope()

func drop_rope_offset() -> Vector2:
	return Vector2(globals.tile_size, globals.tile_size)

func has_climb_input() -> bool:
	if Input.is_action_pressed("move_up"):
		return true
	if Input.is_action_pressed("move_down"):
		if body.is_on_floor():
			return body.is_on_platform()
		return true
	return false
