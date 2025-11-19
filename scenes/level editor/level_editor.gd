extends Node2D


@onready var physics_tilemap:TileMapLayer = $PhysicsTileMap
@onready var decorative_tilemap:TileMapLayer = $DecorativeTileMap
@onready var preview_tilemap:TileMapLayer = $PreviewTileMap
@onready var level_editor_hud:CanvasLayer = $LevelEditorHud

@onready var camera:Camera2D = $Camera2D

var prevent_tile_placement:bool = true:
	set(new_value):
		prevent_tile_placement = new_value
		
		if prevent_tile_placement == true:
			preview_tilemap.clear()

var mouse_position:Vector2 = Vector2.ZERO

var tilemap_mouse_position:Vector2 = Vector2.ZERO


# The toggle for if the editor should be deleting tiles or placing
var is_deleting:bool = false:
	set(new_value):
		is_deleting = new_value



enum tile_types {
	UNDRILLABLE, # Hard material, used for floors or roofs that can't be passed
	DRILLABLE, # Material you can drill through
	SUPERDRILLABLE, # Material you need super drill to get through
}



var selected_tile:int = 0



func _ready() -> void:
	# Get the tile selector
	var tile_selector:TileSelector = level_editor_hud.get_node("TileSelector") as TileSelector
	tile_selector.tile_selector_state_changed.connect(tile_selector_changed)



# Block or unblock placing tiles
func tile_selector_changed(is_open:bool) -> void:
	if is_open == true:
		prevent_tile_placement = true
	
	if is_open == false:
		prevent_tile_placement = false




func get_tile() -> Array:
	
	return [0, Vector2i(0,0), 0]



func set_tile( tile_map:TileMapLayer, tile_position:Vector2i,) -> void:
	var tile_data:Array = get_tile()
	var source_id:int = tile_data[0]
	var atlas_coord:Vector2i = tile_data[1]
	var alt_tile:int = tile_data[2]
	
	tile_map.set_cell(tile_position, source_id, atlas_coord, alt_tile)




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
	if prevent_tile_placement == true:
		return
	
	
	# Allows for the camera to move
	var dir_x:float = Input.get_action_strength("move_right")-Input.get_action_strength("move_left")
	var dir_y:float = Input.get_action_strength("move_down")-Input.get_action_strength("move_up")
	
	camera.global_position.x += dir_x*4
	camera.global_position.y += dir_y*4
	# End Camera Movement


func _unhandled_input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("toggle_delete_tile_mode"):
		is_deleting = not is_deleting
	
	
	# Get the mouse position
	mouse_position = get_global_mouse_position()
	
	# Get the tilemap coords that the mouse is at
	tilemap_mouse_position = physics_tilemap.local_to_map(mouse_position)
	
	show_tile_place_preview(tilemap_mouse_position)
	
	
	print("Mouse Position: ", mouse_position)
	print("Tilemap Mouse Position: ", tilemap_mouse_position)
	
	# Place down a tile
	if Input.is_action_pressed("place_tile") and not prevent_tile_placement:
		var tile_data:Array = get_tile()
		
		print("placed")
		if is_deleting == false:
			set_tile( physics_tilemap, tilemap_mouse_position,)
		if is_deleting == true:
			physics_tilemap.set_cell(tilemap_mouse_position, -1, Vector2i(-1,-1), 0)
		
