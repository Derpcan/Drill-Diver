extends Node
class_name PlayerStatLoaderComponent


@export var json_loader:JSONLoader

@export var movement_component:MovementComponent
@export var jump_component:JumpComponent


func _ready() -> void:
	# Check if the JSON file exists
	if not json_loader.json_file:
		return # Return early if the file doesn't exist
	
	load_movement_data()
	
	load_jump_data()


func load_movement_data() -> void:
	# Get the dictionary from the JSON file that contains data for movement component
	var movement_dict:Dictionary = json_loader.json_file.data["player"]["stats"]["movement"]
	
	# Get each data value from the dictionary
	var max_speed:float = movement_dict["max_speed"]
	var accel:float = movement_dict["acceleration"]
	var friction:float = movement_dict["friction"]
	
	# Assign the data to the movement component
	movement_component.max_speed = max_speed
	movement_component.accel = accel
	movement_component.friction = friction
	
	print("Successfully loaded Movement Data from JSON file.")

func load_jump_data() -> void:
	# Get the dictionary from the JSON file that contains data for jump component
	var jump_dict:Dictionary = json_loader.json_file.data["player"]["stats"]["jump"]
	
	# Get each data value from the dictionary
	var jump_height:float = jump_dict["jump_height"]
	var input_jump_delay:float = jump_dict["input_jump_delay_forgiveness"]
	
	
	# Assign the data to the movement component
	jump_component.jump_speed = jump_height
	jump_component.input_jump_delay = input_jump_delay
	
	
	print("Successfully loaded Jump Data from JSON file.")
