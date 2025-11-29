extends Button

func _ready():
	self.pressed.connect(_handle_on_press)
	$FileDialog.file_selected.connect(file_selected)

func _handle_on_press():
	#SceneManager.change_scene("res://scenes/test_scene.tscn")
	$FileDialog.show()


func file_selected(file_path:String):
	SceneManager.change_scene_extra_args("/Users/logangeorgi/Documents/GitHub/Drill-Diver/scenes/level editor/testing/tutorial_level_loader.tscn", [file_path])
