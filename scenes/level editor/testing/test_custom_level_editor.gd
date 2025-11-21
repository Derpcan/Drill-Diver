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
}


# The possible tiles that can be placed in the level editor
var tiles_dictionary:Dictionary = {
	"Ground":tile_types.UNDRILLABLE,#[0,Vector2(0,0), 0],
	"Dirt":tile_types.DRILLABLE,
	"SuperDrillable":tile_types.SUPERDRILLABLE
}

var tile_type_to_tile_data_dictionary:Dictionary = {
	tile_types.UNDRILLABLE:[0,Vector2(0,0),0],
	tile_types.DRILLABLE:[2,Vector2(0,0),0],
	tile_types.SUPERDRILLABLE:[1,Vector2(0,0),0]
}

# The possible objects that can be placed in the level editor
var object_dictionary:Dictionary = {
	"Checkpoint":preload("res://scenes/checkpoint/checkpoint.tscn"),
	"Gem":preload("res://scenes/items/MeterItem.tscn"),
	"Spawnpoint":preload("res://scenes/checkpoint/spawnpoint.tscn"),
	"Alien":preload("res://scenes/enemy/enemy.tscn"),
}

var scene_dictionary:Dictionary = {
	preload("res://scenes/checkpoint/checkpoint.tscn"):"Checkpoint",
	preload("res://scenes/items/MeterItem.tscn"):"Gem",
	preload("res://scenes/checkpoint/spawnpoint.tscn"):"Spawnpoint",
	preload("res://scenes/enemy/enemy.tscn"):"Alien",
}

# Keeps track of unique locations and stores the associated object at the location
var tile_pos_to_object_dictionary:Dictionary[Vector2i, Object] = {
	
}

# This will be saved in the custom level resource
var object_string_name_to_tile_pos:Dictionary = {
	
}

# The data associated with the physics Tiles
var physics_tile_type_to_tile_data_dictionary:Dictionary = {
	tile_types.UNDRILLABLE:[0,Vector2(0,0),0],
	tile_types.SUPERDRILLABLE:[1,Vector2(0,0),0],
	tile_types.DRILLABLE:[2,Vector2(0,0),0],	
}

# The conversion from decorative to physics tiles
var decorative_tiles_to_physics:Dictionary = {
	"Ground":tile_types.UNDRILLABLE,
	"SuperDrillable":tile_types.SUPERDRILLABLE,
	"Dirt":tile_types.DRILLABLE,
}

# The tile data associated with the decorative tileset
var decorative_tiles_data_dictionary:Dictionary = {
	"Ground":[1,Vector2i(21,0),0],
	"SuperDrillable":[2,Vector2(7,9),0],
	"Dirt":[3,Vector2i(3,1),0],
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
		return physics_tile_type_to_tile_data_dictionary[decorative_tiles_to_physics[selected_tile]]
	elif tile_map == decorative_tilemap:
		return decorative_tiles_data_dictionary[selected_tile]
	
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
				return tile_pos_to_object_dictionary[object_string_name_to_tile_pos["Spawnpoint"][0]]
	return null


func delete_all_by_object_name(obj_name:String) -> void:
	
	for pos:Vector2i in object_string_name_to_tile_pos[obj_name]:
		delete_tile(null, pos)
	



func set_tile(tile_map:TileMapLayer, tile_position:Vector2i,) -> void:
	# If the tile being placed is not an object
	if selected_object == null:
		var tile_data:Array = get_tile(tile_map)
		var source_id:int = tile_data[0]
		var atlas_coord:Vector2i = tile_data[1]
		var alt_tile:int = tile_data[2]
		
		
		# Check to see if the position exists in there
		if tile_position in tile_pos_to_object_dictionary:
			# If there is an object in existance, remove it
			if tile_pos_to_object_dictionary[tile_position] != null:
				tile_pos_to_object_dictionary[tile_position].queue_free()
			tile_pos_to_object_dictionary[tile_position] = null
		
		# Remove from the other dictionary that is used to save
		for key in object_string_name_to_tile_pos.keys():
			if tile_position in object_string_name_to_tile_pos[key]:
				object_string_name_to_tile_pos[key].erase(tile_position)
		
		
		tile_map.set_cell(tile_position, source_id, atlas_coord, alt_tile)
	
	# Set object in tile
	else:
		
		# Check is spawnpoint already exists
		if not check_can_add_spawnpoint() and object_string == "Spawnpoint":
			delete_all_by_object_name("Spawnpoint") # Delete all occurances of Spawnpoint
		
		# Check to see if a tile is there already
		if tile_map.get_cell_tile_data(tile_position) != null:
			tile_map.erase_cell(tile_position)
		
		# Check to see if the position exists in there
		if tile_position in tile_pos_to_object_dictionary:
			# If there is an object in existance, remove it
			if tile_pos_to_object_dictionary[tile_position] != null:
				tile_pos_to_object_dictionary[tile_position].queue_free()
			tile_pos_to_object_dictionary[tile_position] = null
		
		# Remove from the other dictionary that is used to save
		for key in object_string_name_to_tile_pos.keys():
			if tile_position in object_string_name_to_tile_pos[key]:
				object_string_name_to_tile_pos[key].erase(tile_position)
		
		# Add new object to tree and dictionary
		var object = selected_object.instantiate()
		object.global_position = tile_map.map_to_local(tile_position)
		object_node.add_child(object)
		tile_pos_to_object_dictionary[tile_position] = object
		
		
		if object_string in object_string_name_to_tile_pos:
			if tile_position not in object_string_name_to_tile_pos[object_string]:
				object_string_name_to_tile_pos[object_string].append(tile_position)
		else:
			object_string_name_to_tile_pos[object_string] = [tile_position]



# Deletes tile that is in use
func delete_tile(tile_map:TileMapLayer, tile_position:Vector2i,):
	var tile_data:Array = get_tile(tile_map)
	var source_id:int = tile_data[0]
	var atlas_coord:Vector2i = tile_data[1]
	var alt_tile:int = tile_data[2]
	
	tile_map.set_cell(tile_position, -1, Vector2i(-1,-1), 0)
	
	# Check to see if the position exists in there
	if tile_position in tile_pos_to_object_dictionary:
		if tile_pos_to_object_dictionary[tile_position] != null:
			tile_pos_to_object_dictionary[tile_position].queue_free()
		tile_pos_to_object_dictionary[tile_position] = null
	
	
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
				selected_object = object_dictionary[object_key]
				object_string = object_key
				set_tile(physics_tilemap, pos)
				
				# Set the player's spawn
				if object_string == "Spawnpoint":
					var obj:Node2D = tile_pos_to_object_dictionary[object_string_name_to_tile_pos[object_string][0]]
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
			
			# Load Objects
			for object_key in object_string_tile_pos.keys():
				for pos in object_string_tile_pos[object_key]:
					selected_object = object_dictionary[object_key]
					object_string = object_key
					set_tile(physics_tilemap, pos)
					
					# Set the player's spawn
					if object_string == "Spawnpoint":
						var obj:Node2D = tile_pos_to_object_dictionary[object_string_name_to_tile_pos[object_string][0]]
						$Player.global_position = obj.global_position
						$GameCamera.global_position = $Player.global_position
			
			object_string = ""
			selected_object = null
			file.close()




func load_level() -> void:
	pass
