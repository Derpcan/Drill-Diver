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

@onready var check_to_edit:CheckToEdit = $CheckToEdit


@onready var undo_stack:UndoStack = UndoStack.new()


static var bonus_parameters_viewer_scene:PackedScene = preload("res://scenes/level editor/bonus_parameters/show_and_edit_bonus_parameters.tscn")


signal tile_placed()




@onready var lab_background:ParallaxBackground = $LabBackground
@onready var cave_background:ParallaxBackground = $CaveBackground
var background_type:String = "Cave Background":
	set(new_string):
		background_type = new_string
		
		if background_type == "Lab Background":
			lab_background.call_deferred("show")
			cave_background.call_deferred("hide")
		if background_type == "Cave Background":
			lab_background.call_deferred("hide")
			cave_background.call_deferred("show")


var best_time_completed:float = 9223372036854775807:
	set(new_value):
		# Reset the time
		if new_value < 0:
			best_time_completed = 9223372036854775807
			players_beat_level = false
			return
		
		if new_value < best_time_completed:
			best_time_completed = new_value
			players_beat_level = true


var players_beat_level:bool = false


var testing_mode:bool = false:
	set(new_value):
		testing_mode = new_value
		
		if testing_mode:
			if viewer:
				viewer.queue_free()
				viewer = null


var prevent_tile_placement:bool = true:
	set(new_value):
		prevent_tile_placement = new_value
		
		if prevent_tile_placement == true:
			#delete_tile(physics_tilemap, tilemap_mouse_position) # Delete tile when opening selection menu
			preview_tilemap.clear()

var mouse_position:Vector2 = Vector2.ZERO:
	set(new_value):
		mouse_position = new_value
		
		if viewer:
			if mouse_position.distance_to(viewer.global_position) > 20:
				viewer.queue_free()
				viewer = null
		

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
		
		set_up_bonus_parameters_viewer(new_tilemap_mouse_position)
		
		# If the place button is being held down
		if place_held_down:
			# Complete the line between the two points in case there are skips
			for point in line(previous_tilemap_mouse_postion, tilemap_mouse_position):
				if is_deleting == false:
					#set_tile(physics_tilemap, Vector2i(point[0], point[1]))
					set_tile(decorative_tilemap, Vector2i(point[0], point[1]))
					
					
					undo_stack.push(Vector2i(point[0], point[1]), false)
				elif is_deleting == true:
					#delete_tile(physics_tilemap, Vector2i(point[0], point[1]))
					delete_tile(decorative_tilemap, Vector2i(point[0], point[1]))
					
					if viewer:
						viewer.queue_free()
						viewer = null


var previous_tilemap_mouse_postion:Vector2 = Vector2.ZERO


# The toggle for if the editor should be deleting tiles or placing
var is_deleting:bool = false:
	set(new_value):
		is_deleting = new_value
		if is_deleting == true:
			if len(undo_stack.peek()) > 0:
				undo_stack.push_dictionary({false:[], true:[]})



enum tile_types {
	UNDRILLABLE, # Hard material, used for floors or roofs that can't be passed
	DRILLABLE, # Material you can drill through
	SUPERDRILLABLE, # Material you need super drill to get through
	UNDRILLABLE_UP_STAIR_RIGHT,
	UNDRILLABLE_UP_STAIR_LEFT,
	UNDRILLABLE_DOWN_STAIR_RIGHT,
	UNDRILLABLE_DOWN_STAIR_LEFT,
}


static var tile_map_to_tile_dictionary:Dictionary[String, Dictionary] = {
	"Decorative":decorative_tiles_data_dictionary,
	"Physics":decorative_tiles_to_physics,
}


# The possible tiles that can be placed in the level editor
#static var tiles_dictionary:Dictionary = {
	#"Ground":tile_types.UNDRILLABLE,#[0,Vector2(0,0), 0],
	#"Dirt":tile_types.DRILLABLE,
	#"SuperDrillable":tile_types.SUPERDRILLABLE,
	#"Lab":tile_types.UNDRILLABLE,
#}


# The conversion from decorative to physics tiles
static var decorative_tiles_to_physics:Dictionary = {
	"Ground":tile_types.UNDRILLABLE,
	"SuperDrillable":tile_types.SUPERDRILLABLE,
	"Dirt":tile_types.DRILLABLE,
	"Lab":tile_types.UNDRILLABLE
}


static var decorative_source_id_to_tile_name:Dictionary = {
	6:"Ground",
	2:"SuperDrillable",
	12:"Dirt",
	11:"Lab"
}


static var decorative_tiles_slope_to_physics_slope:Dictionary[Vector2i,int] = {
	Vector2i(1,4):tile_types.UNDRILLABLE_DOWN_STAIR_RIGHT,
	Vector2i(2,4):tile_types.UNDRILLABLE_DOWN_STAIR_LEFT,
	Vector2i(3,0):tile_types.UNDRILLABLE_UP_STAIR_RIGHT,
	Vector2i(0,0):tile_types.UNDRILLABLE_UP_STAIR_LEFT,
}

# The tile data associated with the decorative tileset
static var decorative_tiles_data_dictionary:Dictionary = {
	"Ground":[6,Vector2i(1,6),0],
	"Lab":[11,Vector2i(0,2),0],
	#"Ground":[1,Vector2i(21,0),0],
	"SuperDrillable":[2,Vector2(7,9),0],
	"Dirt":[12,Vector2i(3,1),0],
}

# The data associated with the physics Tiles
static var physics_tile_type_to_tile_data_dictionary:Dictionary = {
	tile_types.UNDRILLABLE:[0,Vector2(0,0),0],
	tile_types.SUPERDRILLABLE:[1,Vector2(0,0),0],
	tile_types.DRILLABLE:[2,Vector2(0,0),0],
	tile_types.UNDRILLABLE_UP_STAIR_RIGHT:[3, Vector2(0,0), 0],
	tile_types.UNDRILLABLE_UP_STAIR_LEFT:[4, Vector2(0,0), 0],
	tile_types.UNDRILLABLE_DOWN_STAIR_RIGHT:[5, Vector2(0,0), 0],
	tile_types.UNDRILLABLE_DOWN_STAIR_LEFT:[6, Vector2(0,0), 0],
}

# The possible objects that can be placed in the level editor
static var object_dictionary:Dictionary = {
	"Checkpoint":preload("res://scenes/checkpoint/checkpoint.tscn"),
	"Gem":preload("res://scenes/items/MeterItem.tscn"),
	"Spawnpoint":preload("res://scenes/checkpoint/spawnpoint.tscn"),
	"Goal":preload("res://scenes/goal/goal.tscn"),
	"Alien":preload("res://scenes/enemy/enemy.tscn"),
}

static var scene_dictionary:Dictionary = {
	preload("res://scenes/checkpoint/checkpoint.tscn"):"Checkpoint",
	preload("res://scenes/items/MeterItem.tscn"):"Gem",
	preload("res://scenes/checkpoint/spawnpoint.tscn"):"Spawnpoint",
	preload("res://scenes/goal/goal.tscn"):"Goal",
	preload("res://scenes/enemy/enemy.tscn"):"Alien",
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



var selected_tile:String = "Ground":
	set(new_value):
		selected_tile = new_value
		object_string = ""


var selected_object:PackedScene = null
var object_string:String = ""
var object_bonus_parameters:Dictionary = {}:
	set(new_dict):
		object_bonus_parameters = new_dict
		#print(object_bonus_parameters)



func _ready() -> void:
	# Get the tile selector
	var tile_selector:TileSelector = level_editor_hud.get_node("TileSelector") as TileSelector
	tile_selector.tile_selector_state_changed.connect(tile_selector_changed)
	tile_selector.tile_selector_new_tile_selected.connect(tile_selected_changed)
	
	# Create the directories needed to save the file
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	load_or_save_ui.create_new_level.connect(_create_new_level_dialog)
	load_or_save_ui.load_level.connect(_load_level_logic)
	
	
	load_file_dialog.file_selected.connect(load_logic)
	save_file_dialog.file_selected.connect(_create_new_level_logic)
	
	$LevelEditorHud/TestLevelButton.pressed.connect(test_level)
	$TestingHud/StopTestingButton.pressed.connect(_stop_testing)
	
	tile_placed.connect(_handle_level_changed)
	finished_loading.connect(_hide_loading_screen)



var viewer:ShowEditBonusParameters = null
func set_up_bonus_parameters_viewer(tile_position:Vector2i) -> void:
	
	if place_held_down:
		return
	
	var obj = get_object_at_mouse(tile_position)
	
	if obj == null:
		return
	
	
	if viewer != null and viewer.global_position == physics_tilemap.map_to_local(tile_position):
		return
	
	if viewer != null:
		viewer.queue_free()
		viewer = null
	
	
	viewer = bonus_parameters_viewer_scene.instantiate()
	viewer.global_position = physics_tilemap.map_to_local(tile_position+Vector2i(0,0)) + Vector2(-7, 7)
	viewer.scale = Vector2(1,1)/(camera.zoom)
	if tile_pos_to_bonus_parameters.has(tile_position):
		viewer.bonus_parameters_dictionary = tile_pos_to_bonus_parameters[tile_position]
	viewer.tile_position = tile_position
	viewer.object_name = tile_pos_to_object_dictionary[tile_position]["object_name"]
	viewer.bonus_parameter_submitted.connect(_update_object_bonus_parameters)
	add_child(viewer)


func _update_object_bonus_parameters(tile_position:Vector2i, new_bonus_parameters:Dictionary) -> void:
	
	print("attempting to change")
	# Check is level creator wants to reset time to continue working on level
	if check_to_edit != null and players_beat_level and not loading_level:
		
		check_to_edit.prompt_for_decision(best_time_completed)
		
		var can_edit:bool = await check_to_edit.user_decided
		
		# If user doesn't want to remove their best time
		if can_edit == false:
			viewer.bonus_parameters_dictionary = tile_pos_to_bonus_parameters[tile_position]
			#if viewer:
				#viewer.queue_free()
				#viewer = null
			return
		
		# Reset the time
		best_time_completed = -1
	
	tile_pos_to_bonus_parameters[tile_position] = new_bonus_parameters
	update_object_bonus_parameters(tile_position, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters)


func get_object_at_mouse(tile_position:Vector2i) -> Object:
	if tile_pos_to_bonus_parameters.has(tile_position):
		#print(tile_pos_to_bonus_parameters[tile_position])
		pass
	
	if tile_pos_to_object_dictionary.has(tile_position):
		return tile_pos_to_object_dictionary[tile_position]["object"]
		#print(tile_pos_to_object_dictionary[tile_position])
		pass
	#print(tile_pos_to_bonus_parameters)
	
	return null




func _handle_level_changed() -> void:
	
	# Prompt user if they want to Continue to change the level
	# If they have beat the level. Have a different best time than 9223372036854775807
	
	#print("changed")
	pass



# Creates the new file in the filesystem
func _create_new_level_logic(nam:String) -> void:
	
	load_or_save_ui.queue_free()
	level_editor_hud.show()
	
	
	
	# Open the file for writing
	var file:FileAccess = FileAccess.open(nam+".lvl", FileAccess.WRITE)
	
	prevent_tile_placement = false
	
	save_path = nam+".lvl"
	
	# Save so it isnt a broken file
	save_logic()

# Show the Create new level dialog
func _create_new_level_dialog() -> void:
	save_file_dialog.show()
	

# Show the load level file dialog
func _load_level_logic() -> void:
	load_file_dialog.show()
	


func tile_selected_changed(tile_string:String, bonus_parameters:Dictionary={}) -> void:
	
	if "Background" in tile_string:
		background_type = tile_string
		return
	
	if tile_string in decorative_tiles_to_physics:
		selected_object = null
		selected_tile = tile_string
		object_bonus_parameters = {}
	
	if tile_string in object_dictionary:
		selected_object = object_dictionary[tile_string]
		selected_tile = ""
		object_string = tile_string
		object_bonus_parameters = bonus_parameters




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


func get_goal() -> Node2D:
	if "Goal" in object_string_name_to_tile_pos:
		if len(object_string_name_to_tile_pos["Goal"]) == 1:
			if object_string_name_to_tile_pos["Goal"][0] in tile_pos_to_object_dictionary:
				return tile_pos_to_object_dictionary[object_string_name_to_tile_pos["Goal"][0]]["object"]
	return null


func delete_all_by_object_name(obj_name:String) -> void:
	
	for pos:Vector2i in object_string_name_to_tile_pos[obj_name]:
		
		# Allows for dragging the spawnpoint and undoing to properly work for it
		undo_stack.push_dictionary({false:[],true:[]})
		delete_tile(physics_tilemap, pos)
	

var ignore_tiles:Dictionary[Vector2i, bool] = {
	
}



func set_tile_deleter(tile_map:TileMapLayer, tile_position:Vector2i, avoid_stack:bool=false) -> void:
	# Check to see if the position exists in there
	if tile_position in tile_pos_to_object_dictionary and tile_position not in ignore_tiles:
		# If there is an object in existance, remove it
		if tile_pos_to_object_dictionary[tile_position]["object"] != null:
			if avoid_stack == false:
				if tile_pos_to_bonus_parameters.has(tile_position):
					# Push the deletion with the Bonus Parameters so undoing will bring back parameters
					undo_stack.push(["", tile_pos_to_object_dictionary[tile_position]["object_name"], tile_position, tile_pos_to_bonus_parameters[tile_position]], true)
				else:
					undo_stack.push(["", tile_pos_to_object_dictionary[tile_position]["object_name"], tile_position, {}], true)
			tile_pos_to_object_dictionary[tile_position]["object"].queue_free()
		tile_pos_to_object_dictionary[tile_position]["object"] = null
		tile_pos_to_object_dictionary[tile_position]["object_name"] = ""
	
	# Remove from the other dictionary that is used to save
	for key in object_string_name_to_tile_pos.keys():
		if tile_position in object_string_name_to_tile_pos[key] and tile_position not in ignore_tiles:
			object_string_name_to_tile_pos[key].erase(tile_position)
	
	
	# If there is tile data at the point
	var tile_at_point:int = tile_map.get_cell_source_id(tile_position)
	
	if avoid_stack == false:
		if tile_at_point != -1 and tile_position not in ignore_tiles:
			if tile_map == physics_tilemap:
				match tile_at_point:
					0:
						undo_stack.push(["Ground", "", tile_position, {}], true)
					1:
						undo_stack.push(["SuperDrillable", "", tile_position, {}], true)
					2:
						undo_stack.push(["Dirt", "", tile_position, {}], true)



func fix_physics_tile_map(physics_tile_map:TileMapLayer) -> void:
	for tile_position:Vector2i in decorative_tilemap.get_used_cells():
		var tile_atlas_coords:Vector2i = decorative_tilemap.get_cell_atlas_coords(tile_position)
		var source_id:int = decorative_tilemap.get_cell_source_id(tile_position)
		if decorative_tiles_slope_to_physics_slope.has(tile_atlas_coords) and source_id == 6:
			var new_tile_data = physics_tile_type_to_tile_data_dictionary[decorative_tiles_slope_to_physics_slope[tile_atlas_coords]]
			physics_tile_map.set_cell(tile_position, new_tile_data[0], new_tile_data[1], new_tile_data[2])
		else:
			selected_tile = decorative_source_id_to_tile_name[source_id]
			var tile_data:Array = get_tile(physics_tile_map)
			var source_id2:int = tile_data[0]
			var atlas_coord:Vector2i = tile_data[1]
			var alt_tile:int = tile_data[2]
			physics_tile_map.set_cell(tile_position, source_id2,atlas_coord, alt_tile)



static func static_delete_tile(
	tilemap:TileMapLayer, tile_position:Vector2i, 
	tile_position_to_object_dictionary:Dictionary[Vector2i, Dictionary], 
	tile_position_to_bonus_parameters:Dictionary[Vector2i,Dictionary],
	object_string_to_tile_position:Dictionary[String, Array],
	check_ignore_tiles:bool,
	ignore_tiles:Dictionary[Vector2i, bool],
	avoid_stack:bool, undo_stack:UndoStack
) -> void:
	
	#tilemap.changed.emit()
	
	# Decide if the Undo Stack should be avoided
	if avoid_stack == false:
		# Get the tile's source id
		var tile_at_point:int = tilemap.get_cell_source_id(tile_position)
		
		# Check if there is tile data at the point
		if tile_at_point != -1 and (not check_ignore_tiles or (tile_position not in ignore_tiles)): # If there is a tile
			match tile_at_point:
				6: # 6 Is the source ID for ground in the Decorative Tilemap
					undo_stack.push(["Ground", "", tile_position, {}], true)
				2: # 2 Is the source ID for SuperDrillable in the Decorative Tilemap
					undo_stack.push(["SuperDrillable", "", tile_position, {}], true)
				12: # 3 Is the source ID for Dirt in the Decorative Tilemap
					undo_stack.push(["Dirt", "", tile_position, {}], true)
				11:
					undo_stack.push(["Lab", "", tile_position, {}], true)
	
	# Set the cell to nothing hence deleting it
	tilemap.set_cell(tile_position, -1, Vector2i(-1,-1), 0)
	
	# Update the terrain
	#if tilemap_type == "Decorative":
	BetterTerrain.update_terrain_cell(tilemap, tile_position,)
	
	
	# Check to see if an object exists at the tile position
	if tile_position_to_object_dictionary.has(tile_position) and (not check_ignore_tiles or (tile_position not in ignore_tiles)):
		# Check if the object at the location is null.. Safety Check
		if tile_position_to_object_dictionary[tile_position]["object"] != null:
			
			# Check whether the stack should be avoided
			if avoid_stack == false:
				# Check if the object has bonus parameters
				if tile_position_to_bonus_parameters.has(tile_position):
					# Push the deletion with the Bonus Parameters so an Undo can bring back parameters
					
					# Push. [Tile Name, Object Name, Tile Position, Bonus Params], Is Deletion
					undo_stack.push(["", tile_position_to_object_dictionary[tile_position]["object_name"], tile_position, tile_position_to_bonus_parameters[tile_position]], true)
				else:
					undo_stack.push(["", tile_position_to_object_dictionary[tile_position]["object_name"], tile_position, {}], true)
			# Now queue free on the object, since it exists
			tile_position_to_object_dictionary[tile_position]["object"].queue_free()
			
		
		# Clear the object and object name from the dictionary
		tile_position_to_object_dictionary[tile_position]["object"] = null
		tile_position_to_object_dictionary[tile_position]["object_name"] = ""
		
		# Remove object position from the dictionary that is saved in JSON level
		# This prevents it from being saved accidentally and reappearing on load
		for key:String in object_string_to_tile_position.keys():
			if tile_position in object_string_to_tile_position[key] and (not check_ignore_tiles or (tile_position not in ignore_tiles)):
				object_string_to_tile_position[key].erase(tile_position)


static func static_get_tile(tilemap:TileMapLayer, selected_tile:String) -> Dictionary:
	return {
		"Physics":physics_tile_type_to_tile_data_dictionary[decorative_tiles_to_physics[selected_tile]],
		"Decorative": decorative_tiles_data_dictionary[selected_tile]
		}

# Check if there is multiple Spawnpoints
static func static_check_can_add_spawnpoint(
	object_string_name_to_tile_position:Dictionary[String, Array],
) -> bool:
	# Spawnpoint hasn't been placed yet
	if "Spawnpoint" not in object_string_name_to_tile_position:
		return true
	
	# Spawnpoint object has no location
	if len(object_string_name_to_tile_position["Spawnpoint"]) == 0:
		return true
	
	return false


static func static_check_can_add_goal(
	object_string_name_to_tile_position:Dictionary[String, Array],
) -> bool:
	# Goal hasn't been placed yet
	if "Goal" not in object_string_name_to_tile_position:
		return true
	
	# Spawnpoint object has no location
	if len(object_string_name_to_tile_position["Goal"]) == 0:
		return true
	
	return false



static func static_delete_all_by_object_name(
	object_name:String,
	tilemap:TileMapLayer, 
	tile_position:Vector2i, 
	object_string_to_tile_position:Dictionary[String, Array],
	tile_position_to_object_dictionary:Dictionary[Vector2i, Dictionary], 
	tile_position_to_bonus_parameters:Dictionary[Vector2i,Dictionary],
	ignore_tiles:Dictionary[Vector2i, bool],
	avoid_stack:bool, undo_stack:UndoStack,
) -> void:
	
	for pos:Vector2i in object_string_to_tile_position[object_name]:
		# Allows for dragging the spawnpoint and undoing to properly work
		
		if avoid_stack == false:
			undo_stack.push_dictionary({false:[], true:[]})
		static_delete_tile(tilemap, pos, tile_position_to_object_dictionary, tile_position_to_bonus_parameters, object_string_to_tile_position, false, ignore_tiles, false, undo_stack)
		


static func static_get_spawnpoint(
	object_string_name_to_tile_position:Dictionary[String, Array],
	tile_position_to_object_dictionary:Dictionary[Vector2i, Dictionary]
) -> Node2D:
	# Check if there is any tile positions associated with Spawnpoint
	if "Spawnpoint" in object_string_name_to_tile_position:
		if len(object_string_name_to_tile_position["Spawnpoint"]) == 1:
			if object_string_name_to_tile_position["Spawnpoint"][0] in tile_position_to_object_dictionary:
				return tile_position_to_object_dictionary[object_string_name_to_tile_position["Spawnpoint"][0]]["object"]
	
	return null


static func static_set_object(
	object_string:String,
	tilemap:TileMapLayer, 
	tile_position:Vector2i, 
	selected_object:PackedScene,
	testing_mode:bool,
	object_node:Node2D,
	tile_position_to_object_dictionary:Dictionary[Vector2i, Dictionary], 
	tile_position_to_bonus_parameters:Dictionary[Vector2i,Dictionary],
	object_string_to_tile_position:Dictionary[String, Array],
	object_bonus_parameters,
	ignore_tiles:Dictionary[Vector2i, bool],
	avoid_stack:bool, undo_stack:UndoStack,
	
) -> void:
	
	if not static_check_can_add_spawnpoint(object_string_to_tile_position) and object_string == "Spawnpoint" and tile_position not in ignore_tiles:
		static_delete_all_by_object_name("Spawnpoint", tilemap, tile_position, object_string_to_tile_position, tile_position_to_object_dictionary, tile_position_to_bonus_parameters, ignore_tiles, avoid_stack, undo_stack)
	
	if not static_check_can_add_goal(object_string_to_tile_position) and object_string == "Goal" and tile_position not in ignore_tiles:
		static_delete_all_by_object_name("Goal", tilemap, tile_position, object_string_to_tile_position, tile_position_to_object_dictionary, tile_position_to_bonus_parameters, ignore_tiles, avoid_stack, undo_stack)
	
	#if object_string != "Gem":
	if (tilemap.get_cell_tile_data(tile_position) == null and object_string == "Gem"):
		static_delete_tile(tilemap, tile_position, tile_position_to_object_dictionary, tile_position_to_bonus_parameters, object_string_to_tile_position, true, ignore_tiles, avoid_stack, undo_stack)
	#else:
		#static_delete_tile(tilemap, tile_position, tile_position_to_object_dictionary, tile_position_to_bonus_parameters, object_string_to_tile_position, true, ignore_tiles, avoid_stack, undo_stack)
		
		
		
	# Check to see if a tile is there already
	if tilemap.get_cell_tile_data(tile_position) != null and object_string != "Gem":
		tilemap.erase_cell(tile_position)
	
	if tile_position not in ignore_tiles:
		# Add new object to tree and dictionary
		var object:Object = selected_object.instantiate()
		
		# Check if there is parameters to take into account
		if object_bonus_parameters != {}:
			tile_position_to_bonus_parameters[tile_position] = object_bonus_parameters.duplicate()
		elif object_bonus_parameters == {} and tile_position_to_bonus_parameters.has(tile_position):
			tile_position_to_bonus_parameters.erase(tile_position)
		
		# Pause enemy Tiles
		static_pause_enemy_tiles(testing_mode, tile_position, object, selected_object, tile_position_to_bonus_parameters)
		
		# Add bonus Params
		static_add_bonus_params_to_objects(testing_mode, tile_position, object, tile_position_to_bonus_parameters)
		
		object.global_position = tilemap.map_to_local(tile_position)
		object_node.call_deferred("add_child", object)
		#object_node.add_child(object)
		
		tile_position_to_object_dictionary[tile_position] = {"object":null, "object_name":""}
		tile_position_to_object_dictionary[tile_position]["object"] = object
		tile_position_to_object_dictionary[tile_position]["object_name"] = object_string
		
		if object_string in object_string_to_tile_position:
			if tile_position not in object_string_to_tile_position[object_string]:
				object_string_to_tile_position[object_string].append(tile_position)
		else:
			object_string_to_tile_position[object_string] = [tile_position]
		
		ignore_tiles[tile_position] = true
	




static func update_object_bonus_parameters(
	tile_position:Vector2i,
	tile_pos_to_object_dictionary:Dictionary,
	tile_position_to_bonus_parameters:Dictionary,
) -> void:
	
	if not tile_position_to_bonus_parameters.has(tile_position):
		return
	
	if tile_position_to_bonus_parameters[tile_position].has("Distance"):
		tile_pos_to_object_dictionary[tile_position]["object"].patrol_distance = tile_position_to_bonus_parameters[tile_position]["Distance"]


static func static_pause_enemy_tiles(
	testing_mode:bool, 
	tile_position:Vector2i,
	object:Object, 
	selected_object:PackedScene,
	tile_position_to_bonus_parameters:Dictionary[Vector2i, Dictionary]
) -> void:
	if testing_mode:
		return
	
	if scene_dictionary[selected_object] == "Alien":
		object.in_editor = true
	
	if not tile_position_to_bonus_parameters.has(tile_position):
		return
	
	if tile_position_to_bonus_parameters[tile_position].has("Distance"):
		
		object.patrol_distance = tile_position_to_bonus_parameters[tile_position]["Distance"]
		#print(object.patrol_distance)


static func static_add_bonus_params_to_objects(
	testing_mode:bool,
	tile_position:Vector2i,
	object:Object,
	tile_position_to_bonus_parameters:Dictionary[Vector2i, Dictionary]
) -> void:
	if not testing_mode:
		return
	
	if not tile_position_to_bonus_parameters.has(tile_position):
		return
	
	if tile_position_to_bonus_parameters[tile_position].has("Distance"):
		object.patrol_distance = tile_position_to_bonus_parameters[tile_position]["Distance"]



static func static_set_tile(
	tilemap:TileMapLayer, tilemap_type:String, tile_position:Vector2i, selected_object:PackedScene,
	selected_tile:String,
	object_string:String,
	object_node:Node2D,
	tile_position_to_object_dictionary:Dictionary[Vector2i, Dictionary],
	tile_position_to_bonus_parameters:Dictionary[Vector2i, Dictionary],
	object_string_to_tile_position:Dictionary[String, Array],
	object_bonus_parameters,
	testing_mode:bool = false,
	ignore_tiles:Dictionary[Vector2i, bool] = {},
	avoid_stack:bool=false,
	undo_stack:UndoStack = null,
) -> void:
	if selected_object == null:
		# Get the tile data necessary to place selected tile
		var tile_data:Array = static_get_tile(tilemap, selected_tile)[tilemap_type]
		var source_id:int = tile_data[0]
		var atlas_coord:Vector2i = tile_data[1]
		var alt_tile:int = tile_data[2]
		
		# Delete the tile that was already there
		static_delete_tile(tilemap, tile_position, tile_position_to_object_dictionary, tile_position_to_bonus_parameters, object_string_to_tile_position, true, ignore_tiles, avoid_stack, undo_stack)
		
		# Set the new tile
		tilemap.set_cell(tile_position, source_id, atlas_coord, alt_tile)
		
		
		
		# Update the terrain
		if tilemap_type == "Decorative":
			BetterTerrain.update_terrain_cell(tilemap, tile_position,)
		
		ignore_tiles[tile_position] = true
	else:
		static_set_object(object_string, tilemap, tile_position, selected_object, testing_mode, object_node, tile_position_to_object_dictionary, tile_position_to_bonus_parameters, object_string_to_tile_position, object_bonus_parameters, ignore_tiles,avoid_stack, undo_stack)
	


var loading_level:bool = true
func set_tile(tile_map:TileMapLayer, tile_position:Vector2i,avoid_stack:bool=false) -> void:
	
	#decorative_tilemap.changed.emit()
	
	# Check is level creator wants to reset time to continue working on level
	if check_to_edit != null and players_beat_level and not loading_level:
		
		check_to_edit.prompt_for_decision(best_time_completed)
		
		var can_edit:bool = await check_to_edit.user_decided
		
		# If user doesn't want to remove their best time
		if can_edit == false:
			return
		
		# Reset the time
		best_time_completed = -1
		
		
	static_set_tile(decorative_tilemap, "Decorative", tile_position, selected_object, selected_tile, object_string, object_node, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters, object_string_name_to_tile_pos, object_bonus_parameters, testing_mode, ignore_tiles, false, undo_stack)
	


func pause_enemy_tiles(object:Object, tile_position:Vector2i) -> void:
	if testing_mode:
		return
	
	if scene_dictionary[selected_object] == "Alien":
		object.in_editor = true
	
	if not tile_pos_to_bonus_parameters.has(tile_position):
		return
	
	if tile_pos_to_bonus_parameters[tile_position].has("Distance"):
		object.patrol_distance = tile_pos_to_bonus_parameters[tile_position]["Distance"]



func add_bonus_params_to_objects(object:Object,tile_position:Vector2i) -> void:
	if not testing_mode:
		return
	
	if not tile_pos_to_bonus_parameters.has(tile_position):
		return
	
	if tile_pos_to_bonus_parameters[tile_position].has("Distance"):
		object.patrol_distance = tile_pos_to_bonus_parameters[tile_position]["Distance"]


# Deletes tile that is in use
func delete_tile(tile_map:TileMapLayer, tile_position:Vector2i, avoid_stack:bool=false):
	
	decorative_tilemap.changed.emit()
	
	# Check is level creator wants to reset time to continue working on level
	if check_to_edit != null and players_beat_level and not loading_level:
		
		check_to_edit.prompt_for_decision(best_time_completed)
		
		var can_edit:bool = await check_to_edit.user_decided
		
		# If user doesn't want to remove their best time
		if can_edit == false:
			return
		
		# Reset the time
		best_time_completed = -1
	
	static_delete_tile(tile_map, tile_position, tile_pos_to_object_dictionary, tile_pos_to_bonus_parameters, object_string_name_to_tile_pos, false, ignore_tiles, avoid_stack, undo_stack)
	



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
	
	var viewport_size = get_viewport_rect().size
	var x_offset = viewport_size.x / (2 * camera.zoom.x)
	var y_offset = viewport_size.y / (2 * camera.zoom.y)
	
	var clamped_x = clamp(camera.global_position.x, camera.limit_left + x_offset, camera.limit_right - x_offset)
	var clamped_y = clamp(camera.global_position.y, camera.limit_top + y_offset, camera.limit_bottom - y_offset)
	
	camera.global_position = Vector2(clamped_x, clamped_y)
	
	#camera.global_position.y = clampf(camera.global_position.y, -948, 8)
	#camera.global_position.y = clampf(camera.global_position.y, camera.limit_top*(1/camera.zoom.y), camera.limit_bottom*(1/camera.zoom.y))
	# End Camera Movement



func undo_logic() -> void:
	if Input.is_action_just_pressed("undo_level_editor"):
		var stack_value:Dictionary = undo_stack.pop()
		
		#print(undo_stack.stack_array)
		#print(stack_value)
		
		if len(stack_value) == 0:
			if save_animation_player.is_playing():
				save_animation_player.stop()
			
			save_animation_player.play("nothing_undo_fade_out")
			return
		
			
		# Push an empty array to catch the additions from delete tile function
		#undo_stack.push_dictionary({false:[],true:[]})
		
		
		
		
		for pos:Vector2i in stack_value[false]:
			delete_tile(physics_tilemap, pos, true)
			delete_tile(decorative_tilemap, pos, true)
		
		# Pop the array thats added from deleting tiles
		#undo_stack.pop()
		
		# Replacing tiles that were deleted
		var temp_selected_tile = selected_tile
		var temp_object = object_string
		var temp_selected_object = selected_object
		
		#print(stack_value[true])
		
		var temp_obj_bonus_params:Dictionary = object_bonus_parameters
		
		for arr:Array in stack_value[true]:
			
			ignore_tiles.clear()
			selected_tile = arr[0]
			object_string = arr[1]
			object_bonus_parameters = arr[3]
			
			if tile_pos_to_bonus_parameters.has(arr[2]):
				if object_bonus_parameters == {}:
					tile_pos_to_bonus_parameters[arr[2]] = {}
				tile_pos_to_bonus_parameters[arr[2]] = object_bonus_parameters
			
			if object_string in object_dictionary:
				selected_object = object_dictionary[object_string]
			else:
				selected_object = null
			set_tile(physics_tilemap, arr[2])
			set_tile(decorative_tilemap, arr[2])
		selected_tile = temp_selected_tile
		object_string = temp_object
		selected_object = temp_selected_object
		object_bonus_parameters = temp_obj_bonus_params



func place_tile_input_logic(event:InputEvent) -> void:
	if testing_mode == true:
		return
	
	if event is InputEventMouse:
		# Get the mouse position
		mouse_position = get_global_mouse_position()
	
		# Get the tilemap coords that the mouse is at
		tilemap_mouse_position = physics_tilemap.local_to_map(mouse_position)
	
	show_tile_place_preview(tilemap_mouse_position)
	
	
	undo_logic()
	
	
	# Place down a tile
	if Input.is_action_pressed("place_tile") and not prevent_tile_placement:
		place_held_down = true
		
	
	
	elif Input.is_action_just_released("place_tile"):
		place_held_down = false
	
	if Input.is_action_pressed("delete_tile") and not prevent_tile_placement:
		place_held_down = true
		
		if is_deleting == false:
			is_deleting = true
	elif Input.is_action_just_released("delete_tile"):
		place_held_down = false
		is_deleting = false





var folder_path:String = "user://level_editor/levels"
var save_path:String = folder_path + "/"
var level_name:String = "level_0.json"

func save_beat_level() -> void:
	var temp_time:float = best_time_completed
	
	#reload_tilemap_beat_level()
	
	
	#loading_thread.wait_to_finish()
	
	
	best_time_completed = temp_time
	
	save_logic()
	
	

func save_logic() -> void:
	
	# Create the directories needed to save the file
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	var file:FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	
	
	# Omit this to save almost half of the storage thats used to make levels
	# Save the level as a json
	#file.store_string("{\n\"PhysicsTilemap\":[\n")
	#file.store_string(JSON.stringify(JSON.from_native(physics_tilemap.get_used_cells_by_id(0)))+",\n")
	#file.store_string(JSON.stringify(JSON.from_native(physics_tilemap.get_used_cells_by_id(1)))+",\n")
	#file.store_string(JSON.stringify(JSON.from_native(physics_tilemap.get_used_cells_by_id(2)))+"\n")
	#file.store_string("],\n")
	
	file.store_string("{\"BestTimeCompleted\":")
	file.store_string(JSON.stringify(JSON.from_native(best_time_completed)) + ",\n")
	
	file.store_string("\"BackgroundType\":")
	file.store_string(JSON.stringify(JSON.from_native(background_type)) + ",\n")
	
	var decorative_tile_map_dict:Dictionary[int, Array] = {
		6: decorative_tilemap.get_used_cells_by_id(6),
		2: decorative_tilemap.get_used_cells_by_id(2),
		12: decorative_tilemap.get_used_cells_by_id(12),
		11: decorative_tilemap.get_used_cells_by_id(11),
	}
	
	if testing_mode:
		decorative_tile_map_dict = testing_save_for_level_complete
	
	
	# Save the decorative map
	file.store_string("\"DecorativeTilemap\":\n")
	file.store_string(JSON.stringify(JSON.from_native(decorative_tile_map_dict)))
	file.store_string(",\n")
	
	
	file.store_string("\"ObjectStringTilePos\":")
	
	file.store_string(JSON.stringify(JSON.from_native(object_string_name_to_tile_pos), "")+",\n")
	#file.store_string(",")
	
	file.store_string("\"TilePosBonusParameters\":")
	
	file.store_string(JSON.stringify(JSON.from_native(tile_pos_to_bonus_parameters), "")+"\n")
	file.store_string("}")
	
	
	if save_animation_player.is_playing():
		save_animation_player.stop()
	
	save_animation_player.play("save_fade_out")




func _load_logic_async(path_name:String = "") -> void:
	if load_or_save_ui:
		load_or_save_ui.queue_free()
		load_or_save_ui = null
	
	save_path = path_name
	
	# Disconnect the signal
	#decorative_tilemap.call_deferred("disconnect", "changed", "_handle_beat_level")
	#if decorative_tilemap.changed.is_connected(_handle_beat_level):
		#decorative_tilemap.changed.disconnect(_handle_beat_level)
	
	# Load level from json file
	if FileAccess.file_exists(save_path):
		
		# Open the json file for reading
		var file:FileAccess = FileAccess.open(save_path, FileAccess.READ)
		
		# Get the text from the file
		var json_string = file.get_as_text()
		
		
		
		if json_string == "": # See if the file is empty
			return # Return early to not cause any errors
		
		# Parse the text from the file in json style
		var json:Dictionary = JSON.parse_string(json_string)
		if json != null: # If there was no error parsing the text
			#var physics_tilemap_data = JSON.to_native(json["PhysicsTilemap"]) 
			# Convert json into native Godot types
			
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
			
			
			
			#print("Decorative_tilemap_data: ", decorative_tilemap_data)
			#print("TilePosBonusParameters: ", tile_pos_to_bonus_params)
			#print("ObjectStringTilePos: ", object_string_tile_pos)
			
			selected_object = null
			object_string = ""
			
			
			if decorative_tilemap_data:
				for id:int in decorative_source_id_to_tile_name.keys():#range(len(decorative_tilemap_data)):
					if decorative_tilemap_data.has(id):
						for pos:Vector2i in decorative_tilemap_data[id]:
							selected_tile = decorative_source_id_to_tile_name[id]
							#set_tile(physics_tilemap, pos)
							set_tile(decorative_tilemap, pos,)
			
			selected_tile = "Ground"
			
			# Load the bonus paramaters from the JSON file
			tile_pos_to_bonus_parameters = tile_pos_to_bonus_params
			
			# Load Objects
			for object_key in object_string_tile_pos.keys():
				for pos:Vector2i in object_string_tile_pos[object_key]:
					selected_object = object_dictionary[object_key]
					object_string = object_key
					
					if tile_pos_to_bonus_params.has(pos):
						object_bonus_parameters = tile_pos_to_bonus_params[pos]
					else:
						object_bonus_parameters = {}
					
					set_tile(physics_tilemap, pos)
			
			object_string = ""
			selected_object = null
			file.close()
			
			if "BestTimeCompleted" in json:
				best_time_completed = JSON.to_native(json["BestTimeCompleted"])
			print(best_time_completed)
			
			
	
	if testing_mode == false:
		level_editor_hud.call_deferred("show")
	
	prevent_tile_placement = false
	
	#decorative_tilemap.changed.connect(_handle_level_changed)
	loading_level = false
	call_deferred("emit_signal", "finished_loading")



signal finished_loading()


func _hide_loading_screen() -> void:
	if $LoadingScreen.visible or $LoadingScreen.hidden == false:
		$LoadingScreen._stop_loading()
		pass


var loading_thread:Thread =  null
# Loading Level
func load_logic(path_name:String="") -> void:
	
	$LoadingScreen._start_loading()
	
	
	
	#_load_logic_async(path_name)
	if loading_thread != null and not loading_thread.is_alive():
		loading_thread = Thread.new()
		loading_thread.start(
			func() -> void:
				_load_logic_async(path_name)
		)
	elif loading_thread == null:
		loading_thread = Thread.new()
		loading_thread.start(
			func() -> void:
				_load_logic_async(path_name)
		)
	
	#thread.start(_load_logic_async, [path_name])
	
	


func _input(event: InputEvent) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("save_level_editor"):
		print("Saved")
		save_logic()
	
	if Input.is_action_just_pressed("toggle_delete_tile_mode"):
		is_deleting = not is_deleting
		if Input.is_action_pressed("delete_tile"):
			is_deleting = not is_deleting
	
	# Camera Zooming In and Out
	if Input.is_action_pressed("camera_scroll_out"):
		var temp_zoom = camera.zoom - Vector2(0.5,0.5)
		
		camera.zoom = temp_zoom.clamp(Vector2(0.5, 0.5), Vector2(5,5))
	if Input.is_action_pressed("camera_scroll_in"):
		camera.zoom += Vector2(0.5,0.5)
		camera.zoom = camera.zoom.clamp(Vector2(0.5, 0.5), Vector2(5,5))
	if Input.is_action_just_pressed("camera_scroll_reset"):
		camera.zoom = Vector2(1,1)
	
	
	place_tile_input_logic(event)
	
	# When pause is pressed
	if Input.is_action_just_pressed("escape"):
		place_held_down = false





var player:Player = null
var checkpoint_mangager:CheckpointManager = null
var game_camera:GameCamera = null
var hud:CanvasLayer = null
var on_level_loaded:Node = null

var temp_bonus:Dictionary

var testing_save_for_level_complete:Dictionary[int, Array] = {
	
}

func test_level() -> void:
	testing_mode = true
	
	
	
	testing_save_for_level_complete = {
		6: decorative_tilemap.get_used_cells_by_id(6),
		2: decorative_tilemap.get_used_cells_by_id(2),
		12: decorative_tilemap.get_used_cells_by_id(12),
		11: decorative_tilemap.get_used_cells_by_id(11),
	}
	
	
	save_logic()
	
	
	temp_bonus = object_bonus_parameters
	object_bonus_parameters = {}
	
	
	reload_tilemaps()
	
	
	if loading_thread != null and loading_thread.is_alive():
		loading_thread.wait_to_finish()
	
	fix_physics_tile_map(physics_tilemap)
	
	
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
	
	hud.add_to_group("hud")
	player.add_to_group("player")
	
	$LevelEditorHud/TestLevelButton.hide()
	$Camera2D.hide()
	$Camera2D.enabled = false
	
	game_camera.enabled = true
	game_camera.zoom = Vector2(3,3)
	
	physics_tilemap.player = player
	
	var spawn_point:Node2D = get_spawnpoint()
	
	if spawn_point:
		player.global_position = spawn_point.global_position
	
	var goal:Goal = get_goal() as Goal
	
	if goal:
		goal.Sranktime = best_time_completed
		goal.new_time_got.connect(_handle_beat_level)
	
	add_child(player)
	add_child(checkpoint_mangager)
	add_child(game_camera)
	add_child(hud)
	add_child(on_level_loaded)
	
	level_editor_hud.hide()
	
	
	$TestingHud.show()


func _handle_beat_level(new_time:float) -> void:
	best_time_completed = new_time
	save_beat_level()
	#save_logic()


func _stop_testing() -> void:
	testing_mode = false
	game_camera.queue_free()
	player.queue_free()
	checkpoint_mangager.queue_free()
	hud.queue_free()
	on_level_loaded.queue_free()
	
	GameManager._handle_set_meter(0)
	
	#level_editor_hud.show()
	$TestingHud.hide()
	
	$LevelEditorHud/TestLevelButton.show()
	$Camera2D.show()
	$Camera2D.enabled = true
	
	physics_tilemap.player = null
	
	
	
	reload_tilemaps()
	
	if loading_thread != null and loading_thread.is_alive():
		loading_thread.wait_to_finish()
	
	#level_editor_hud.show()
	
	object_bonus_parameters = temp_bonus


func reload_tilemap_beat_level() -> void:
	loading_level = true
	# Disconnect the signal
	if decorative_tilemap.changed.is_connected(_handle_level_changed):
		decorative_tilemap.changed.disconnect(_handle_level_changed)
	
	#physics_tilemap.clear()
	decorative_tilemap.clear()
	object_string_name_to_tile_pos.clear()
	tile_pos_to_object_dictionary.clear()
	ignore_tiles.clear()
	
	_load_logic_async(save_path)
	
	#load_logic(save_path)


func reload_tilemaps() -> void:
	loading_level = true
	# Disconnect the signal
	if decorative_tilemap.changed.is_connected(_handle_level_changed):
		decorative_tilemap.changed.disconnect(_handle_level_changed)
	
	# Remove children from object node
	for child in object_node.get_children():
		child.queue_free()
	
	physics_tilemap.clear()
	decorative_tilemap.clear()
	object_string_name_to_tile_pos.clear()
	tile_pos_to_object_dictionary.clear()
	ignore_tiles.clear()
	
	_load_logic_async(save_path)
	#load_logic(save_path)
	
	




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
