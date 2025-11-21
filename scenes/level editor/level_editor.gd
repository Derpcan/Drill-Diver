extends Node2D
class_name LevelEditor

@onready var physics_tilemap:TileMapLayer = $PhysicsTileMap
@onready var decorative_tilemap:TileMapLayer = $DecorativeTileMap
@onready var preview_tilemap:TileMapLayer = $PreviewTileMap
@onready var level_editor_hud:CanvasLayer = $LevelEditorHud

@onready var camera:Camera2D = $Camera2D

@onready var load_file_dialog:FileDialog = $LoadDialog
@onready var save_file_dialog:FileDialog = $SaveDialog

@onready var load_or_save_ui:LoadOrSave = $LoadOrSave


@onready var save_animation_player:AnimationPlayer = $LevelEditorHud/AnimationPlayer

@onready var object_node:Node2D = $ObjectNode


@onready var undo_stack:UndoStack = UndoStack.new()


var testing_mode:bool = false:
	set(new_value):
		testing_mode = new_value


var prevent_tile_placement:bool = true:
	set(new_value):
		prevent_tile_placement = new_value
		
		if prevent_tile_placement == true:
			#delete_tile(physics_tilemap, tilemap_mouse_position) # Delete tile when opening selection menu
			preview_tilemap.clear()

var mouse_position:Vector2 = Vector2.ZERO

var place_held_down:bool = false:
	set(new_value):
		if new_value == place_held_down:
			return
		
		#if new_value != place_held_down:
		if new_value == true :#and place_held_down == false:
			if len(undo_stack.peek()) > 0:
				undo_stack.push_dictionary({false:[], true:[]})
				ignore_tiles = {}
				#undo_stack.push_array([is_deleting])
			else:
				ignore_tiles = {}
				#undo_stack.push(is_deleting)
				pass
		else:
			# Pop the empty dictionary after place button is released
			if undo_stack.peek() == {false:[], true:[]}:
				undo_stack.pop()
		place_held_down = new_value
		
		

var tilemap_mouse_position:Vector2 = Vector2.ZERO:
	set(new_tilemap_mouse_position):
		
		previous_tilemap_mouse_postion = tilemap_mouse_position
		tilemap_mouse_position = new_tilemap_mouse_position
		
		# If the place button is being held down
		if place_held_down:
			# Complete the line between the two points in case there are skips
			for point in line(previous_tilemap_mouse_postion, tilemap_mouse_position):
				if is_deleting == false:
					set_tile(physics_tilemap, Vector2i(point[0], point[1]))
					set_tile(decorative_tilemap, Vector2i(point[0], point[1]))
					
					undo_stack.push(Vector2i(point[0], point[1]), false)
				elif is_deleting == true:
					delete_tile(physics_tilemap, Vector2i(point[0], point[1]))
					delete_tile(decorative_tilemap, Vector2i(point[0], point[1]))


var previous_tilemap_mouse_postion:Vector2 = Vector2.ZERO


# The toggle for if the editor should be deleting tiles or placing
var is_deleting:bool = false:
	set(new_value):
		is_deleting = new_value
		if len(undo_stack.peek()) > 0:
			undo_stack.push_dictionary({false:[], true:[]})



enum tile_types {
	UNDRILLABLE, # Hard material, used for floors or roofs that can't be passed
	DRILLABLE, # Material you can drill through
	SUPERDRILLABLE, # Material you need super drill to get through
}


var tile_map_to_tile_dictionary:Dictionary[String, Dictionary] = {
	"Decorative":decorative_tiles_data_dictionary,
	"Physics":decorative_tiles_to_physics,
}

# The possible tiles that can be placed in the level editor
var tiles_dictionary:Dictionary = {
	"Ground":tile_types.UNDRILLABLE,#[0,Vector2(0,0), 0],
	"Dirt":tile_types.DRILLABLE,
	"SuperDrillable":tile_types.SUPERDRILLABLE
}


# The conversion from decorative to physics tiles
var decorative_tiles_to_physics:Dictionary = {
	"Ground":tile_types.UNDRILLABLE,
	"SuperDrillable":tile_types.SUPERDRILLABLE,
	"Dirt":tile_types.DRILLABLE,
}


var decorative_source_id_to_tile_name:Dictionary = {
	0:"Ground",
	1:"SuperDrillable",
	2:"Dirt",
}


# The tile data associated with the decorative tileset
var decorative_tiles_data_dictionary:Dictionary = {
	"Ground":[1,Vector2i(21,0),0],
	"SuperDrillable":[2,Vector2(7,9),0],
	"Dirt":[3,Vector2i(3,1),0],
}

# The data associated with the physics Tiles
var physics_tile_type_to_tile_data_dictionary:Dictionary = {
	tile_types.UNDRILLABLE:[0,Vector2(0,0),0],
	tile_types.SUPERDRILLABLE:[1,Vector2(0,0),0],
	tile_types.DRILLABLE:[2,Vector2(0,0),0],	
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
var tile_pos_to_object_dictionary:Dictionary[Vector2i, Dictionary] = {
	
}

# This will be saved in the custom level resource
var object_string_name_to_tile_pos:Dictionary = {
	
}



var selected_tile:String = "Ground":
	set(new_value):
		selected_tile = new_value
		object_string = ""

var selected_object:PackedScene = null
var object_string:String = ""


func _ready() -> void:
	# Get the tile selector
	var tile_selector:TileSelector = level_editor_hud.get_node("TileSelector") as TileSelector
	tile_selector.tile_selector_state_changed.connect(tile_selector_changed)
	tile_selector.tile_selector_new_tile_selected.connect(tile_selected_changed)
	
	
	load_or_save_ui.create_new_level.connect(_create_new_level_dialog)
	load_or_save_ui.load_level.connect(_load_level_logic)
	
	
	load_file_dialog.file_selected.connect(load_logic)
	save_file_dialog.file_selected.connect(_create_new_level_logic)
	
	$LevelEditorHud/TestLevelButton.pressed.connect(test_level)
	$TestingHud/StopTestingButton.pressed.connect(_stop_testing)



# Creates the new file in the filesystem
func _create_new_level_logic(nam:String) -> void:
	load_or_save_ui.queue_free()
	level_editor_hud.show()
	
	# Create the directories needed to save the file
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	# Open the file for writing
	var file:FileAccess = FileAccess.open(nam+".json", FileAccess.WRITE)
	
	prevent_tile_placement = false
	
	save_path = nam+".json"

# Show the Create new level dialog
func _create_new_level_dialog() -> void:
	save_file_dialog.show()
	

# Show the load level file dialog
func _load_level_logic() -> void:
	load_file_dialog.show()
	


func tile_selected_changed(tile_string:String) -> void:
	if tile_string in tiles_dictionary:
		selected_object = null
		selected_tile = tile_string
	
	if tile_string in object_dictionary:
		selected_object = object_dictionary[tile_string]
		selected_tile = ""
		object_string = tile_string




# Block or unblock placing tiles
func tile_selector_changed(is_open:bool) -> void:
	if is_open == true:
		prevent_tile_placement = true
	
	if is_open == false:
		prevent_tile_placement = false





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
				return tile_pos_to_object_dictionary[object_string_name_to_tile_pos["Spawnpoint"][0]]["object"]
	return null


func delete_all_by_object_name(obj_name:String) -> void:
	
	for pos:Vector2i in object_string_name_to_tile_pos[obj_name]:
		
		# Allows for dragging the spawnpoint and undoing to properly work for it
		undo_stack.push_dictionary({false:[],true:[]})
		delete_tile(physics_tilemap, pos)
	

var ignore_tiles:Dictionary[Vector2i, bool] = {
	
}



func set_tile_deleter(tile_map:TileMapLayer, tile_position:Vector2i) -> void:
	# Check to see if the position exists in there
	#delete_tile(tile_map, tile_position)
	if tile_position in tile_pos_to_object_dictionary and tile_position not in ignore_tiles:
		# If there is an object in existance, remove it
		if tile_pos_to_object_dictionary[tile_position]["object"] != null:
			undo_stack.push(["", tile_pos_to_object_dictionary[tile_position]["object_name"], tile_position], true)
			tile_pos_to_object_dictionary[tile_position]["object"].queue_free()
		tile_pos_to_object_dictionary[tile_position]["object"] = null
		tile_pos_to_object_dictionary[tile_position]["object_name"] = ""
	
	# Remove from the other dictionary that is used to save
	for key in object_string_name_to_tile_pos.keys():
		if tile_position in object_string_name_to_tile_pos[key] and tile_position not in ignore_tiles:
			object_string_name_to_tile_pos[key].erase(tile_position)
	
	
	# If there is tile data at the point
	var tile_at_point:int = tile_map.get_cell_source_id(tile_position)
	
	if tile_at_point != -1 and tile_position not in ignore_tiles:
		if tile_map == physics_tilemap:
			match tile_at_point:
				0:
					undo_stack.push(["Ground", "", tile_position], true)
				1:
					undo_stack.push(["SuperDrillable", "", tile_position], true)
				2:
					undo_stack.push(["Dirt", "", tile_position], true)
		



func set_tile(tile_map:TileMapLayer, tile_position:Vector2i,) -> void:
	
	# If the tile being placed is not an object
	if selected_object == null:
		var tile_data:Array = get_tile(tile_map)
		var source_id:int = tile_data[0]
		var atlas_coord:Vector2i = tile_data[1]
		var alt_tile:int = tile_data[2]
		
		set_tile_deleter(tile_map, tile_position)
		
		
		tile_map.set_cell(tile_position, source_id, atlas_coord, alt_tile)
		ignore_tiles[tile_position] = true
	
	# Set object in tile
	else:
		
		# Check is spawnpoint already exists
		if not check_can_add_spawnpoint() and object_string == "Spawnpoint" and tile_position not in ignore_tiles:
			delete_all_by_object_name("Spawnpoint") # Delete all occurances of Spawnpoint
		
		set_tile_deleter(tile_map, tile_position)
		## Check to see if a tile is there already
		if tile_map.get_cell_tile_data(tile_position) != null:
			tile_map.erase_cell(tile_position)
		#
		## Check to see if the position exists in there
		#if tile_position in tile_pos_to_object_dictionary:
			## If there is an object in existance, remove it
			#if tile_pos_to_object_dictionary[tile_position]["object"] != null:
				#tile_pos_to_object_dictionary[tile_position]["object"].queue_free()
			#tile_pos_to_object_dictionary[tile_position]["object"] = null
			#tile_pos_to_object_dictionary[tile_position]["object_name"] = ""
		#
		## Remove from the other dictionary that is used to save
		#for key in object_string_name_to_tile_pos.keys():
			#if tile_position in object_string_name_to_tile_pos[key]:
				#object_string_name_to_tile_pos[key].erase(tile_position)
		
		if tile_position not in ignore_tiles:
			# Add new object to tree and dictionary
			var object = selected_object.instantiate()
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
			ignore_tiles[tile_position] = true



# Deletes tile that is in use
func delete_tile(tile_map:TileMapLayer, tile_position:Vector2i,):
	#var tile_data:Array = get_tile()
	#var source_id:int = tile_data[0]
	#var atlas_coord:Vector2i = tile_data[1]
	#var alt_tile:int = tile_data[2]
	
	
	# If there is tile data at the point
	var tile_at_point:int = tile_map.get_cell_source_id(tile_position)
	if tile_at_point != -1:
		if tile_map == physics_tilemap:
			match tile_at_point:
				0:
					undo_stack.push(["Ground", "", tile_position], true)
				1:
					undo_stack.push(["SuperDrillable", "", tile_position], true)
				2:
					undo_stack.push(["Dirt", "", tile_position], true)
	
	
	tile_map.set_cell(tile_position, -1, Vector2i(-1,-1), 0)
	
	
	
	# Check to see if the position exists in there
	if tile_position in tile_pos_to_object_dictionary:
		if tile_pos_to_object_dictionary[tile_position]["object"] != null:
			undo_stack.push(["", tile_pos_to_object_dictionary[tile_position]["object_name"], tile_position], true)
			tile_pos_to_object_dictionary[tile_position]["object"].queue_free()
		tile_pos_to_object_dictionary[tile_position]["object"] = null
		tile_pos_to_object_dictionary[tile_position]["object_name"] = ""
	
	
	# Remove from the other dictionary that is used to save
	for key in object_string_name_to_tile_pos.keys():
		if tile_position in object_string_name_to_tile_pos[key]:
			object_string_name_to_tile_pos[key].erase(tile_position)



func show_tile_place_preview(tile_position:Vector2) -> void:
	preview_tilemap.clear()
	
	# Doesn't preview placement when tile selection menu is up
	if prevent_tile_placement == true:
		return
	
	preview_tilemap.set_cell(tile_position, 0, Vector2i(0,0), 0)
	
	if is_deleting == true:
		preview_tilemap.modulate = Color(1, 0, 0, 0.5)
	else:
		preview_tilemap.modulate = Color(1, 1, 1, 0.5)



func _physics_process(delta: float) -> void:
	if testing_mode == true: # If in testing mode
		return
	
	if prevent_tile_placement == true:
		return
	
	# Prevent the camera from moving when pressing the quick save keybind
	if Input.is_action_pressed("save_level_editor"):
		return
	
	# Allows for the camera to move
	var dir_x:float = Input.get_action_strength("move_right")-Input.get_action_strength("move_left")
	var dir_y:float = Input.get_action_strength("move_down")-Input.get_action_strength("move_up")
	
	camera.global_position.x += dir_x*4
	camera.global_position.y += dir_y*4
	# End Camera Movement



func undo_logic() -> void:
	if Input.is_action_just_pressed("undo_level_editor"):
		var stack_value:Dictionary = undo_stack.pop()
		
		#print(stack_value)
		
		if len(stack_value) == 0:
			if save_animation_player.is_playing():
				save_animation_player.stop()
			
			save_animation_player.play("nothing_undo_fade_out")
			return
		
		#if len(stack_value) == 1 and stack_value[0] is bool:
			#stack_value = undo_stack.pop()
			
		
		# For deleting tiles that were placed
		#if stack_value[0] == false:
			
		# Push an empty array to catch the additions from delete tile function
		#undo_stack.push_array([])
		undo_stack.push_dictionary({false:[],true:[]})
		#print("STACK VALUE: ",stack_value)
		for arr:Vector2i in stack_value[false]:
			delete_tile(physics_tilemap, arr)
			delete_tile(decorative_tilemap, arr)
		
		# Pop the array thats added from deleting tiles
		undo_stack.pop()
		# Replacing tiles that were deleted
		#else:
		var temp_selected_tile = selected_tile
		var temp_object = object_string
		var temp_selected_object = selected_object
		for arr:Array in stack_value[true]:
			ignore_tiles.clear()
			selected_tile = arr[0]
			object_string = arr[1]
			if object_string in object_dictionary:
				selected_object = object_dictionary[object_string]
			else:
				selected_object = null
			set_tile(physics_tilemap, arr[2])
			set_tile(decorative_tilemap, arr[2])
		selected_tile = temp_selected_tile
		object_string = temp_object
		selected_object = temp_selected_object
		



func place_tile_input_logic() -> void:
	if testing_mode == true:
		return
	
	# Get the mouse position
	mouse_position = get_global_mouse_position()
	
	# Get the tilemap coords that the mouse is at
	tilemap_mouse_position = physics_tilemap.local_to_map(mouse_position)
	
	show_tile_place_preview(tilemap_mouse_position)
	
	
	undo_logic()
	
	
	# Place down a tile
	if Input.is_action_pressed("place_tile") and not prevent_tile_placement:
		place_held_down = true
		
		if is_deleting == false:
			#set_tile(physics_tilemap, tilemap_mouse_position,)
			#set_tile(decorative_tilemap, tilemap_mouse_position,)
			pass
			#undo_stack.push(tilemap_mouse_position)
			
		if is_deleting == true:
			
			
			#delete_tile(physics_tilemap, tilemap_mouse_position)
			pass
			#physics_tilemap.set_cell(tilemap_mouse_position, -1, Vector2i(-1,-1), 0)
	elif Input.is_action_just_released("place_tile"):
		place_held_down = false





var folder_path:String = "user://level_editor/levels"
var save_path:String = folder_path + "/"
var level_name:String = "level_0.json"

func save_logic() -> void:
	
	# Create the directories needed to save the file
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	var file:FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	
	
	# Save the level as a json
	file.store_string("{\n\"PhysicsTilemap\":[\n")
	file.store_string(JSON.stringify(JSON.from_native(physics_tilemap.get_used_cells_by_id(0)))+",\n")
	file.store_string(JSON.stringify(JSON.from_native(physics_tilemap.get_used_cells_by_id(1)))+",\n")
	file.store_string(JSON.stringify(JSON.from_native(physics_tilemap.get_used_cells_by_id(2)))+"\n")
	file.store_string("],\n")
	
	# Save the decorative map
	file.store_string("\"DecorativeTilemap\":[\n")
	file.store_string(JSON.stringify(JSON.from_native(decorative_tilemap.get_used_cells_by_id(1)))+",\n")
	file.store_string(JSON.stringify(JSON.from_native(decorative_tilemap.get_used_cells_by_id(2)))+",\n")
	file.store_string(JSON.stringify(JSON.from_native(decorative_tilemap.get_used_cells_by_id(3)))+"\n")
	file.store_string("],\n")
	
	
	file.store_string("\"ObjectStringTilePos\":")
	
	file.store_string(JSON.stringify(JSON.from_native(object_string_name_to_tile_pos), "")+"\n")
	file.store_string("}")
	
	
	if save_animation_player.is_playing():
		save_animation_player.stop()
	
	save_animation_player.play("save_fade_out")





# Loading Level
func load_logic(path_name:String="") -> void:
	if load_or_save_ui:
		load_or_save_ui.queue_free()
		load_or_save_ui = null
	
	save_path = path_name
	
	
	# Load level from json file
	if FileAccess.file_exists(save_path):
		
		# Open the json file for reading
		var file:FileAccess = FileAccess.open(save_path, FileAccess.READ)
		
		# Get the text from the file
		var json_string = file.get_as_text()
		
		if json_string == "": # See if the file is empty
			return # Return early to not cause any errors
		
		# Parse the text from the file in json style
		var json = JSON.parse_string(json_string)
		if json != null: # If there was no error parsing the text
			var physics_tilemap_data = JSON.to_native(json["PhysicsTilemap"]) # Convert json into native Godot types
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
			
			object_string = ""
			selected_object = null
			file.close()
	
	
	level_editor_hud.show()
	
	prevent_tile_placement = false



func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("save_level_editor"):
		print("Saved")
		save_logic()
	
	if Input.is_action_just_pressed("toggle_delete_tile_mode"):
		is_deleting = not is_deleting
	
	# Camera Zooming In and Out
	if Input.is_action_pressed("camera_scroll_out"):
		camera.zoom *= 0.8
		camera.zoom = camera.zoom.clamp(Vector2(0.5, 0.5), Vector2(5,5))
	if Input.is_action_pressed("camera_scroll_in"):
		camera.zoom *= 1.2
		camera.zoom = camera.zoom.clamp(Vector2(0.5, 0.5), Vector2(5,5))
	if Input.is_action_just_pressed("camera_scroll_reset"):
		camera.zoom = Vector2(1,1)
	
	place_tile_input_logic()
	
	# When pause is pressed
	if Input.is_action_just_pressed("escape"):
		place_held_down = false



var player:Player = null
var checkpoint_mangager:CheckpointManager = null
var game_camera:GameCamera = null
var hud:CanvasLayer = null
var on_level_loaded:Node = null

func test_level() -> void:
	
	save_logic()
	
	
	var player_scene:PackedScene = preload("res://scenes/player/player.tscn")
	var checkpoint_manager_scene:PackedScene = preload("res://scenes/checkpoint/checkpoint_manager.tscn")
	var game_camera_scene:PackedScene = preload("res://scenes/Camera/game_camera.tscn")
	
	var hud_scene:PackedScene = preload("res://scenes/UI/hud.tscn")
	var level_loaded_scene:PackedScene = preload("res://scenes/system/OnLevelLoaded.tscn")
	
	hud = hud_scene.instantiate()
	on_level_loaded = level_loaded_scene.instantiate()
	
	player = player_scene.instantiate()
	checkpoint_mangager = checkpoint_manager_scene.instantiate()
	game_camera = game_camera_scene.instantiate()
	
	
	checkpoint_mangager.game_camera = game_camera
	checkpoint_mangager.player = player
	
	testing_mode = true
	$LevelEditorHud/TestLevelButton.hide()
	$Camera2D.hide()
	$Camera2D.enabled = false
	
	game_camera.enabled = true
	game_camera.zoom = Vector2(3,3)
	
	physics_tilemap.player = player
	
	var spawn_point:Node2D = get_spawnpoint()
	
	if spawn_point:
		player.global_position = spawn_point.global_position
	
	add_child(player)
	add_child(checkpoint_mangager)
	add_child(game_camera)
	add_child(hud)
	add_child(on_level_loaded)
	
	level_editor_hud.hide()
	
	
	$TestingHud.show()


func _stop_testing() -> void:
	testing_mode = false
	game_camera.queue_free()
	player.queue_free()
	checkpoint_mangager.queue_free()
	hud.queue_free()
	on_level_loaded.queue_free()
	
	GameManager._handle_set_meter(0)
	
	level_editor_hud.show()
	$TestingHud.hide()
	
	$LevelEditorHud/TestLevelButton.show()
	$Camera2D.show()
	$Camera2D.enabled = true
	
	physics_tilemap.player = null
	
	# Remove children from object node
	for child in object_node.get_children():
		child.queue_free()
	
	
	reload_tilemaps()


func reload_tilemaps() -> void:
	physics_tilemap.clear()
	decorative_tilemap.clear()
	object_string_name_to_tile_pos.clear()
	tile_pos_to_object_dictionary.clear()
	ignore_tiles.clear()
	
	load_logic(save_path)




# https://forum.godotengine.org/t/tile-based-line-drawing-algorithm-efficiency/26998
#Returns a set of points from p0 to p1 using Bresenham's line algorithm
#use: line([0, 0], [10, 10])
func line(p0:Vector2i, p1:Vector2i):
	var points:Array = []
	var dx:int = abs(p1[0] - p0[0])
	var dy:int = -abs(p1[1] - p0[1])
	var err:int = dx + dy
	var e2:int = 2 * err
	var sx:int = 1 if p0[0] < p1[0] else -1
	var sy:int = 1 if p0[1] < p1[1] else -1
	while true:
		points.append([p0[0], p0[1]])
		if p0[0] == p1[0] and p0[1] == p1[1]:
			break
		e2 = 2 * err
		if e2 >= dy:
			err += dy
			p0[0] += sx
		if e2 <= dx:
			err += dx
			p0[1] += sy
	return points
