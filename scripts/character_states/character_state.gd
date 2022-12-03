extends Node
class_name CharacterState

@onready var body: CharacterBody2D = $"../.."
@onready var hit_box: Vector2 = $"../../HitBox".shape.get_rect().size
@onready var sprite: Sprite2D = $"../../Sprite2D"
@onready var anim_tree: AnimationNodeStateMachinePlayback = $"../../AnimationTree".get("parameters/playback")

var pixel_per_meter = ProjectSettings.get_setting("global/pixel_per_meter")
# var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func get_transition() -> CharacterState:
	return self

func enter_state(_previous_state: CharacterState, _delta: float):
	pass

func exit_state(_next_state: CharacterState, _delta: float):
	pass

func handle_physics(_delta: float):
	pass

func default_physics(delta: float):
	if not body.is_on_floor():
		body.velocity.y += body.gravity * delta

	body.velocity.x = move_toward(body.velocity.x, 0, body.friction)

	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction:
		var factor = 1.0 if Input.is_action_pressed("sneak") else body.sprint_factor
		body.velocity.x = move_toward(
			body.velocity.x,
			input_direction * body.max_speed * factor,
			body.acceleration * delta * factor
		)
		sprite.flip_h = input_direction < 0

	# print(position / pixel_per_meter)
	# if velocity != Vector2.ZERO:
	# 	print('vel: ', velocity / spelunky2_fps / pixel_per_meter)
	body.move_and_slide()
