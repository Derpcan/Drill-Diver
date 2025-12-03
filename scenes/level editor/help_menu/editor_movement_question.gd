extends Control

@export var list_of_keybinds:Label


func _ready() -> void:
	_set_up_list_of_movement_keybinds()
	$PanelContainer/MarginContainer/VBoxContainer/Button.connect("button_down", queue_free)



func _set_up_list_of_movement_keybinds() -> void:
	var down_movement:Array[String]
	for i in InputMap.action_get_events("editor_move_down"):
		down_movement.append(i.as_text())
	
	var str:String = "You can move down with: "
	
	for i in down_movement:
		str += "\n" + i
	
	
	str += "\n\nYou can move up with: "
	
	for i in InputMap.action_get_events("editor_move_up"):
		str += "\n" + i.as_text()
	
	str += "\n\nYou can move left with:"
	
	for i in InputMap.action_get_events("editor_move_left"):
		str += "\n" + i.as_text()
	
	str += "\n\nYou can move right with:"
	
	for i in InputMap.action_get_events("editor_move_right"):
		str += "\n" + i.as_text()
	
	list_of_keybinds.text = str
	
	InputMap.action_get_events("editor_move_left")
	InputMap.action_get_events("editor_move_right")
