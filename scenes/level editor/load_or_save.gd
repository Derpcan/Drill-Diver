extends CanvasLayer
class_name LoadOrSave


signal load_level()

signal create_new_level()

func _ready() -> void:
	$Control/ColorRect/VBoxContainer/HBoxContainer2/Load.pressed.connect(_emit_load_level_signal)
	$Control/ColorRect/VBoxContainer/HBoxContainer2/Create.pressed.connect(_emit_create_new_level_signal)


func _emit_load_level_signal() -> void:
	load_level.emit()

func _emit_create_new_level_signal() -> void:
	create_new_level.emit()
