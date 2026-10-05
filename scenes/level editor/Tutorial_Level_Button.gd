extends Button

func _ready():
	self.pressed.connect(_handle_on_press)
	#$FileDialog.file_selected.connect(file_selected)

func _handle_on_press():
	SceneManager.change_scene("res://scenes/level editor/testing/tutorial_level_loader.tscn")
