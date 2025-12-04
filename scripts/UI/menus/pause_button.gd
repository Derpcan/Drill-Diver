extends TextureButton

@export var tile_selector:TileSelector

func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.push_scene("res://scenes/level editor/pause_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("game_escape"):
		if tile_selector and tile_selector.is_open:
			tile_selector.open_close_button_pressed()
			return
		
		if get_parent().visible:
			SceneManager.push_scene("res://scenes/level editor/pause_menu.tscn")
