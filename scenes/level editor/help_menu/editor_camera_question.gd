extends Control

@export var list_of_keybinds:Label


func _ready() -> void:
	_set_up_list_of_zoom_keybinds()
	$PanelContainer/MarginContainer/VBoxContainer/Button.connect("button_down", queue_free)



func _set_up_list_of_zoom_keybinds() -> void:
	var str:String = ""
	
	var num:int = 1
	str += "\nYou can Zoom in with: "
	
	for i in InputMap.action_get_events("editor_camera_scroll_in"):
		str += "\n" + str(num) + ". " + i.as_text()
		num += 1
	
	str += "\n\nYou can zoom out with:"
	
	num = 1
	for i in InputMap.action_get_events("editor_camera_scroll_out"):
		str += "\n" + str(num) + ". " + i.as_text()
		num += 1
	
	str += "\n\nYou can reset the camera's zoom with:"
	
	num = 1
	for i in InputMap.action_get_events("editor_camera_scroll_reset"):
		str += "\n" + str(num) + ". " + i.as_text()
		num += 1
	
	list_of_keybinds.text = str
	
	InputMap.action_get_events("editor_move_left")
	InputMap.action_get_events("editor_move_right")
