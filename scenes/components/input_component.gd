extends Node
class_name InputComponent


signal movement_inputs(direction:Vector2, delta:float)
signal jump_input(dir:Vector2, is_pressed:bool)
signal dash_inputs(direction:Vector2)
signal drill_inputs(direction:Vector2)

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
	# Get the direction of the characters input
	var dir:Vector2 = Vector2(Input.get_action_strength("move_right")-Input.get_action_strength("move_left"), 0).normalized()
	var is_jump_pressed:bool = false
	var jump_direction:Vector2 = Vector2.ZERO
	var dash_dir:Vector2 = Vector2.ZERO
	if Input.is_action_pressed("jump"):
		is_jump_pressed = true
		jump_direction = Vector2.UP
	
	if Input.is_action_just_pressed("dash"):
		var dir_x:float = Input.get_action_strength("move_right")-Input.get_action_strength("move_left")
		var dir_y:float = Input.get_action_strength("move_down")-Input.get_action_strength("move_up")
		
		
		dash_dir = turn_vector_into_8_directions(Vector2(round_to_8_directions(dir_x), round_to_8_directions(dir_y)))
		print("Dash direction: ",dash_dir)
	var drill_x:float = Input.get_action_strength("move_right")-Input.get_action_strength("move_left")
	var drill_y:float = Input.get_action_strength("move_down")-Input.get_action_strength("move_up")
	var drill_dir:Vector2 = Vector2(drill_x, drill_y)
	dash_inputs.emit(dash_dir)
	jump_input.emit(jump_direction, is_jump_pressed)
	movement_inputs.emit(dir, delta)
	drill_inputs.emit(drill_dir)
	
	log_key_input(dir, jump_direction, is_jump_pressed, dash_dir, drill_dir)


func round_to_8_directions(value:float) -> float:
	if value >= 0.25 and value < 0.75:
		value = 0.5
	elif -0.25 < value and value < 0.25:
		value = 0
	elif value <= -0.25 and value > -0.75:
		value = -0.5
	elif value <= -0.75:
		value = -1
	else:
		value = 1
	return value

func turn_vector_into_8_directions(vec:Vector2) -> Vector2:
	var half = sqrt(3)/2
	if vec.x > 0 and vec.y > 0:
		vec.x = half
		vec.y = half
	if vec.x < 0 and vec.y < 0:
		vec.x = -half
		vec.y = -half
	if vec.x > 0 and vec.y < 0:
		vec.x = half
		vec.y = -half
	if vec.x < 0 and vec.y > 0:
		vec.x = -half
		vec.y = half
	
	return vec



func _ready() -> void:
	_set_up_key_logger()
	tree_exiting.connect(_exiting)


var key_log:Array = []
var file:FileAccess

func _set_up_key_logger() -> void:
	# Create variables to store path of folders and the saved animation file
	var folder_path:String = "res://save_info"
	var save_path:String = folder_path + "/" + "keylog.JSON"
	
	if FileAccess.file_exists(save_path):
		file = FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.parse_string(json_string)
		if json != null:
			var native = JSON.to_native(json["D"])
			for dict in native:
				print("move_dir = ",dict["move_dir"])
		file.close()
	#get_tree().quit.call_deferred()
	#return
	file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string("{\n\"D\":[\n")
	
	# Create folders needed for storing the key log info if they don't exist
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	#var file = FileAccess.open(save_path, FileAccess.READ)
	

	

func log_key_input(movement_dir:Vector2, jump_direction:Vector2, is_jump_pressed:bool, dash_dir:Vector2, drill_vector:Vector2) -> void:
	
	# Save the keys pressed each frame into a dictionary to save into JSON
	var keys_pressed_dict:Dictionary = {}
	keys_pressed_dict["move_dir"] = movement_dir
	keys_pressed_dict["jump_dir"] = jump_direction
	keys_pressed_dict["is_jump_pressed"] = is_jump_pressed
	keys_pressed_dict["dash_dir"] = dash_dir
	keys_pressed_dict["drill_dir"] = drill_vector
	
	
	file.store_string(JSON.stringify(JSON.from_native(keys_pressed_dict), "\t", true) + ",\n")
	


func _exiting() -> void:
	var folder_path:String = "res://save_info"
	var save_path:String = folder_path + "/" + "keylog.JSON"
	file.store_string("]\n}")
	file.close()
	#var file:FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	return
	file.store_string(JSON.stringify(JSON.from_native(key_log), "\t", true) )
	file.close()
	
	
