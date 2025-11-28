@tool
extends HBoxContainer
class_name KeybindChanger


## Default key binds
var default_binds_file_path:String = "res://default_keybinds/keybind.kb"


@export var action_name_display:String = "Example: ":
	set(new_action_display_name):
		action_name_display = new_action_display_name
		
		if action_name_label != null:
			action_name_label.text = action_name_display

@export var action_name:String = "jump":
	set(new_action_name):
		action_name = new_action_name

@export_category("Keyboard Inputs")
#@export var keyboard_bind:String = "Spacebar":
	#set(new_keyboard_bind):
		#keyboard_bind = new_keyboard_bind
		#
		#if keyboard_bind_button != null:
			#keyboard_bind_button.text = keyboard_bind

#@export var keyboard_input_bind:InputEvent
var current_keyboard_input_bind:InputEvent:
	set(new_value):
		current_keyboard_input_bind = new_value
		
		if keyboard_bind_button != null :
			if current_keyboard_input_bind == null:
				keyboard_bind_button.text = ""
				keyboard_bind_button.hide()
			else:
				keyboard_bind_button.text = current_keyboard_input_bind.as_text()
				keyboard_bind_button.show()


@export_category("Controller Inputs")
#@export var controller_bind:String = "A":
	#set(new_controller_bind):
		#controller_bind = new_controller_bind
		#
		#if controller_bind_button != null:
			#controller_bind_button.text = controller_bind
#@export var controller_input_bind:InputEvent
var current_controller_input_bind:InputEvent:
	set(new_value):
		current_controller_input_bind = new_value
		
		if controller_bind_button != null:
			if current_controller_input_bind == null:
				controller_bind_button.text = ""
				controller_bind_button.hide()
			else:
				controller_bind_button.text = current_controller_input_bind.as_text()
				controller_bind_button.show()


@export_category("Mouse Inputs")
#@export var mouse_bind:String = "A":
	#set(new_mouse_bind):
		#mouse_bind = new_mouse_bind
		#
		#if mouse_bind_button != null:
			#mouse_bind_button.text = mouse_bind
#@export var mouse_input_bind:InputEvent
var current_mouse_input_bind:InputEvent:
	set(new_value):
		current_mouse_input_bind = new_value
		
		
		if mouse_bind_button != null:
			if current_mouse_input_bind == null:
				mouse_bind_button.text = ""
				mouse_bind_button.hide()
			else:
				mouse_bind_button.text = current_mouse_input_bind.as_text()
				mouse_bind_button.show()


@onready var action_name_label:Label = $ActionName
@onready var keyboard_bind_button:Button = $KeyboardBind
@onready var controller_bind_button:Button = $ControllerBind
@onready var reset_binds_button:Button = $Reset
@onready var mouse_bind_button:Button = $MouseBind

func _ready() -> void:
	
	action_name_label.text = action_name_display
	
	keyboard_bind_button.hide()
	controller_bind_button.hide()
	mouse_bind_button.hide()
	
	if keyboard_bind_button:
		keyboard_bind_button.pressed.connect(_listen_for_input)
	if controller_bind_button:
		controller_bind_button.pressed.connect(_listen_for_input)
	if mouse_bind_button:
		mouse_bind_button.pressed.connect(_listen_for_input)
	
	
	reset_binds_button.connect("pressed", _reset_binds)
	
	#current_controller_input_bind = controller_input_bind
	#current_keyboard_input_bind = keyboard_input_bind
	load_actions()
	
	#save_default_actions()




func load_actions() -> void:
	for inputevent in InputMap.action_get_events(action_name.to_lower()):
		if inputevent is InputEventKey:
			#keyboard_input_bind = inputevent
			current_keyboard_input_bind = inputevent
		elif inputevent is InputEventJoypadButton or inputevent is InputEventJoypadMotion:
			#controller_input_bind = inputevent
			current_controller_input_bind = inputevent
		elif inputevent is InputEventMouseButton:
			#mouse_input_bind = inputevent
			current_mouse_input_bind = inputevent
	pass



func _listen_for_input() -> void:
	var change_button:ChangeButton = SceneManager.push_scene_with_return("res://scenes/UI/keybind_settings/change_button.tscn")
	
	change_button.save_new_input.connect(_set_bind)
	change_button.destroying.connect(_disconnect_from_change_button)



func _disconnect_from_change_button(change_button:ChangeButton) -> void:
	change_button.destroying.disconnect(_disconnect_from_change_button)
	change_button.save_new_input.disconnect(_set_bind)



func _set_bind(input_event:InputEvent, change_button:ChangeButton):
	if input_event == null:
		change_button.destroying.disconnect(_disconnect_from_change_button)
		change_button.save_new_input.disconnect(_set_bind)
		return
	
	if input_event is InputEventKey and input_event is not InputEventMouse:
		set_keyboard_bind(input_event)
	elif input_event is InputEventJoypadButton or input_event is InputEventJoypadMotion:
		set_controller_bind(input_event)
	else:
		set_mouse_bind(input_event)
	
	change_button.destroying.disconnect(_disconnect_from_change_button)
	change_button.save_new_input.disconnect(_set_bind)



func set_mouse_bind(new_input:InputEvent) -> void:
	InputMap.action_erase_event(action_name.to_lower(), current_mouse_input_bind)
	InputMap.action_add_event(action_name.to_lower(), new_input)
	current_mouse_input_bind = new_input



func set_controller_bind(new_input:InputEvent) -> void:
	InputMap.action_erase_event(action_name.to_lower(), current_controller_input_bind)
	InputMap.action_add_event(action_name.to_lower(), new_input)
	current_controller_input_bind = new_input



func set_keyboard_bind(new_input:InputEventKey) -> void:
	InputMap.action_erase_event(action_name.to_lower(), current_keyboard_input_bind)
	InputMap.action_add_event(action_name.to_lower(), new_input)
	current_keyboard_input_bind = new_input




# Resets the keybinds back to default
func _reset_binds() -> void:
	InputMap.action_erase_events(action_name.to_lower())
	
	
	var file:FileAccess = FileAccess.open(default_binds_file_path,FileAccess.READ)
	
	var text:String = file.get_as_text()
	var result:Dictionary = JSON.parse_string(text)
	#var result:Dictionary = JSON.to_native(JSON.parse_string(text))
	
	if action_name in result:
		var arr:Array = result[action_name]
		for dict:Dictionary in arr:
			var event:InputEvent = _dict_to_input_event(dict)
			InputMap.action_add_event(action_name, event)
			match dict["type"]:
				"key":
					current_keyboard_input_bind = event
				"joy_button":
					current_controller_input_bind = event
				"joy_axis":
					current_controller_input_bind = event
				"mouse_button":
					current_mouse_input_bind = event
	
	#print(InputMap.action_get_events(action_name.to_lower()))
	#InputMap.action_add_event(action_name.to_lower(), keyboard_input_bind)
	#InputMap.action_add_event(action_name.to_lower(), controller_input_bind)
	#current_keyboard_input_bind = keyboard_input_bind
	#current_controller_input_bind = controller_input_bind
	current_mouse_input_bind = null
	#print(InputMap.action_get_events(action_name.to_lower()))



func _dict_to_input_event(d: Dictionary) -> InputEvent:
	match d.get("type"):
		
		"key":
			var e := InputEventKey.new()
			e.physical_keycode = d["physical_keycode"]
			e.shift_pressed = d.get("shift", false)
			e.alt_pressed   = d.get("alt", false)
			e.ctrl_pressed  = d.get("ctrl", false)
			e.meta_pressed  = d.get("meta", false)
			return e
		
		"joy_button":
			var e := InputEventJoypadButton.new()
			e.button_index = d["button_index"]
			return e
		
		"joy_axis":
			var e := InputEventJoypadMotion.new()
			e.axis = d["axis"]
			e.axis_value = d["value"]
			return e
		
		"mouse_button":
			var e := InputEventMouseButton.new()
			e.button_index = d["button_index"]
			return e
	
	return null




func _load_actions(file_path:String):
	var path = file_path
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("No saved keybinds found")
		return

	var text := file.get_as_text()
	var result = JSON.parse_string(text)
	if typeof(result) != TYPE_DICTIONARY:
		push_error("Invalid keybind file")
		return

	for action in result.keys():
		InputMap.action_erase_events(action)
		for d in result[action]:
			InputMap.action_add_event(action, _dict_to_input_event(d))
