extends Node
class_name AnimationHandler

@export var anim_tree: AnimationTree
@onready var anim_playback: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

var _current: StringName
var _override: StringName


func travel(node: StringName):
	if _override.is_empty():
		anim_playback.travel(node)
	_current = node


func override(node: StringName):
	_override = node
	anim_playback.travel(_override)


func clear_override():
	_override = StringName("")


func is_current_done_playing():
	return anim_playback.get_current_play_position() == \
		anim_playback.get_current_length()


func get_current_node():
	return anim_playback.get_current_node()
