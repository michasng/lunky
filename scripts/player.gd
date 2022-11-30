extends CharacterBody2D
class_name Player

var pixel_per_meter = ProjectSettings.get_setting("global/pixel_per_meter")
# var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# values taken from the real game
var spelunky2_fps = 60 # number of physics calculations per second, actually
var friction: float = 0.015 * spelunky2_fps * pixel_per_meter
var gravity: float = 0.01 * pow(spelunky2_fps, 2) * pixel_per_meter
var acceleration: float = 0.032 * pow(spelunky2_fps, 2) * pixel_per_meter
var max_speed: float = 0.0725 * spelunky2_fps * pixel_per_meter
var sprint_factor: float = 2
var jump_power: float = 0.18 * pow(spelunky2_fps, 2) * pixel_per_meter

@onready var tile_above: RayCast2D = $TileAbove
@onready var tile_above_default_target_pos: Vector2i = tile_above.target_position
@onready var tile_in_front: RayCast2D = $TileInFront
@onready var tile_in_front_default_target_pos: Vector2i = tile_in_front.target_position

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_tree: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

enum State { DOOR, GROUND, JUMP, FALL, LEDGE }
var state_names = {
	State.DOOR: 'door',
	State.GROUND: 'ground',
	State.JUMP: 'jump',
	State.FALL: 'fall',
	State.LEDGE: 'ledge',
}

var current_state: State = State.DOOR
var previous_state: State = State.DOOR

func _physics_process(delta: float):
	# first transition, then handle physics, for responsiveness
	var next_state = get_transition()
	if next_state != current_state:
		set_state(next_state, delta)

	handle_physics(delta)

func get_transition():
	match current_state:
		State.DOOR:
			if anim_tree.get_current_node() != 'enter' and anim_tree.get_current_node() != 'leave':
				return State.GROUND
		State.GROUND:
			if Input.is_action_just_pressed('jump'):
				return State.JUMP
			if not is_on_floor():
				return State.FALL
		State.JUMP:
			if is_on_floor():
				return State.GROUND
			if velocity.y > 0:
				return State.FALL
		State.FALL:
			if is_on_floor():
				return State.GROUND
			if not tile_above.get_collider() and tile_in_front.get_collider():
				return State.LEDGE
		State.LEDGE:
			if Input.is_action_just_pressed("jump"):
				if Input.is_action_pressed("move_down"):
					return State.FALL
				return State.JUMP
	return current_state

func _exit_state(_previous_state: State, _next_state: State, delta: float):
	pass

func _enter_state(next_state: State, _previous_state: State, delta: float):
	if next_state == State.JUMP:
		velocity.y -= jump_power * delta
		anim_tree.travel("jump_rise")
	if next_state == State.FALL:
		anim_tree.travel("jump_fall")
	if next_state == State.LEDGE:
		velocity.y = 0
		anim_tree.travel("ledge_grab")


func handle_physics(delta: float):
	if current_state in [State.DOOR, State.LEDGE]:
		return
	
	if current_state == State.JUMP and Input.is_action_just_released("jump"):
		velocity.y /= 2
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("move_left", "move_right")

	velocity.x = move_toward(velocity.x, 0, friction)
	if direction:
		var factor = 1 if Input.is_action_pressed("sprint") else sprint_factor
		velocity.x = move_toward(
			velocity.x,
			direction * max_speed * factor,
			acceleration * delta * factor
		)

	# if velocity != Vector2.ZERO:
	# 	print('vel: ', velocity / spelunky2_fps / pixel_per_meter)
	move_and_slide()
	
	if direction:
		sprite.flip_h = direction < 0
		tile_above.target_position = direction * tile_above_default_target_pos
		tile_in_front.target_position = direction * tile_in_front_default_target_pos
	if current_state == State.GROUND:
		if direction:
			anim_tree.travel("walk")
		else:
			anim_tree.travel("idle")


func set_state(next_state: State, delta: float):
	# print(state_names[next_state])
	previous_state = current_state
	current_state = next_state
	_exit_state(previous_state, next_state, delta)
	_enter_state(next_state, previous_state, delta)
