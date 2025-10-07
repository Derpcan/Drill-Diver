extends Button

func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.push_scene("res://scenes/pause_menu.tscn")
