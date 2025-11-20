extends Button

func _ready():
	self.pressed.connect(_handle_on_press)
	$FileDialog.file_selected.connect(file_selected)

func _handle_on_press():
	#SceneManager.change_scene("res://scenes/test_scene.tscn")
	$FileDialog.show()


func file_selected(file_path:String):
	pass
