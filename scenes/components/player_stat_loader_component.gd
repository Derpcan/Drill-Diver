extends Node
class_name PlayerStatLoaderComponent


@export var json_loader:JSONLoader

@export var movement_component:MovementComponent
@export var jump_component:JumpComponent
@export var dash_component:DashComponent
@export var drill_component:DrillComponent

@export_category("Debug Colors")
@export var movement_debug_color:Color
@export var jump_debug_color:Color
@export var dash_debug_color:Color
@export var drill_debug_color:Color


func _ready() -> void:
	# Check if the JSON file exists
	if not json_loader.json_file:
		return # Return early if the file doesn't exist
	
	load_movement_data()
	
	load_jump_data()
	
	load_dash_data()
	
	load_drill_data()

func load_drill_data() -> void:
	if not drill_component:
		return
	
	var drill_dict:Dictionary = json_loader.json_file.data["player"]["stats"]["drill"]
	
	var drill_speed:float = drill_dict["drill_speed"]
	var turn_speed:float = drill_dict["turn_speed"]
	
	drill_component.drill_speed = drill_speed
	drill_component.turn_speed = turn_speed
	
	print_rich("[color=",drill_debug_color.to_html(false),"]Successfully loaded Drill Data from JSON file.")

func load_movement_data() -> void:
	if not movement_component:
		return
	
	# Get the dictionary from the JSON file that contains data for movement component
	var movement_dict:Dictionary = json_loader.json_file.data["player"]["stats"]["movement"]
	
	# Get each data value from the dictionary
	var max_speed:float = movement_dict["max_speed"]
	var accel:float = movement_dict["acceleration"]
	var friction:float = movement_dict["friction"]
	
	# Assign the data to the movement component
	movement_component.max_speed = max_speed
	movement_component.og_max_speed = max_speed
	movement_component.accel = accel
	movement_component.friction = friction
	print_rich("[color=",movement_debug_color.to_html(false),"]Successfully loaded Movement Data from JSON file.")
	#print("Successfully loaded Movement Data from JSON file.")

func load_jump_data() -> void:
	if not jump_component:
		return
	
	# Get the dictionary from the JSON file that contains data for jump component
	var jump_dict:Dictionary = json_loader.json_file.data["player"]["stats"]["jump"]
	
	# Get each data value from the dictionary
	var jump_height:float = jump_dict["jump_height"]
	var input_jump_delay:float = jump_dict["input_jump_delay_forgiveness"]
	
	
	# Assign the data to the movement component
	jump_component.jump_speed = jump_height
	jump_component.input_jump_delay = input_jump_delay
	print_rich("[color=",jump_debug_color.to_html(false),"]Successfully loaded Jump Data from JSON file.")
	#print("Successfully loaded Jump Data from JSON file.")

func load_dash_data() -> void:
	if not dash_component:
		return
	
	# Get the dictionary from the JSON file that contains data for dash component
	var dash_dict:Dictionary = json_loader.json_file.data["player"]["stats"]["dash"]
	
	# Get each data value from the dictionary
	var dash_speed:float = dash_dict["dash_speed"]
	var dash_time:float = dash_dict["dash_time"]
	
	
	# Assign the data to the movement component
	dash_component.dash_speed = dash_speed
	dash_component.dash_time = dash_time
	
	print_rich("[color=",dash_debug_color.to_html(false),"]Successfully loaded Dash Data from JSON file.")
	#print("Successfully loaded Dash Data from JSON file.")
