extends Node
class_name KeyLogger

@export var input_component:InputComponent
var folder_path:String = "res://save_info"
var save_path:String = folder_path + "/keylog.JSON"

# Variable to keep track of the keys pressed this frame
var keys_pressed_current_frame_dict:Dictionary = {}:
	set(new_val):
		print(new_val)

func _ready() -> void:
	if not input_component:
		return
	
	input_component.all_inputs.connect(_log_key_input)
	_set_up_key_logger()
	
	tree_exiting.connect(_exiting)



var file:FileAccess

func _set_up_key_logger() -> void:
	# Create variables to store path of folders and the saved animation file
	var temp_name:String = "keylog"
	var value:int = 0
	
	while FileAccess.file_exists(folder_path + "/" + temp_name + str(value) + ".JSON"):
		value += 1
	
	save_path = folder_path + "/" + temp_name + str(value) + ".JSON"
	
	#if FileAccess.file_exists(save_path):
		#file = FileAccess.open(save_path, FileAccess.READ)
		#var json_string = file.get_as_text()
		#var json = JSON.parse_string(json_string)
		#if json != null:
			#var native = JSON.to_native(json["D"])
			#for dict in native:
				##print("move_dir = ",dict["move_dir"])
				#pass
		#file.close()
	#get_tree().quit.call_deferred()
	#return
	file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string("{\n\"D\":[\n")
	
	# Create folders needed for storing the key log info if they don't exist
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	#var file = FileAccess.open(save_path, FileAccess.READ)
	



func _log_key_input(movement_dir:Vector2, jump_direction:Vector2, is_jump_pressed:bool, dash_dir:Vector2, drill_vector:Vector2) -> void:
	
	# Save the keys pressed each frame into a dictionary to save into JSON
	var keys_pressed_dict:Dictionary = {}
	keys_pressed_dict["move_dir"] = movement_dir
	keys_pressed_dict["jump_dir"] = jump_direction
	keys_pressed_dict["is_jump_pressed"] = is_jump_pressed
	keys_pressed_dict["dash_dir"] = dash_dir
	keys_pressed_dict["drill_dir"] = drill_vector
	keys_pressed_dict["frame"] = Engine.get_physics_frames()
	
	
	file.store_string(JSON.stringify(JSON.from_native(keys_pressed_dict), "\t", true) + ",\n")
	


func _exiting() -> void:
	var folder_path:String = "res://save_info"
	var save_path:String = folder_path + "/" + "keylog.JSON"
	file.store_string("]\n}")
	file.close()
