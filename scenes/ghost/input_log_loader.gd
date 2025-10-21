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

# Is emitted when the key array index value is changed
signal key_array_index_changed(new_value:int)

## Skip to a specfic frame of the input replay
@export var remove_up_to_frame:int = 0

# Keeps all the pressed keys read from the input log
var key_array:Array = []

# Keeps track of the current index in the key array of the input that is being played
var key_array_index:int = 0:
	set(new_value):
		key_array_index = new_value
		key_array_index_changed.emit(key_array_index)

var pause_playback:bool = false:
	set(new_value):
		pause_playback = new_value

# Keeps track of the current time passed to keep input replay accurate
var elapsed_time:float = 0.0

# Keeps track of the physics frames that have passed
var current_counted_frames:int = 0

# Keeps track of the frame and the dictionary related to that frame
# and can be used to scrub through playback
var frame_to_input_dict:Dictionary[int, Dictionary] = {}

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
	
	# Update the remove_up_to_frame value to the first input frame
	remove_up_to_frame = find_first_input()
	# Skip to the first input value
	skip_to_frame(remove_up_to_frame)
	
	frame_to_input_dict = set_up_frame_to_dict()


# Pauses the playback
func _enable_pause_playback(any=null) -> void:
	pause_playback = true
	
	var parent:Ghost = get_parent() as Ghost
	parent.movement_component.disable_movement_component = true
	parent.drill_component._disable_drill()

# Unpauses the playback
func _disable_pause_playback(any=null) -> void:
	pause_playback = false
	
	var parent:Ghost = get_parent() as Ghost
	parent.movement_component.disable_movement_component = false


# Changes the current replay frame
func change_current_replay_frame(change_value:int) -> void:
	_set_replay_frame(key_array_index+change_value)



# Sets the current frame to the passed in value
func _set_replay_frame(set_value:float) -> void:
	
	var value:int = int(set_value)
	
	if value >= len(key_array) or value < 0:
		return
	
	current_counted_frames = key_array[value]["frame"]
	
	key_array_index = frame_to_input_dict[current_counted_frames]["index"]
	
	elapsed_time = key_array[value]["elapsed_time"]
	

# Sets up the dictionary that connects frame to input log
func set_up_frame_to_dict() -> Dictionary[int, Dictionary]:
	var dict:Dictionary[int, Dictionary] = {}
	var temp_array:Array = key_array.duplicate()
	
	for i in range(len(temp_array)):
		dict[temp_array[i]["frame"]] = temp_array[i]
		dict[temp_array[i]["frame"]]["index"] = i
	#for dictionary in temp_array:
		#dict[dictionary["frame"]] = dictionary
	
	#print("Keys: ",dict.keys())
	return dict


# Finds the first input in the array
func find_first_input() -> int:
	var frame_first_input:int = 0
	
	var temp_array:Array = key_array.duplicate()
	
	# If the key array contains input data from the json file
	if len(temp_array) > 0:
		# Get the first input from the key array
		var dict:Dictionary = temp_array[0]
		
		# Check if the first recorded value has inputs
		if has_input(dict):
				frame_first_input = dict["frame"]
				return frame_first_input
		
		#has_input = "move_dir" in dict or "jump_dir" in dict or "is_jump_pressed" in dict or "dash_dir" in dict or "drill_dir" in dict
		while len(temp_array) > 1: # Check if it should be skipped
			temp_array.pop_front() # Remove the input from the array
			dict = temp_array[0] # Go to the next frame
			
			# If the dict has an input section
			if has_input(dict):
				frame_first_input = dict["frame"]
				return frame_first_input # Return the frame value
			
	
	# Returns the first frame that has input
	return frame_first_input


# Checks if the input dictionary has input values
func has_input(dict:Dictionary) -> bool:
	return "move_dir" in dict or "jump_dir" in dict or "is_jump_pressed" in dict or "dash_dir" in dict or "drill_dir" in dict


func skip_to_frame(remove_up_to_frame:int) -> void:
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
				#print("move_dir = ",dict["move_dir"])
				#pass
		# Close the file, since it was read fully already
		file.close()



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
	if OS.is_debug_build() and Input.is_action_pressed("ui_left"):
		#print("Going back 1 frames")
		change_current_replay_frame(-2)
		#print("New frame: ", current_counted_frames)
	elif OS.is_debug_build() and Input.is_action_pressed("ui_right"):
		#print("Going forward 1 frames")
		change_current_replay_frame(1)
		#print("New frame: ", current_counted_frames)
	
	
	if pause_playback:
		dash_inputs.emit(Vector2.ZERO) 
		jump_input.emit(Vector2.ZERO, false)
		movement_inputs.emit(Vector2.ZERO, delta)
		drill_inputs.emit(Vector2.ZERO)
		super_drill_inputs.emit(Vector2.ZERO)
		set_parent_data()
		return
	
	
	elapsed_time += delta # Update the elapsed time that has passed for input replaying
	current_counted_frames += 1 # Increment the current counted frames
	
	
	# If there are no more inputs to replay
	# Emit default inputs
	if len(key_array) <= 0 or key_array_index >= len(key_array): 
		dash_inputs.emit(Vector2.ZERO) 
		jump_input.emit(Vector2.ZERO, false)
		movement_inputs.emit(Vector2.ZERO, delta)
		drill_inputs.emit(Vector2.ZERO)
		super_drill_inputs.emit(Vector2.ZERO)
		return
	
	# Get the current input to replay
	var dict:Dictionary = key_array[key_array_index]
	
	# Make default values that should be emitted if no input is able to be read
	var dir:Vector2 = Vector2.ZERO
	var is_jump_pressed:bool = false
	var jump_direction:Vector2 = Vector2.ZERO
	var dash_dir:Vector2 = Vector2.ZERO
	var drill_dir:Vector2 = Vector2.ZERO
	var super_drill_dir:Vector2 = Vector2.ZERO
	
	
	# Check if the frame should be played
	# Add the offset to the current Engine frames
	if dict["frame"] <= remove_up_to_frame + current_counted_frames and dict["elapsed_time"] <= elapsed_time:
		# Grab the current input from the array
		dict = key_array[key_array_index]
		key_array_index += 1 # increment the index
		
		
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


func set_parent_data() -> void:
	var dict = key_array[key_array_index]
	
	# Get the parent so it can be updated
	var parent = get_parent() as CharacterBody2D
	
	if "flip" in dict:
		parent.animated_sprite.flip_h = dict["flip"]
	
	if "rot" in dict: # Update the basic stats of parent to keep replay accurate
		parent.rotation = dict["rot"]
		
		
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
	
	

	return
