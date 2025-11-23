extends Node2D
class_name TestCustomLevelEditor

## Temporary to test Completion Times and Ending screen
@export var s_rank_time:float = 10000


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
			
			var object_bonus_parameters = {}
			
			if decorative_tilemap_data:
				for id in range(len(decorative_tilemap_data)):
					for pos:Vector2i in decorative_tilemap_data[id]:
						selected_tile = decorative_source_id_to_tile_name[id]
						LevelEditor.static_set_tile(physics_tilemap, "Physics", pos, selected_object, selected_tile, object_string, object_node, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters, object_string_name_to_tile_pos, object_bonus_parameters, true)
						LevelEditor.static_set_tile(decorative_tilemap, "Decorative", pos, selected_object, selected_tile, object_string, object_node, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters, object_string_name_to_tile_pos, object_bonus_parameters, true)
			
			
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
						$Player.global_position = obj.global_position
						$GameCamera.global_position = $Player.global_position
						pass
			
			object_string = ""
			selected_object = null
			file.close()
			BetterTerrain.update_terrain_cells(decorative_tilemap, decorative_tilemap.get_used_cells())
			fix_physics_tile_map()

func fix_physics_tile_map() -> void:
	for tile_position:Vector2i in decorative_tilemap.get_used_cells():
		var tile_atlas_coords:Vector2i = decorative_tilemap.get_cell_atlas_coords(tile_position)
		if LevelEditor.decorative_tiles_slope_to_physics_slope.has(tile_atlas_coords):
			var new_tile_data = LevelEditor.physics_tile_type_to_tile_data_dictionary[LevelEditor.decorative_tiles_slope_to_physics_slope[tile_atlas_coords]]
			physics_tilemap.set_cell(tile_position, new_tile_data[0], new_tile_data[1], new_tile_data[2])
		else:
			var tile_data:Array = LevelEditor.static_get_tile(physics_tilemap, selected_tile)["Physics"]
			var source_id:int = tile_data[0]
			var atlas_coord:Vector2i = tile_data[1]
			var alt_tile:int = tile_data[2]
			physics_tilemap.set_cell(tile_position, source_id,atlas_coord, alt_tile)


func load_level() -> void:
	pass
