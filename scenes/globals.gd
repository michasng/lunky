extends Node

class_name Globals

const solid_layer: int = 1
const player_layer: int = 2
const platform_layer: int = 3
const ladder_layer: int = 4

const tile_size: int = 128
const physics_fps: int = 60

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const linear_speed_limit: float = 0.4 * tile_size * physics_fps
