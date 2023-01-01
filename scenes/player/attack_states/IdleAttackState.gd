extends BaseState
class_name IdleAttackState


func get_transition() -> BaseState:
	if Input.is_action_pressed("use_item"):
		return $"../WhipAttackState"
	return self


func enter_state(_previous_state: BaseState, _delta: float):
	pass 


func exit_state(_next_state: BaseState, _delta: float):
	pass


func handle_physics(_delta: float):
	pass
