extends Button

func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.push_scene("res://scenes/level editor/level_editor_pause_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("escape"):
		SceneManager.push_scene("res://scenes/level editor/level_editor_pause_menu.tscn")
