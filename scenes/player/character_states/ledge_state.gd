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
	if body.view_dir == body.RIGHT and Input.is_action_pressed("move_left") \
		or body.view_dir == body.LEFT and Input.is_action_pressed("move_right"):
			return $"../FallState"
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	body.velocity.y = 0
	var tile = body.pos_to_tile(body.get_center())
	if body.view_dir == body.RIGHT: tile.x += 1
	var ledge_pos = body.tile_to_pos(tile, false)
	# move the player directly to the ledge
	body.position = ledge_pos + Vector2(
		-body.view_dir * (body.hit_box.x / 2 - 1), # -1 pixel, to avoid weird edge collisions
		body.hit_box.y - ledge_offset
	)
	anim_tree.travel("ledge_grab")

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(_delta: float):
	self.handle_rope_input()

func drop_rope_offset() -> Vector2:
	return Vector2(0, 0)
