extends RigidBody2D
class_name RopeSegment

@onready var anim_player: AnimationPlayer = $AnimationPlayer

signal unrolled

var _is_cap: bool


func unroll(is_cap: bool):
	_is_cap = is_cap
	anim_player.play("unroll")


func _on_animation_finished(anim_name: String):
	if anim_name == "unroll":
		unrolled.emit()
		if _is_cap:
			anim_player.play("cap")
		else:
			anim_player.play("hang")
