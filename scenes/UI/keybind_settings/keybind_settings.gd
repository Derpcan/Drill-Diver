extends CanvasLayer
class_name KeybindSettings



var user_keybinds_folder:String = "user://keybinds/"
var user_keybinds_filename:String = "keybinds.kb"

@onready var tab_bar:TabBar = $Panel/TabBar

var had_first_editor:bool = false

func _ready() -> void:
	
	save_actions(user_keybinds_folder, user_keybinds_filename)
	
	create_keybind_editors("game")
	
	tab_bar.tab_changed.connect(tab_change)
	
	tree_exiting.connect(save_keybinds)
	
	save_keybinds()


func save_keybinds() -> void:
	save_actions(user_keybinds_folder, user_keybinds_filename)



static func load_user_keybinds() -> void:
	var user_keybinds_folder:String = "user://keybinds/"
	var user_keybinds_filename:String = "keybinds.kb"
	
	
	if not FileAccess.file_exists(user_keybinds_folder + user_keybinds_filename):
		return
	
	for action_name in InputMap.get_actions():
		if action_name.begins_with("game_") or action_name.begins_with("editor_"):
	
			InputMap.action_erase_events(action_name.to_lower())
			
		
			var file:FileAccess = FileAccess.open(user_keybinds_folder + user_keybinds_filename,FileAccess.READ)
			
			var text:String = file.get_as_text()
			var result:Dictionary = JSON.parse_string(text)
			#var result:Dictionary = JSON.to_native(JSON.parse_string(text))
			
			if action_name in result:
				var arr:Array = result[action_name]
				for dict:Dictionary in arr:
					var event:InputEvent = _dict_to_input_event(dict)
					InputMap.action_add_event(action_name, event)



static func _dict_to_input_event(d: Dictionary) -> InputEvent:
	match d.get("type"):
		
		"key":
			var e := InputEventKey.new()
			e.physical_keycode = d["physical_keycode"]
			e.shift_pressed = d.get("shift", false)
			e.alt_pressed   = d.get("alt", false)
			e.ctrl_pressed  = d.get("ctrl", false)
			e.meta_pressed  = d.get("meta", true)
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



func tab_change(new_tab:int) -> void:
	if new_tab == 0:
		clear_keybinds()
		create_keybind_editors("game")
	else:
		clear_keybinds()
		create_keybind_editors("editor")

func clear_keybinds() -> void:
	var vbox:VBoxContainer = $Panel/MarginContainer/ScrollContainer/VBoxContainer
	
	for child in vbox.get_children().slice(1):
		child.queue_free()


func create_keybind_editors(type_of_keybind:String="game") -> void:
	var first:bool = true
	for action in InputMap.get_actions():
		if action.begins_with(type_of_keybind):
			var keybind_editor:KeybindChanger = preload("res://scenes/UI/keybind_settings/keybind_changer.tscn").instantiate()
			var h_sep:HSeparator = HSeparator.new()
			keybind_editor.action_name = action
			
			var display_name:String = action
			
			
			if action.begins_with("game_"):
				display_name = display_name.trim_prefix("game_")
			elif action.begins_with("editor_"):
				display_name = display_name.trim_prefix("editor_")
			
			#if action.begins_with("editor_") and had_first_editor == false:
				#had_first_editor = true
				#var hbox:HBoxContainer = HBoxContainer.new()
				#hbox.alignment = BoxContainer.ALIGNMENT_CENTER
				#var label:Label = Label.new()
				#label.text = "Level Editor Controls"
				#hbox.add_child(label)
				#
				#h_sep.custom_minimum_size = Vector2(0, 30)
				#$Panel/MarginContainer/ScrollContainer/VBoxContainer.add_child(h_sep)
				#$Panel/MarginContainer/ScrollContainer/VBoxContainer.add_child(hbox)
			#else:
				
			
			var words := display_name.split("_")
			for i in range(words.size()):
				words[i] = words[i].capitalize()
			
			display_name = " ".join(words)
			
			keybind_editor.action_name_display = display_name
			$Panel/MarginContainer/ScrollContainer/VBoxContainer.add_child(h_sep)
			$Panel/MarginContainer/ScrollContainer/VBoxContainer.add_child(keybind_editor)
			if first:
				first = false
				keybind_editor.keyboard_bind_button.grab_focus()
				



func save_actions(folder_path:String,file_path:String) -> void:
	DirAccess.make_dir_recursive_absolute(folder_path)
	var file:FileAccess = FileAccess.open(folder_path + file_path, FileAccess.WRITE)
	var export_data := {}
	
	for action in InputMap.get_actions():
		if action.begins_with("game") or action.begins_with("editor"):
			var list := []
			for ev in InputMap.action_get_events(action):
				list.append(_input_event_to_dict(ev))
			export_data[action] = list
		
	file.store_string(JSON.stringify(export_data, "\t"))


func _input_event_to_dict(ev: InputEvent) -> Dictionary:
	var d := {}
	
	if ev is InputEventMouseButton:
		d["type"] = "mouse_button"
		d["button_index"] = ev.button_index
	
	if ev is InputEventKey:
		d["type"] = "key"
		d["physical_keycode"] = ev.physical_keycode
		d["alt"] = ev.alt_pressed
		d["shift"] = ev.shift_pressed
		d["ctrl"] = ev.ctrl_pressed
		d["meta"] = ev.meta_pressed
	elif ev is InputEventJoypadButton:
		d["type"] = "joy_button"
		d["button_index"] = ev.button_index
		d["pressed"] = ev.pressed

	elif ev is InputEventJoypadMotion:
		d["type"] = "joy_axis"
		d["axis"] = ev.axis
		d["value"] = ev.axis_value  # e.g. -1..1 for stick/trigger direction

	elif ev is InputEventMouseButton:
		d["type"] = "mouse_button"
		d["button_index"] = ev.button_index
		d["pressed"] = ev.pressed
	# Add more types if needed: InputEventMouseButton, InputEventJoypadButton, etc.
	
	return d
