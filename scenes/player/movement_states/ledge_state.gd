extends MovementState
class_name LedgeState

@onready var tile_in_front: RayCast2D = $"../../TileInFront"

# how many pixels to hang above ledges
var ledge_offset: float = 2
var collider: Object

func get_transition() -> BaseState:
	if Input.is_action_just_pressed("jump"):
		if Input.is_action_pressed("move_down"):
			return $"../FallState"
		return $"../JumpState"
	if body.view_dir == body.RIGHT and Input.is_action_pressed("move_left") \
		or body.view_dir == body.LEFT and Input.is_action_pressed("move_right"):
			return $"../FallState"
	return self

func enter_state(_previous_state: BaseState, _delta: float):
	body.velocity.y = 0
	collider = body.tile_in_front.get_collider()
	var ledge_pos: Vector2
	if collider is CollisionObject2D:
		var owner_ids = collider.get_shape_owners()
		var shape_id = body.tile_in_front.get_collider_shape()
		var shape = collider.shape_owner_get_shape(owner_ids[0], shape_id)
		ledge_pos = collider.position + shape.get_rect().position
		if body.view_dir == body.LEFT:
			ledge_pos += Vector2(shape.get_rect().size.x, 0)
	if collider is TileMap:
		var tile: Vector2i = body.level.local_to_map(body.get_center())
		var tile_center = body.level.map_to_local(tile)
		ledge_pos = tile_center + Vector2(
			body.view_dir * globals.tile_size / 2,
			-globals.tile_size / 2
		)
	move_to_ledge(ledge_pos)

	anim_playback.travel("ledge_grab")

func move_to_ledge(ledge_pos: Vector2):
	body.position = ledge_pos + Vector2(
		-body.view_dir * (body.hit_box.x / 2 - 1), # -1 pixel, to avoid weird edge collisions
		body.hit_box.y - ledge_offset
	)

func exit_state(_next_state: BaseState, _delta: float):
	pass

func handle_physics(_delta: float):
	if collider is CharacterBody2D:
		body.velocity = collider.velocity
		body.apply_velocity()
	handle_rope_input()

func drop_rope_offset() -> Vector2:
	return Vector2(0, 0)
