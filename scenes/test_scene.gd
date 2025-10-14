extends Node2D

var num_deaths:int = 0
var death_dict:Dictionary[int,Dictionary] = {}
var player:Player
var enemies:Array = []
var num_times_drilled:int = 0
var drill_dict:Dictionary[int,Dictionary] = {}
var enemies_killed:int = 0
var enemy_killed_dict:Dictionary = {}
var times_dashed:int = 0
var dash_dict:Dictionary[int,Dictionary] = {}

var folder_path:String = "user://test_data"
var save_path:String = folder_path + "/testing_data.json"

var time_to_complete_level:float = 0

var time:float = 0

func _physics_process(delta: float) -> void:
	time += delta # Update time passed

func _ready() -> void:
	GameManager.set_meter.emit(0)
	player = get_tree().get_nodes_in_group("player")[0] as Player
	player.drill_component.entered_drill_mode.connect(_increment_times_drilled)
	player.dash_component.dash_start.connect(_increment_times_dashed)
	#player.health_component.died.connect(_increment_deaths)
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemies.append(enemy)
		((enemy as Enemy).get_node("HitBox") as HitBox).hit_something.connect(_add_player_died_to)
		(enemy as Enemy).died.connect(_increment_enemies_killed)
	
	tree_exiting.connect(_save_all_data)
	
	$FinishLevel.body_entered.connect(_finish_level_set_time)


func _finish_level_set_time(_body) -> void:
	GameManager.stop_timer.emit()
	time_to_complete_level = GameManager.get_current_time()
	$CanvasLayer/Label.show()
	$CanvasLayer/Label.text = "Level Complete\nTime = " + str(time_to_complete_level) + "\nEsc to Pause and go to Main Menu"



func _increment_times_dashed(value:Vector2 = Vector2.ZERO) -> void:
	times_dashed += 1
	dash_dict[times_dashed] = {"start_pos":player.global_position, "time":time}


func _increment_enemies_killed(enemy:Enemy) -> void:
	enemies_killed += 1
	enemy_killed_dict[enemies_killed] = enemy.name


func _increment_times_drilled() -> void:
	num_times_drilled += 1
	drill_dict[num_times_drilled] = {"start_drill_pos":player.global_position, "start_time":time}
	print("Drilled ", num_times_drilled)

func _increment_deaths() -> void:
	#num_deaths += 1
	#death_dict[num_deaths] = [player.global_position, Engine.get_physics_frames()]
	print(num_deaths)

func _add_player_died_to(enemy:Enemy, character_hit) -> void:
	if character_hit == player:
		num_deaths += 1
		
		death_dict[num_deaths] = {"player_pos":player.global_position,"time_passed":time, "frame":Engine.get_physics_frames(), "enemy_name":enemy.name}
		print("Death Dict: ", death_dict[num_deaths])


func _save_all_data() -> void:
	# Create the directories needed to save the file
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	# Create variables to store path of folders and the saved keylog
	var temp_name:String = "testing_data"
	var value:int = 0
	
	# Make a new file with the correct value
	while FileAccess.file_exists(folder_path + "/" + temp_name + str(value) + ".json"):
		value += 1
	
	# Create the new save_path
	save_path = folder_path + "/" + temp_name + str(value) + ".json"
	
	# Open the file for writing
	var file:FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	
	file.store_string("{\n\"Death_Dict\":[\n") # Start the file with proper JSON syntax
	
	# Store the Death Dictionary
	file.store_string(JSON.stringify(JSON.from_native(death_dict), "\t", true) + "\n")
	file.store_string("],") # Start the next Set of Data
	
	# Store the number of deaths
	file.store_string("\n\"Num_Deaths\":[\n") 
	file.store_string(JSON.stringify(JSON.from_native(num_deaths), "\t", true) + "\n") 
	
	file.store_string("],") # End this set of data
	
	# Store the number of times drilled
	file.store_string("\n\"Num_Times_Drilled\":[\n") 
	file.store_string(JSON.stringify(JSON.from_native(num_times_drilled), "\t", true) + "\n") 
	
	file.store_string("],") # End this set of data
	
	# Store the number of enemies killed
	file.store_string("\n\"Drill_Dictionary\":[\n") 
	file.store_string(JSON.stringify(JSON.from_native(drill_dict), "\t", true) + "\n") 
	
	file.store_string("],") # End this set of data
	
	# Store the number of enemies killed
	file.store_string("\n\"Enemies_Killed\":[\n") 
	file.store_string(JSON.stringify(JSON.from_native(enemies_killed), "\t", true) + "\n") 
	
	file.store_string("],") # End this set of data
	
	# Store the number of enemies killed
	file.store_string("\n\"Enemies_Killed_Dictionary\":[\n") 
	file.store_string(JSON.stringify(JSON.from_native(enemy_killed_dict), "\t", true) + "\n") 
	
	file.store_string("],") # End this set of data
	
	# Store the number of times dashed 
	file.store_string("\n\"Num_Times_Dashed\":[\n") 
	file.store_string(JSON.stringify(JSON.from_native(times_dashed), "\t", true) + "\n") 
	
	file.store_string("],") # End this set of data
	
	# Store the dash extra information
	file.store_string("\n\"Dash_Dictionary\":[\n") 
	file.store_string(JSON.stringify(JSON.from_native(dash_dict), "\t", true) + "\n") 
	
	file.store_string("],") # End this set of data
	
	# Store the time it took to beat the level
	file.store_string("\n\"Level_Complete_Time\":[\n") 
	file.store_string(JSON.stringify(JSON.from_native(time_to_complete_level), "\t", true) + "\n") 
	
	file.store_string("]\n}") # End this set of data
	
	file.close()
