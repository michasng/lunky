extends Node
class_name RepeatingWorld

@export var bounds_meter: Vector2 = Vector2(40, 32)
@export var padding_meter: Vector2 = Vector2(2, 2)
@export var portal_size_meter: Vector2 = Vector2(5, 5)

@onready var pixel_per_meter = ProjectSettings.get_setting("global/pixel_per_meter")
@onready var bounds = bounds_meter * pixel_per_meter
@onready var padding = padding_meter * pixel_per_meter
@onready var total_size = bounds + 2 * padding
@onready var portal_size = portal_size_meter * pixel_per_meter

@onready var left_to_right_teleport: TeleportArea = $"Teleports/LeftToRight"
@onready var right_to_left_teleport: TeleportArea = $"Teleports/RightToLeft"
@onready var top_to_bottom_teleport: TeleportArea = $"Teleports/TopToBottom"
@onready var bottom_to_top_teleport: TeleportArea = $"Teleports/BottomToTop"
@onready var left_to_right_projection: WorldProjection = $"Projections/LeftToRight"
@onready var right_to_left_projection: WorldProjection = $"Projections/RightToLeft"
@onready var top_to_bottom_projection: WorldProjection = $"Projections/TopToBottom"
@onready var bottom_to_top_projection: WorldProjection = $"Projections/BottomToTop"
@onready var tl_br_projection: WorldProjection = $"Projections/TopLeftToBottomRight"
@onready var br_tl_projection: WorldProjection = $"Projections/BottomRightToTopLeft"
@onready var tr_bl_projection: WorldProjection = $"Projections/TopRightToBottomLeft"
@onready var bl_tr_projection: WorldProjection = $"Projections/BottomLeftToTopRight"


func _ready():
	init()


func init():
	var projection_size = portal_size * 2
	var h_portal_y = -padding.y
	var left_portal_x = -padding.x - portal_size.x
	var right_teleport_x = bounds.x + padding.x
	var right_projection_x = right_teleport_x - portal_size.x
	var h_teleport_size = Vector2(portal_size.x, total_size.y)
	var h_projection_size = Vector2(projection_size.x, total_size.y)
	left_to_right_teleport.position = Vector2(left_portal_x, h_portal_y)
	left_to_right_teleport.size = h_teleport_size
	left_to_right_teleport.teleport_movement = Vector2(total_size.x, 0)
	right_to_left_teleport.position = Vector2(right_teleport_x, h_portal_y)
	right_to_left_teleport.size = h_teleport_size
	right_to_left_teleport.teleport_movement = -left_to_right_teleport.teleport_movement
	left_to_right_projection.record_position = Vector2(left_portal_x, h_portal_y)
	left_to_right_projection.position = Vector2(right_projection_x, h_portal_y)
	left_to_right_projection.size = h_projection_size
	right_to_left_projection.record_position = left_to_right_projection.position
	right_to_left_projection.position = left_to_right_projection.record_position
	right_to_left_projection.size = h_projection_size

	var v_portal_x = -padding.x
	var top_portal_y = -padding.y - portal_size.y
	var bottom_teleport_y = bounds.y + padding.y
	var bottom_projection_y = bottom_teleport_y - portal_size.y
	var v_teleport_size = Vector2(total_size.x, portal_size.y)
	var v_projection_size = Vector2(total_size.x, projection_size.y)
	top_to_bottom_teleport.position = Vector2(v_portal_x, top_portal_y)
	top_to_bottom_teleport.size = v_teleport_size
	top_to_bottom_teleport.teleport_movement = Vector2(0, total_size.y)
	bottom_to_top_teleport.position = Vector2(v_portal_x, bottom_teleport_y)
	bottom_to_top_teleport.size = v_teleport_size
	bottom_to_top_teleport.teleport_movement = -top_to_bottom_teleport.teleport_movement
	top_to_bottom_projection.record_position = Vector2(v_portal_x, top_portal_y)
	top_to_bottom_projection.position = Vector2(v_portal_x, bottom_projection_y)
	top_to_bottom_projection.size = v_projection_size
	bottom_to_top_projection.record_position = top_to_bottom_projection.position
	bottom_to_top_projection.position = top_to_bottom_projection.record_position
	bottom_to_top_projection.size = v_projection_size

	tl_br_projection.record_position = Vector2(left_portal_x, top_portal_y)
	tl_br_projection.position = Vector2(right_projection_x, bottom_projection_y)
	tl_br_projection.size = projection_size
	br_tl_projection.record_position = tl_br_projection.position
	br_tl_projection.position = tl_br_projection.record_position
	br_tl_projection.size = projection_size
	bl_tr_projection.record_position = Vector2(left_portal_x, bottom_projection_y)
	bl_tr_projection.position = Vector2(right_projection_x, top_portal_y)
	bl_tr_projection.size = projection_size
	tr_bl_projection.record_position = bl_tr_projection.position
	tr_bl_projection.position = bl_tr_projection.record_position
	tr_bl_projection.size = projection_size


