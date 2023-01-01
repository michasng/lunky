extends BaseState
class_name WhipAttackState

@onready var body: Player = $"../.."
@onready var anim_tree: AnimationTree = $"../../AnimationTree"
@onready var anim_playback: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

var previous_anim_node: StringName


func get_transition() -> BaseState:
	if anim_playback.get_current_play_position() == \
		anim_playback.get_current_length():
		return $"../IdleAttackState"
	return self


func enter_state(_previous_state: BaseState, _delta: float):
	previous_anim_node = anim_playback.get_current_node()
	# no way to set the play position again later
	# previous_play_position = anim_playback.get_current_play_position()
	anim_playback.start("whip")


func exit_state(_next_state: BaseState, _delta: float):
	anim_playback.start(previous_anim_node)


func handle_physics(_delta: float):
	pass

