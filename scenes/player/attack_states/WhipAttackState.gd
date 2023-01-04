extends BaseState
class_name WhipAttackState

@onready var body: Player = $"../.."
@onready var anim_handler: AnimationHandler = $"../../AnimationHandler"


func get_transition() -> BaseState:
	if anim_handler.is_current_done_playing():
		return $"../IdleAttackState"
	return self


func enter_state(_previous_state: BaseState, _delta: float):
	anim_handler.override("whip")


func exit_state(_next_state: BaseState, _delta: float):
	anim_handler.clear_override()


func handle_physics(_delta: float):
	pass

