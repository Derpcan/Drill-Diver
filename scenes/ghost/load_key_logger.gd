extends Node
class_name KeyLogLoader


@export var json_name:String = "keylog0.JSON"

signal movement_inputs(direction:Vector2, delta:float)
signal jump_input(dir:Vector2, is_pressed:bool)
signal dash_inputs(direction:Vector2)
signal drill_inputs(direction:Vector2)

var key_array:Array = []

func _ready() -> void:
	_load_key_log_json()


func _load_key_log_json() -> void:
	# Create variables to store path of folders and the saved animation file
	var folder_path:String = "user://test_data/keylogs"
	var save_path:String = folder_path + "/" + json_name
	
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
	
	var dir:Vector2 = Vector2.ZERO
	var is_jump_pressed:bool = false
	var jump_direction:Vector2 = Vector2.ZERO
	var dash_dir:Vector2 = Vector2.ZERO
	var drill_dir:Vector2 = Vector2.ZERO
	
	if (dict["frame"] == Engine.get_physics_frames()):
		#print("Frame is correct")
		key_array.pop_front()
		if dict["frame"] % 30 == 0:
			var parent = get_parent() as CharacterBody2D
			parent.rotation = dict["rot"]
			parent.position = dict["pos"]
			parent.velocity = dict["vel"]
	else:
		dash_inputs.emit(dash_dir)
		jump_input.emit(jump_direction, is_jump_pressed)
		movement_inputs.emit(dir, delta)
		drill_inputs.emit(drill_dir)
		return
	
	
	
	# Get the direction of the characters input
	if dict.has("move_dir"):
		dir = dict["move_dir"] as Vector2
	if dict.has("is_jump_pressed"):
		is_jump_pressed = dict["is_jump_pressed"] as bool
	if dict.has("jump_dir"):
		jump_direction = dict["jump_dir"] as Vector2
	if dict.has("dash_dir"):
		dash_dir = dict["dash_dir"] as Vector2
	if dict.has("drill_dir"):
		drill_dir = dict["drill_dir"] as Vector2
	
	dash_inputs.emit(dash_dir)
	jump_input.emit(jump_direction, is_jump_pressed)
	movement_inputs.emit(dir, delta)
	drill_inputs.emit(drill_dir)
	
