extends Button

func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.change_scene("res://scenes/main_menu.tscn")
