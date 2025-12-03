extends Control

@export var list_of_keybinds:Label


func _ready() -> void:
	_set_up_list_of_save_keybinds()
	
	$PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Button.connect("button_down", queue_free)



func _set_up_list_of_save_keybinds() -> void:
	var str:String = ""
	
	var num:int = 1
	str += "\nYou can Quick-Save with: "
	
	for i in InputMap.action_get_events("editor_save_level_editor"):
		str += "\n" + str(num) + ". " + i.as_text()
		num += 1
	
	list_of_keybinds.text = str
