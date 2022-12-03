extends CharacterState
class_name FallState

@onready var tile_above: RayCast2D = $"../../TileAbove"
@onready var tile_above_default_target_pos: Vector2i = tile_above.target_position
@onready var tile_in_front: RayCast2D = $"../../TileInFront"
@onready var tile_in_front_default_target_pos: Vector2i = tile_in_front.target_position

func get_transition() -> CharacterState:
	if body.is_on_floor():
		return $"../StandState"
	if not tile_above.get_collider() and tile_in_front.get_collider():
		return $"../LedgeState"
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	anim_tree.travel("jump_fall")

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(delta: float):
	default_physics(delta)
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		tile_above.target_position = input_direction * tile_above_default_target_pos
		tile_in_front.target_position = input_direction * tile_in_front_default_target_pos
