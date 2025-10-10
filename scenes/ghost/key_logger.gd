extends Node
class_name KeyLogger
## Logs the keys pressed in a given frame, gets inputs from the InputComponent


@export var input_component:InputComponent
var folder_path:String = "user://test_data/keylogs"
var save_path:String = folder_path + "/keylog.JSON"



func _ready() -> void:
	if not input_component:
		return
	
	print("Test Data is found in: ", OS.get_user_data_dir() + "/test_data/")
	
	# Connect the input components inputs
	input_component.all_inputs.connect(_log_key_input)
	_set_up_key_logger() # Set up the key logger data and files
	
	tree_exiting.connect(_exiting)



var file:FileAccess

func _set_up_key_logger() -> void:
	# Create the directories needed to save the file
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	# Create variables to store path of folders and the saved keylog
	var temp_name:String = "keylog"
	var value:int = 0
	
	while FileAccess.file_exists(folder_path + "/" + temp_name + str(value) + ".JSON"):
		value += 1
	
	save_path = folder_path + "/" + temp_name + str(value) + ".JSON"
	
	# Open the file for writing
	file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string("{\n\"D\":[\n") # Start the file with proper JSON syntax
	
	


# Log the keys this frame from the InputComponent
func _log_key_input(movement_dir:Vector2, jump_direction:Vector2, is_jump_pressed:bool, dash_dir:Vector2, drill_vector:Vector2) -> void:
	# Save the keys pressed each frame into a dictionary to save into JSON
	var keys_pressed_dict:Dictionary = {}
	if movement_dir != Vector2.ZERO:
		keys_pressed_dict["move_dir"] = movement_dir
	
	if jump_direction != Vector2.ZERO:
		keys_pressed_dict["jump_dir"] = jump_direction
	if is_jump_pressed != false:
		keys_pressed_dict["is_jump_pressed"] = is_jump_pressed
	if dash_dir != Vector2.ZERO:
		keys_pressed_dict["dash_dir"] = dash_dir
	if drill_vector != Vector2.ZERO:
		keys_pressed_dict["drill_dir"] = drill_vector
	
	if not keys_pressed_dict.is_empty() or Engine.get_physics_frames() % 30 == 0:
		keys_pressed_dict["frame"] = Engine.get_physics_frames()
	
	if not keys_pressed_dict.is_empty() and keys_pressed_dict["frame"] % 30 == 0:
		var parent = get_parent() as CharacterBody2D
		keys_pressed_dict["rot"] = parent.rotation
		keys_pressed_dict["pos"] = parent.position
		keys_pressed_dict["vel"] = parent.velocity
	
	# only store in the JSON if the key script isnt empty
	if not keys_pressed_dict.is_empty():
		# Store the data with proper JSON syntax
		file.store_string(JSON.stringify(JSON.from_native(keys_pressed_dict), "\t", true) + ",\n")


# When the game is being closed we end the JSON string and then close the file
func _exiting() -> void:
	file.store_string("]\n}")
	file.close()
