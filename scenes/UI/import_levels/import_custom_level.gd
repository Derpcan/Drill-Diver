extends Control
class_name ImportCustomLevel


@export var file_dialog:FileDialog
signal file_chosen(new_file_path:String)

func _ready() -> void:
	#file_dialog.add_filter(".lvl", "Level files end with .lvl")
	file_dialog.show()
	
	file_dialog.file_selected.connect(_file_selected)
	file_dialog.close_requested.connect(_close)
	file_dialog.canceled.connect(_close)



var folder_path:String = "user://level_editor/levels"
var save_path:String = folder_path + "/"

func _file_selected(new_path:String) -> void:
	
	var file_name:String = new_path.split("/")[-1]
	
	DirAccess.copy_absolute(new_path, save_path + "imported_" + file_name)
	emit_signal("file_chosen", save_path + "imported_" + file_name)
	queue_free()


func _close() -> void:
	queue_free()
