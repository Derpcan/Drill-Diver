extends TileMapLayer
class_name TileMapLink

## This is the tilemap layer that has the script that handles the player's superdrill
@export var physics_tile_map:TileMapLayer


func _ready() -> void:
	if physics_tile_map == null:
		return
	
	if not physics_tile_map.has_signal("deleted_tile"):
		return
	
	physics_tile_map.deleted_tile.connect(_delete_tile)


func _delete_tile(coords:Vector2i) -> void:
	erase_cell(coords)
