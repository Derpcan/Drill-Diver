extends Node
class_name KeyLogLoader

## The json_name for the file that should be read of input logs
@export var json_name:String = "inputlog0.json"

# The folder path to the input logs
var folder_path:String = "user://test_data/inputlogs"

signal movement_inputs(direction:Vector2, delta:float)
signal jump_input(dir:Vector2, is_pressed:bool)
signal dash_inputs(direction:Vector2)
signal drill_inputs(direction:Vector2)
signal super_drill_inputs(direction:Vector2)

## Skip to a specfic frame of the input replay
@export var remove_up_to_frame:int = 0

# Keeps all the pressed keys read from the input log
var key_array:Array = []

# Keeps track of the current time passed to keep input replay accurate
var elapsed_time:float = 0.0


func _ready() -> void:
	# Get the parent as a Ghost (Since its the only object that can replay inputs)
	var parent = get_parent() as Ghost
	
	# If the parent has a different name for the json file, swap to the override
	json_name = parent.input_log_file_name
	
	# If the parent has a different name for the folder path, swap to the override
	folder_path = parent.input_log_folder_path
	
	# Get the parents skip to frame override
	remove_up_to_frame = parent.remove_up_to_frame
	
	# Load the key log file
	_load_key_log_json()


func _load_key_log_json() -> void:
	# Make a variable to store the path to the input log file
	var save_path:String = folder_path + "/" + json_name
	
	# Check if the file exists
	if FileAccess.file_exists(save_path):
		# If the file exists, open it for reading
		var file = FileAccess.open(save_path, FileAccess.READ)
		
		# Get the text from the file
		var json_string = file.get_as_text()
		
		if json_string == "": # See if the file is empty
			return # Return early to not cause any errors
		
		# Parse the text from the file in json style
		var json = JSON.parse_string(json_string)
		if json != null: # If there was no error parsing the text
			var native = JSON.to_native(json["D"]) # Convert json into native Godot types
			key_array = native # Update the key_array
			
			#
			#for dict in native:
				##print("move_dir = ",dict["move_dir"])
				#pass
		# Close the file, since it was read fully already
		file.close()
	
	# Make a temporary variable to help skip frames
	var frame:int = 0
	
	# If the key array contains input data from the json file
	if len(key_array) > 0:
		# Get the first input from the key array
		var dict:Dictionary = key_array[0]
		# Set frame equal to the first frame recorded in the inputs
		frame = dict["frame"]
		while frame < remove_up_to_frame: # Check if it should be skipped
			key_array.pop_front() # Remove the input from the array
			dict = key_array[0] # Go to the next frame
			frame = dict["frame"] # Update frame to next input frame value



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
	elapsed_time += delta # Update the elapsed time that has passed for input replaying
	
	# If there are no more inputs to replay
	# Emit default inputs
	if len(key_array) <= 0: 
		dash_inputs.emit(Vector2.ZERO) 
		jump_input.emit(Vector2.ZERO, false)
		movement_inputs.emit(Vector2.ZERO, delta)
		drill_inputs.emit(Vector2.ZERO)
		super_drill_inputs.emit(Vector2.ZERO)
		return
	
	# Get the current input to replay
	var check_dict:Dictionary = key_array[0]
	var dict:Dictionary = key_array[0]
	
	# Make default values that should be emitted if no input is able to be read
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
	
	# Check if the frame should be played
	# Add the offset to the current Engine frames
	if dict["frame"] <= remove_up_to_frame + Engine.get_physics_frames():#dict["elapsed_time"] <= elapsed_time :#and dict["frame"] <= Engine.get_physics_frames():
		#while dict["elapsed_time"] <= elapsed_time: #and dict["frame"] <= Engine.get_physics_frames():
		#	check_dict = dict
		# Remove the input from the array
		dict = key_array.pop_front()
		#print(dict["elapsed_time"], " : ", elapsed_time)
		#print(check_dict["elapsed_time"], " : ", elapsed_time)
		#key_array.insert(0, dict)
		#dict = check_dict
		
		#if "rot" in dict.keys():# and dict["frame"] % 30 == 0:#"rot" in dict.keys():#dict["frame"] % 1 == 0:
		
		# Get the parent so it can be updated
		var parent = get_parent() as CharacterBody2D
		if "rot" in dict: # Update the basic stats of parent to keep replay accurate
			parent.rotation = dict["rot"]
			
			parent.velocity = dict["vel"]
			
			# Get the drill component and state machine1
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
		
		# Update the position of the parent if it is in the dictionary
		if "pos" in dict:
			parent.position = dict["pos"]
		
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
	
