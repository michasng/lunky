extends CharacterState
class_name LedgeState

@onready var tile_in_front: RayCast2D = $"../../TileInFront"

# how many pixels to hang above ledges
var ledge_offset: float = 2

func get_transition() -> CharacterState:
	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("move_down"):
			return $"../FallState"
		return $"../JumpState"
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	body.velocity.y = 0
	# move the player directly to the ledge
	var player_center = body.position - hit_box / 2
	var tile = floor(player_center / pixel_per_meter) * pixel_per_meter
	var input_direction = tile_in_front.target_position.normalized()
	if input_direction == Vector2.RIGHT:
		tile += Vector2(pixel_per_meter, 0)
	body.position = tile + Vector2(
		-input_direction.x * (hit_box.x / 2 - 1),
		hit_box.y - ledge_offset
	)
	anim_tree.travel("ledge_grab")

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(_delta: float):
	pass
