extends Button


func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.push_scene("res://scenes/UI/audio_settings/audio_settings.tscn")
