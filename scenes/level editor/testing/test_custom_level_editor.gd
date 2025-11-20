extends Node2D
class_name TestCustomLevelEditor


@export var level_file_path:String = ""
@onready var tilemap:TileMapLayer = $TileMapLayer3
var parent:LevelEditor

func _ready() -> void:
	pass
	if parent:
		parent.load_level_to_tilemap(tilemap)


var selected_tile:String = ""


func load_level() -> void:
	pass
