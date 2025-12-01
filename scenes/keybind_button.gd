extends Button


func _ready():
	grab_focus()
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.push_scene("res://scenes/UI/keybind_settings/keybind_settings.tscn")
