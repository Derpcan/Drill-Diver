extends Node
class_name KeyLogLoader


@export var json_name:String = "inputlog0.json"
var folder_path:String = "user://test_data/inputlogs"

signal movement_inputs(direction:Vector2, delta:float)
signal jump_input(dir:Vector2, is_pressed:bool)
signal dash_inputs(direction:Vector2)
signal drill_inputs(direction:Vector2)
signal super_drill_inputs(direction:Vector2)

@export var remove_up_to_frame:int = 0

var key_array:Array = []
var elapsed_time:float = 0.0

func _ready() -> void:
	var parent = get_parent() as Ghost
	json_name = parent.input_log_file_name
	folder_path = parent.input_log_folder_path
	remove_up_to_frame = parent.remove_up_to_frame
	_load_key_log_json()


func _load_key_log_json() -> void:
	# Create variables to store path of folders and the saved animation file
	
	var save_path:String = folder_path + "/" + json_name
	
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		
		if json_string == "": # See if the file is empty
			return
		
		var json = JSON.parse_string(json_string)
		if json != null:
			var native = JSON.to_native(json["D"])
			key_array = native
			
			for dict in native:
				#print("move_dir = ",dict["move_dir"])
				pass
		file.close()
	
	var frame:int = 0
	
	if len(key_array) > 0:
		var dict:Dictionary = key_array[0]
		frame = dict["frame"]
		while frame < remove_up_to_frame:
			key_array.pop_front()
			dict = key_array[0]
			frame = dict["frame"]
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
	elapsed_time += delta
	if len(key_array) <= 0:
		return
	var check_dict:Dictionary = key_array[0]
	var dict:Dictionary = key_array[0]
	
	var dir:Vector2 = Vector2.ZERO
	var is_jump_pressed:bool = false
	var jump_direction:Vector2 = Vector2.ZERO
	var dash_dir:Vector2 = Vector2.ZERO
	var drill_dir:Vector2 = Vector2.ZERO
	var super_drill_dir:Vector2 = Vector2.ZERO
	# Check if it is the right time to play the inputs
	#if (dict["elapsed_time"] >= elapsed_time):
		#dash_inputs.emit(dash_dir)
		#jump_input.emit(jump_direction, is_jump_pressed)
		#movement_inputs.emit(dir, delta)
		#drill_inputs.emit(drill_dir)
		#return
	if dict["frame"] <= remove_up_to_frame + Engine.get_physics_frames():#dict["elapsed_time"] <= elapsed_time :#and dict["frame"] <= Engine.get_physics_frames():
		#while dict["elapsed_time"] <= elapsed_time: #and dict["frame"] <= Engine.get_physics_frames():
		#	check_dict = dict
		dict = key_array.pop_front()
		#print(dict["elapsed_time"], " : ", elapsed_time)
		#print(check_dict["elapsed_time"], " : ", elapsed_time)
		#key_array.insert(0, dict)
		#dict = check_dict
		
		#if "rot" in dict.keys():# and dict["frame"] % 30 == 0:#"rot" in dict.keys():#dict["frame"] % 1 == 0:
		var parent = get_parent() as CharacterBody2D
		if "rot" in dict:
			parent.rotation = dict["rot"]
			parent.position = dict["pos"]
			parent.velocity = dict["vel"]
			
			var drill:DrillComponent = (parent.drill_component as DrillComponent)
			var state_machine:StateMachine = (parent.state_machine as StateMachine)
			state_machine._enter_state(dict["state"])
			if dict["state"] == "drill":
				state_machine._enter_state("drill")
				drill._enter_drill_state(null)
			else:
				#state_machine._enter_state("jump")
				if drill.drill_enabled:
					drill._exit_drill_state(null)
		
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
		if dict.has("super_drill_dir"):
			super_drill_dir = dict["super_drill_dir"] as Vector2
	
	
	dash_inputs.emit(dash_dir)
	jump_input.emit(jump_direction, is_jump_pressed)
	movement_inputs.emit(dir, delta)
	drill_inputs.emit(drill_dir)
	super_drill_inputs.emit(super_drill_dir)
	
