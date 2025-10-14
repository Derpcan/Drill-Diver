extends Button

func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.pop_scene()

#func _input(event):
	#if event.is_action_pressed("escape"):
		#SceneManager.pop_scene()
