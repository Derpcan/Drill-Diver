extends Node2D
var triggered = false






func _on_area_2d_body_entered(body):
	if triggered == false:
		triggered= true
		get_tree().get_first_node_in_group("player")._enter_dialogue()
		Dialogic.start("res://dialogue/Timelines/timeline.dtl")
		await Dialogic.timeline_ended
		get_tree().get_first_node_in_group("player")._leave_dialogue()
