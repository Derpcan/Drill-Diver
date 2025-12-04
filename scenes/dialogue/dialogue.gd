extends Node2D
var triggered = false
@export var dialogue:DialogicTimeline






func _on_area_2d_body_entered(body):
	if triggered == false:
		triggered= true
		get_tree().get_first_node_in_group("player")._enter_dialogue()
		Dialogic.start(dialogue)
		await Dialogic.timeline_ended
		get_tree().get_first_node_in_group("player")._leave_dialogue()
