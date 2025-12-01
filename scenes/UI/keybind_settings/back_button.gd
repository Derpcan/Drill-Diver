extends Button

func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.pop_scene()
	#SceneManager.change_scene("res://scenes/options.tscn")
