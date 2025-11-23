extends Node2D
class_name TestCustomLevelEditor


@export var level_file_path:String = "":
	set(new_path):
		level_file_path = new_path

@export var physics_tilemap:TileMapLayer
@export var decorative_tilemap:TileMapLayer


@export var object_node:Node2D

func _ready() -> void:
	load_logic(level_file_path)


var selected_tile:String = "Ground"
var selected_object:PackedScene = null
var object_string:String = ""

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
var object_string_name_to_tile_pos:Dictionary = {
	
}


# This will keep track of bonus parameters at a specific tile
var tile_pos_to_bonus_parameters:Dictionary[Vector2i, Dictionary] = {
	
}



#func get_tile() -> Array:
	#if (selected_tile in tiles_dictionary):
		#return tile_type_to_tile_data_dictionary[tiles_dictionary[selected_tile]]
	##match selected_tile:
		##"Ground":
			##return tiles_dictionary[selected_tile]
	#return [0, Vector2i(0,0), 0]


func get_tile(tile_map:TileMapLayer) -> Array:
	
	# Physics tile map needs to convert from decorative
	if tile_map == physics_tilemap:
		return LevelEditor.physics_tile_type_to_tile_data_dictionary[LevelEditor.decorative_tiles_to_physics[selected_tile]]
	elif tile_map == decorative_tilemap:
		return LevelEditor.decorative_tiles_data_dictionary[selected_tile]
	
	#if (selected_tile in tiles_dictionary):
		#return tile_type_to_tile_data_dictionary[tiles_dictionary[selected_tile]]
	#match selected_tile:
		#"Ground":
			#return tiles_dictionary[selected_tile]
	return [0, Vector2i(0,0), 0]



func check_can_add_spawnpoint() -> bool:
	# Check if there is multiple Spawnpoints
	if "Spawnpoint" not in object_string_name_to_tile_pos:
		return true
	
	if len(object_string_name_to_tile_pos["Spawnpoint"]) == 0:
		return true
	
	return false


func get_spawnpoint() -> Node2D:
	if "Spawnpoint" in object_string_name_to_tile_pos:
		if len(object_string_name_to_tile_pos["Spawnpoint"]) == 1:
			if object_string_name_to_tile_pos["Spawnpoint"][0] in tile_pos_to_object_dictionary:
				return tile_pos_to_object_dictionary[object_string_name_to_tile_pos["Spawnpoint"][0]]["object"]
	return null


func delete_all_by_object_name(obj_name:String) -> void:
	
	for pos:Vector2i in object_string_name_to_tile_pos[obj_name]:
		delete_tile(null, pos)


func set_tile_deleter(tile_map:TileMapLayer, tile_position:Vector2i) -> void:
	# Check to see if the position exists in there
	#delete_tile(tile_map, tile_position)
	if tile_position in tile_pos_to_object_dictionary:
		# If there is an object in existance, remove it
		if tile_pos_to_object_dictionary[tile_position]["object"] != null:
			tile_pos_to_object_dictionary[tile_position]["object"].queue_free()
		tile_pos_to_object_dictionary[tile_position]["object"] = null
		tile_pos_to_object_dictionary[tile_position]["object_name"] = ""
	
	# Remove from the other dictionary that is used to save
	for key in object_string_name_to_tile_pos.keys():
		if tile_position in object_string_name_to_tile_pos[key]:
			object_string_name_to_tile_pos[key].erase(tile_position)
	

	



func set_tile(tile_map:TileMapLayer, tile_position:Vector2i,) -> void:
	
	# If the tile being placed is not an object
	if selected_object == null:
		var tile_data:Array = get_tile(tile_map)
		var source_id:int = tile_data[0]
		var atlas_coord:Vector2i = tile_data[1]
		var alt_tile:int = tile_data[2]
		
		set_tile_deleter(tile_map, tile_position)
		
		
		tile_map.set_cell(tile_position, source_id, atlas_coord, alt_tile)
		
		#decorative_tilemap.set_cells_terrain_connect(decorative_tilemap.get_used_cells(), 0, 0, false)
		#BetterTerrain.update_terrain_cells(decorative_tilemap, decorative_tilemap.get_used_cells(),)
		BetterTerrain.update_terrain_cell(decorative_tilemap, tile_position,)
		
		
		#var tile_atlas_coords:Vector2i = decorative_tilemap.get_cell_atlas_coords(tile_position)
		#print(tile_atlas_coords)
		#if decorative_tiles_slope_to_physics_slope.has(tile_atlas_coords):
			#var new_tile_data = physics_tile_type_to_tile_data_dictionary[decorative_tiles_slope_to_physics_slope[tile_atlas_coords]]
			#print(new_tile_data)
			#physics_tilemap.set_cell(tile_position, new_tile_data[0], new_tile_data[1], new_tile_data[2])
	
	# Set object in tile
	else:
		
		# Check is spawnpoint already exists
		if not check_can_add_spawnpoint() and object_string == "Spawnpoint":
			delete_all_by_object_name("Spawnpoint") # Delete all occurances of Spawnpoint
		
		set_tile_deleter(tile_map, tile_position)
		## Check to see if a tile is there already
		if tile_map.get_cell_tile_data(tile_position) != null:
			tile_map.erase_cell(tile_position)
		
	
		# Add new object to tree and dictionary
		var object = selected_object.instantiate()
		
		#if object_bonus_parameters != {}:
		#
			#tile_pos_to_bonus_parameters[tile_position] = object_bonus_parameters.duplicate()
		#elif object_bonus_parameters == {} and tile_pos_to_bonus_parameters.has(tile_position):
			#tile_pos_to_bonus_parameters.erase(tile_position)
		#object_bonus_parameters = {}
		
		
		add_bonus_params_to_objects(object, tile_position)
		
		object.global_position = tile_map.map_to_local(tile_position)
		object_node.add_child(object)
		tile_pos_to_object_dictionary[tile_position] = {"object":null, "object_name":""}
		tile_pos_to_object_dictionary[tile_position]["object"] = object
		tile_pos_to_object_dictionary[tile_position]["object_name"] = object_string
		
		
		if object_string in object_string_name_to_tile_pos:
			if tile_position not in object_string_name_to_tile_pos[object_string]:
				object_string_name_to_tile_pos[object_string].append(tile_position)
		else:
			object_string_name_to_tile_pos[object_string] = [tile_position]




func add_bonus_params_to_objects(object:Object,tile_position:Vector2i) -> void:
	
	if not tile_pos_to_bonus_parameters.has(tile_position):
		return
	
	if tile_pos_to_bonus_parameters[tile_position].has("Distance"):
		object.patrol_distance = tile_pos_to_bonus_parameters[tile_position]["Distance"]


#func set_tile(tile_map:TileMapLayer, tile_position:Vector2i,) -> void:
	## If the tile being placed is not an object
	#if selected_object == null:
		#var tile_data:Array = get_tile(tile_map)
		#var source_id:int = tile_data[0]
		#var atlas_coord:Vector2i = tile_data[1]
		#var alt_tile:int = tile_data[2]
		#
		#
		## Check to see if the position exists in there
		#if tile_position in tile_pos_to_object_dictionary:
			## If there is an object in existance, remove it
			#if tile_pos_to_object_dictionary[tile_position] != null:
				#tile_pos_to_object_dictionary[tile_position].queue_free()
			#tile_pos_to_object_dictionary[tile_position] = null
		#
		## Remove from the other dictionary that is used to save
		#for key in object_string_name_to_tile_pos.keys():
			#if tile_position in object_string_name_to_tile_pos[key]:
				#object_string_name_to_tile_pos[key].erase(tile_position)
		#
		#
		#tile_map.set_cell(tile_position, source_id, atlas_coord, alt_tile)
	#
	## Set object in tile
	#else:
		#
		## Check is spawnpoint already exists
		#if not check_can_add_spawnpoint() and object_string == "Spawnpoint":
			#delete_all_by_object_name("Spawnpoint") # Delete all occurances of Spawnpoint
		#
		## Check to see if a tile is there already
		#if tile_map.get_cell_tile_data(tile_position) != null:
			#tile_map.erase_cell(tile_position)
		#
		## Check to see if the position exists in there
		#if tile_position in tile_pos_to_object_dictionary:
			## If there is an object in existance, remove it
			#if tile_pos_to_object_dictionary[tile_position] != null:
				#tile_pos_to_object_dictionary[tile_position].queue_free()
			#tile_pos_to_object_dictionary[tile_position] = null
		#
		## Remove from the other dictionary that is used to save
		#for key in object_string_name_to_tile_pos.keys():
			#if tile_position in object_string_name_to_tile_pos[key]:
				#object_string_name_to_tile_pos[key].erase(tile_position)
		#
		## Add new object to tree and dictionary
		#var object = selected_object.instantiate()
		#object.global_position = tile_map.map_to_local(tile_position)
		#object_node.add_child(object)
		#tile_pos_to_object_dictionary[tile_position] = object
		#
		#
		#if object_string in object_string_name_to_tile_pos:
			#if tile_position not in object_string_name_to_tile_pos[object_string]:
				#object_string_name_to_tile_pos[object_string].append(tile_position)
		#else:
			#object_string_name_to_tile_pos[object_string] = [tile_position]



# Deletes tile that is in use
func delete_tile(tile_map:TileMapLayer, tile_position:Vector2i,):
	var tile_data:Array = get_tile(tile_map)
	var source_id:int = tile_data[0]
	var atlas_coord:Vector2i = tile_data[1]
	var alt_tile:int = tile_data[2]
	
	tile_map.set_cell(tile_position, -1, Vector2i(-1,-1), 0)
	
	# Check to see if the position exists in there
	if tile_position in tile_pos_to_object_dictionary:
		if tile_pos_to_object_dictionary[tile_position]["object"] != null:
			tile_pos_to_object_dictionary[tile_position]["object"].queue_free()
		tile_pos_to_object_dictionary[tile_position]["object"] = null
	
	
	# Remove from the other dictionary that is used to save
	for key in object_string_name_to_tile_pos.keys():
		if tile_position in object_string_name_to_tile_pos[key]:
			object_string_name_to_tile_pos[key].erase(tile_position)


func load_logics(path_name:String="") -> void:
	#tilemap.clear()
	print("PATH: ", path_name)
	tile_pos_to_object_dictionary.clear()
	object_string_name_to_tile_pos.clear()
	
	if ResourceLoader.exists(path_name):
		# Open the file for writing
		var save:CustomLevelSave = ResourceLoader.load(path_name,"", ResourceLoader.CACHE_MODE_IGNORE)
		
		if save == null:
			print("failed to load")
		
		selected_object = null
		
		
		# Load the physics tile map cells
		for pos in save.physics_tilemap_cells[0]:
			selected_tile = "Ground"
			set_tile(physics_tilemap, pos)
		
		for pos in save.physics_tilemap_cells[1]:
			selected_tile = "SuperDrillable"
			set_tile(physics_tilemap, pos)
		
		for pos in save.physics_tilemap_cells[2]:
			selected_tile = "Dirt"
			set_tile(physics_tilemap, pos)
		
		selected_tile = "Ground"
		
		
		# Load Objects
		for object_key in save.object_string_name_to_tile_pos.keys():
			for pos in save.object_string_name_to_tile_pos[object_key]:
				selected_object = LevelEditor.object_dictionary[object_key]
				object_string = object_key
				set_tile(physics_tilemap, pos)
				
				# Set the player's spawn
				if object_string == "Spawnpoint":
					var obj:Node2D = tile_pos_to_object_dictionary[object_string_name_to_tile_pos[object_string][0]]["object"]
					$Player.global_position = obj.global_position
					$GameCamera.global_position = $Player.global_position
		
		
		selected_object = null
		
		


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
			#var physics_tilemap_data = JSON.to_native(json["PhysicsTilemap"]) 
			# Convert json into native Godot types
			var decorative_tilemap_data
			if "DecorativeTilemap" in json:
				decorative_tilemap_data = JSON.to_native(json["DecorativeTilemap"])
			
			var tile_pos_to_bonus_params:Dictionary = {}
			if "TilePosBonusParameters" in json:
				tile_pos_to_bonus_params = JSON.to_native(json["TilePosBonusParameters"])
			
			var object_string_tile_pos = JSON.to_native(json["ObjectStringTilePos"])
			
			selected_object = null
			object_string = ""
			
			if decorative_tilemap_data:
				for id in range(len(decorative_tilemap_data)):
					for pos:Vector2i in decorative_tilemap_data[id]:
						selected_tile = decorative_source_id_to_tile_name[id]
						#print(selected_tile)
						set_tile(physics_tilemap, pos)
						set_tile(decorative_tilemap, pos,)
			#else:
			#
				## Load the physics tile map cells
				#for pos in physics_tilemap_data[0]:
					#selected_tile = "Ground"
					#set_tile(physics_tilemap, pos)
					#set_tile(decorative_tilemap, pos,)
					#
				#for pos in physics_tilemap_data[1]:
					#selected_tile = "SuperDrillable"
					#set_tile(physics_tilemap, pos)
					#set_tile(decorative_tilemap, pos,)
					#
				#for pos in physics_tilemap_data[2]:
					#selected_tile = "Dirt"
					#set_tile(physics_tilemap, pos)
					#set_tile(decorative_tilemap, pos,)
			
			
			selected_tile = "Ground"
			
			# Load the bonus paramaters from the JSON file
			tile_pos_to_bonus_parameters = tile_pos_to_bonus_params
			
			# Load Objects
			for object_key in object_string_tile_pos.keys():
				for pos in object_string_tile_pos[object_key]:
					selected_object = LevelEditor.object_dictionary[object_key]
					object_string = object_key
					set_tile(physics_tilemap, pos)
					
					# Set the player's spawn
					if object_string == "Spawnpoint":
						var obj:Node2D = tile_pos_to_object_dictionary[object_string_name_to_tile_pos[object_string][0]]["object"]
						$Player.global_position = obj.global_position
						$GameCamera.global_position = $Player.global_position
						pass
			
			object_string = ""
			selected_object = null
			file.close()
			fix_physics_tile_map()

func fix_physics_tile_map() -> void:
	for tile_position:Vector2i in decorative_tilemap.get_used_cells():
		var tile_atlas_coords:Vector2i = decorative_tilemap.get_cell_atlas_coords(tile_position)
		if LevelEditor.decorative_tiles_slope_to_physics_slope.has(tile_atlas_coords):
			var new_tile_data = LevelEditor.physics_tile_type_to_tile_data_dictionary[LevelEditor.decorative_tiles_slope_to_physics_slope[tile_atlas_coords]]
			physics_tilemap.set_cell(tile_position, new_tile_data[0], new_tile_data[1], new_tile_data[2])
		else:
			var tile_data:Array = get_tile(physics_tilemap)
			var source_id:int = tile_data[0]
			var atlas_coord:Vector2i = tile_data[1]
			var alt_tile:int = tile_data[2]
			physics_tilemap.set_cell(tile_position, source_id,atlas_coord, alt_tile)


func load_level() -> void:
	pass
