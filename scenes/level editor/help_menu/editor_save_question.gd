extends Control

@export var list_of_keybinds:Label
@export var list_of_keybinds2:Label


func _ready() -> void:
	_set_up_list_of_save_keybinds()
	_set_up_list_of_undo_keybinds()
	
	$PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/Button.connect("button_down", queue_free)


@export var keybind_node:Control


func _set_up_list_of_save_keybinds() -> void:
	var str:String = ""
	
	var num:int = 1
	str += "\nYou can Quick-Save with: "
	
	var textures:Array[Texture2D] = []
	for i in InputMap.action_get_events("editor_save_level_editor"):
		textures.append(ControllerIcons.parse_event(i))
		str += "\n" + str(num) + ". " + i.as_text()
		num += 1
	
	for text in textures:
		pass
		#var texture:TextureRect = TextureRect.new()
		#texture.texture = text
		#keybind_node.add_child(texture)
		#texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	list_of_keybinds.text = str + "\n"


func _set_up_list_of_undo_keybinds() -> void:
	var str:String = ""
	
	var num:int = 1
	str += "\nYou can Quick-Undo with: "
	
	var textures:Array[Texture2D] = []
	for i in InputMap.action_get_events("editor_undo_level_editor"):
		#textures.append(ControllerIcons.parse_event(i))
		str += "\n" + str(num) + ". " + i.as_text()
		num += 1
	
	for text in textures:
		pass
		#var texture:TextureRect = TextureRect.new()
		#texture.texture = text
		#keybind_node.add_child(texture)
		#texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	list_of_keybinds2.text = str
