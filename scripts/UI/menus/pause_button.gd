extends TextureButton

func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.push_scene("res://scenes/level editor/pause_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("game_escape") and get_parent().visible:
		SceneManager.push_scene("res://scenes/level editor/pause_menu.tscn")
