extends Node
class_name KeyLogLoader

@export var json_loader:JSONLoader


signal movement_inputs(direction:Vector2, delta:float)
signal jump_input(dir:Vector2, is_pressed:bool)
signal dash_inputs(direction:Vector2)
signal drill_inputs(direction:Vector2)

var key_array:Array = []

func _ready() -> void:
	_load_key_log_json()


func _load_key_log_json() -> void:
	# Create variables to store path of folders and the saved animation file
	var folder_path:String = "res://save_info"
	var save_path:String = folder_path + "/" + "keylog.JSON"
	
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.parse_string(json_string)
		if json != null:
			var native = JSON.to_native(json["D"])
			key_array = native
			
			for dict in native:
				#print("move_dir = ",dict["move_dir"])
				pass
		file.close()
	#file.close()


# Functions from Input Component
var disabled_inputs:bool = false:
	set(new_val):
		disabled_inputs = new_val
		
		set_physics_process(not disabled_inputs)

func _disable_inputs() -> void:
	disabled_inputs = true

func _enable_inputs() -> void:
	disabled_inputs = false

# Get inputs during each physics process frame
func _physics_process(delta: float) -> void:
	if len(key_array) <= 0:
		return
	var dict:Dictionary = key_array[0]
	
	if (dict["frame"] == Engine.get_physics_frames()):
		#print("Frame is correct")
		key_array.pop_front()
	else:
		return
	
	# Get the direction of the characters input
	var dir:Vector2 = dict["move_dir"]
	var is_jump_pressed:bool = dict["is_jump_pressed"]
	var jump_direction:Vector2 = dict["jump_dir"]
	var dash_dir:Vector2 = dict["dash_dir"]
	var drill_dir:Vector2 = dict["drill_dir"]
	
	dash_inputs.emit(dash_dir)
	jump_input.emit(jump_direction, is_jump_pressed)
	movement_inputs.emit(dir, delta)
	drill_inputs.emit(drill_dir)
	
