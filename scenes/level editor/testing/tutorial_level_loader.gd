extends Node2D
class_name TutorialLevelLoader

## Temporary to test Completion Times and Ending screen
@export var s_rank_time:float = 10000

@export var goal:Goal

@export var opening:OpeningScene


@export var level_file_path:String = "":
	set(new_path):
		level_file_path = new_path

@export var physics_tilemap:TileMapLayer
@export var decorative_tilemap:TileMapLayer


@export var object_node:Node2D


@export var to_level_select:CanvasLayer

var ghost_file_name:String:
	set(new_file_name):
		ghost_file_name = new_file_name + ".ghst"
		
		print(ghost_file_name)


var ghost_folder_path:String = "user://ghosts/"



func _relay_time_got_to_player(new_value:float) -> void:
	var input_logger:KeyLogger = (opening.get_node("Player").get_node("InputLogger") as KeyLogger)
	input_logger.time_to_beat_level = new_value



func load_ghost_path() -> void:
	$Ghost.input_component.folder_path = ghost_folder_path
	$Ghost.input_component.json_name = ghost_file_name



func _ready() -> void:
	ghost_file_name = _slice_level_file_path_to_name(level_file_path)
	set_up_folder_directory(ghost_folder_path)
	
	if not check_file_exists(ghost_folder_path + ghost_file_name):
		$Ghost.queue_free()
	
	set_up_player_input_saver()
	load_ghost_path()
	load_logic(level_file_path)
	opening._play_break_out()


func set_up_player_input_saver() -> void:
	var input_logger:KeyLogger = (opening.get_node("Player").get_node("InputLogger") as KeyLogger)
	input_logger.folder_path = ghost_folder_path
	input_logger.file_name = ghost_file_name


static func check_file_exists(file_path:String) -> bool:
	return FileAccess.file_exists(file_path)


static func set_up_folder_directory(folder_path:String) -> void:
	# Create the directories needed to save the file
	DirAccess.make_dir_recursive_absolute(folder_path)



static func _slice_level_file_path_to_name(file_path:String) -> String:
	var last_slash:int = file_path.rfind("/")
	
	var last_dot:int = file_path.find(".", last_slash)
	
	var output:String = file_path.substr(last_slash+1, last_dot)
	output = output.trim_suffix(".lvl")
	
	return output




var selected_tile:String = "Ground"
var selected_object:PackedScene = null
var object_string:String = ""

var background_type:String = "Cave Background":
	set(new_string):
		background_type = new_string
		
		if background_type == "Lab Background":
			$LabBackground.show()
			$CaveBackground.hide()
		if background_type == "Cave Background":
			$LabBackground.hide()
			$CaveBackground.show()

enum tile_types {
	UNDRILLABLE, # Hard material, used for floors or roofs that can't be passed
	DRILLABLE, # Material you can drill through
	SUPERDRILLABLE, # Material you need super drill to get through
	UNDRILLABLE_UP_STAIR_RIGHT,
	UNDRILLABLE_UP_STAIR_LEFT,
	UNDRILLABLE_DOWN_STAIR_RIGHT,
	UNDRILLABLE_DOWN_STAIR_LEFT,
}


# Keeps track of unique locations and stores the associated object at the location
var tile_pos_to_object_dictionary:Dictionary[Vector2i, Dictionary] = {
	
}

# This will be saved in the custom level resource
var object_string_name_to_tile_pos:Dictionary[String, Array] = {
	
}


# This will keep track of bonus parameters at a specific tile
var tile_pos_to_bonus_parameters:Dictionary[Vector2i, Dictionary] = {
	
}









var decorative_source_id_to_tile_name:Dictionary = {
	0:"Ground",
	1:"SuperDrillable",
	2:"Dirt",
}

func load_logic(path_name:String="") -> void:
	
	
	# Load level from json file
	if FileAccess.file_exists(path_name):
		
		# Open the json file for reading
		var file:FileAccess = FileAccess.open(path_name, FileAccess.READ)
		
		# Get the text from the file
		var json_string = file.get_as_text()
		
		if json_string == "": # See if the file is empty
			return # Return early to not cause any errors
		
		# Parse the text from the file in json style
		var json = JSON.parse_string(json_string)
		if json != null: # If there was no error parsing the text
			
			# Get the decorative tilemap data if it exists
			var decorative_tilemap_data:Dictionary[int, Array] = {}
			if "DecorativeTilemap" in json:
				decorative_tilemap_data = JSON.to_native(json["DecorativeTilemap"])
			
			# Get bonus params if they exist in the file
			var tile_pos_to_bonus_params:Dictionary[Vector2i, Dictionary] = {}
			if "TilePosBonusParameters" in json:
				tile_pos_to_bonus_params = JSON.to_native(json["TilePosBonusParameters"])
			
			# Load the background type if it exists
			if "BackgroundType" in json:
				background_type = JSON.to_native(json["BackgroundType"])
			
			
			var object_string_tile_pos = {}
			if "ObjectStringTilePos" in json:
				object_string_tile_pos = JSON.to_native(json["ObjectStringTilePos"])
			
			
			selected_object = null
			object_string = ""
			
			var object_bonus_parameters = {}
			
			
			if decorative_tilemap_data:
				for id:int in LevelEditor.decorative_source_id_to_tile_name.keys():#range(len(decorative_tilemap_data)):
					if decorative_tilemap_data.has(id):
						for pos:Vector2i in decorative_tilemap_data[id]:
							selected_tile = LevelEditor.decorative_source_id_to_tile_name[id]
							LevelEditor.static_set_tile(physics_tilemap, "Physics", pos, selected_object, selected_tile, object_string, object_node, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters, object_string_name_to_tile_pos, object_bonus_parameters, true)
							LevelEditor.static_set_tile(decorative_tilemap, "Decorative", pos, selected_object, selected_tile, object_string, object_node, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters, object_string_name_to_tile_pos, object_bonus_parameters, true)
			
			#if decorative_tilemap_data:
				#for id in range(len(decorative_tilemap_data)):
					#for pos:Vector2i in decorative_tilemap_data[id]:
						#selected_tile = decorative_source_id_to_tile_name[id]
						#LevelEditor.static_set_tile(physics_tilemap, "Physics", pos, selected_object, selected_tile, object_string, object_node, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters, object_string_name_to_tile_pos, object_bonus_parameters, true)
						#LevelEditor.static_set_tile(decorative_tilemap, "Decorative", pos, selected_object, selected_tile, object_string, object_node, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters, object_string_name_to_tile_pos, object_bonus_parameters, true)
			
			
			selected_tile = "Ground"
			
			# Load the bonus paramaters from the JSON file
			tile_pos_to_bonus_parameters = tile_pos_to_bonus_params
			
			# Load Objects
			for object_key in object_string_tile_pos.keys():
				for pos:Vector2i in object_string_tile_pos[object_key]:
					selected_object = LevelEditor.object_dictionary[object_key]
					object_string = object_key
					
					if pos in tile_pos_to_bonus_parameters:
						object_bonus_parameters = tile_pos_to_bonus_parameters[pos]
					else:
						object_bonus_parameters = {}
					
					
					LevelEditor.static_set_tile(physics_tilemap, "Physics", pos, selected_object, selected_tile, object_string, object_node, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters, object_string_name_to_tile_pos, object_bonus_parameters, true)
					#set_tile(physics_tilemap, pos)
					
					# Set the player's spawn
					if object_string == "Spawnpoint":
						var obj:Node2D = tile_pos_to_object_dictionary[object_string_name_to_tile_pos[object_string][0]]["object"]
						
						opening.global_position = obj.global_position
						opening.global_position.y -= 5
						$GameCamera.global_position = opening.global_position
						$Ghost.global_position = opening.global_position
						$CheckpointManager.last_checkpoint_position = opening.global_position
						pass
						
					
					if object_string == "Goal":
						var obj:Goal = tile_pos_to_object_dictionary[object_string_name_to_tile_pos[object_string][0]]["object"]
						obj.score_shown.connect(to_level_select._make_visible)
						goal = obj
						goal.new_time_got.connect(_relay_time_got_to_player)
						goal.new_time_got.connect(_compare_old_and_new_times)
			
			
			if "BestTimeCompleted" in json:
				s_rank_time = JSON.to_native(json["BestTimeCompleted"])
			print(s_rank_time)
			
			
			object_string = ""
			selected_object = null
			file.close()
			BetterTerrain.update_terrain_cells(decorative_tilemap, decorative_tilemap.get_used_cells())
			fix_physics_tile_map()
			
			



func _compare_old_and_new_times(new_time:float) -> void:
	var old_time:float = -1
	
	var file_path:String = ghost_folder_path + ghost_file_name
	# Checks to see if a ghost already exists and if the time to beat is better
	if FileAccess.file_exists(file_path):
		var file:FileAccess = FileAccess.open(file_path, FileAccess.READ)
		
		# Get the text from the file
		var json_string = file.get_as_text()
		
		
		if json_string == "": # See if the file is empty
			return # Return early to not cause any errors
		
		# Parse the text from the file in json style
		var json = JSON.parse_string(json_string)
		if json.has("BestTime"):
			old_time = JSON.to_native(json["BestTime"])
	
	
	# Can use these values to determine which is better
	# Old_time will be -1 if there wasn't a previous time
	print("OLD: ", old_time)
	print("NEW: ", new_time)
	



func fix_physics_tile_map() -> void:
	for tile_position:Vector2i in decorative_tilemap.get_used_cells():
		var tile_atlas_coords:Vector2i = decorative_tilemap.get_cell_atlas_coords(tile_position)
		var source_id:int = decorative_tilemap.get_cell_source_id(tile_position)
		if LevelEditor.decorative_tiles_slope_to_physics_slope.has(tile_atlas_coords) and source_id == 6:
			var new_tile_data = LevelEditor.physics_tile_type_to_tile_data_dictionary[LevelEditor.decorative_tiles_slope_to_physics_slope[tile_atlas_coords]]
			physics_tilemap.set_cell(tile_position, new_tile_data[0], new_tile_data[1], new_tile_data[2])
		else:
			selected_tile = LevelEditor.decorative_source_id_to_tile_name[source_id]
			var tile_data:Array = LevelEditor.static_get_tile(physics_tilemap, selected_tile)["Physics"]
			var source_id2:int = tile_data[0]
			var atlas_coord:Vector2i = tile_data[1]
			var alt_tile:int = tile_data[2]
			physics_tilemap.set_cell(tile_position, source_id2, atlas_coord, alt_tile)


func load_level() -> void:
	pass
