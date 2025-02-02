extends CharacterBody2D
class_name CrushTrap

@onready var area_by_direction: Dictionary = { # Dictionary[Vector2i, Area2D]
	Vector2i.LEFT: $LeftArea2D,
	Vector2i.RIGHT: $RightArea2D,
	Vector2i.UP: $UpArea2D,
	Vector2i.DOWN: $DownArea2D,
}

# same as max player speed. Probably incorrect. They should probably be even faster.
var SPEED_PIXELS_PER_TICK = 0.0725 * globals.tile_size * globals.physics_fps
var MAX_COOLDOWN_TICKS = globals.physics_fps

var movement_direction: Vector2i = Vector2i.ZERO
# This is just the cooldown after stopping,
# but there should also be a cooldown before starting to move.
var cooldown_ticks: int

func _physics_process(_delta: float):
	if velocity == Vector2.ZERO:
		if movement_direction != Vector2i.ZERO:
			movement_direction = Vector2i.ZERO
			cooldown_ticks = MAX_COOLDOWN_TICKS
			return
		
		if cooldown_ticks > 0:
			cooldown_ticks -= 1
		
		if cooldown_ticks == 0:
			var player_direction = Vector2i.ZERO
			for direction: Vector2i in area_by_direction:
				var area = area_by_direction[direction] as Area2D
				if area.has_overlapping_bodies():
					player_direction = direction
					break
			movement_direction = player_direction

	velocity = movement_direction * SPEED_PIXELS_PER_TICK
	move_and_slide()
