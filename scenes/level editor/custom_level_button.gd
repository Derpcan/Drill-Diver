extends Button

func _ready():
	self.pressed.connect(_handle_on_press)
	$FileDialog.file_selected.connect(file_selected)

func _handle_on_press():
	#SceneManager.change_scene("res://scenes/test_scene.tscn")
	$FileDialog.show()


func file_selected(file_path:String):
	SceneManager.change_scene_extra_args("res://scenes/level editor/testing/test_custom_level_editor.tscn", [file_path])
