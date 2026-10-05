extends CanvasLayer


func _ready() -> void:
	$AnimationPlayer.play("open")
	$Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer5/Close.connect("button_down", _close)
	$Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Move.connect("button_down", _open_movement_help_menu)
	$Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4/Camera.connect("button_down", _open_camera_help_menu)
	$Control/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/Save.connect("button_down", _open_save_help_menu)

func _close() -> void:
	$AnimationPlayer.play("close")


func _open_movement_help_menu() -> void:
	var movement_menu = preload("res://scenes/level editor/help_menu/editor_movement_question.tscn").instantiate()
	add_child(movement_menu)

func _open_camera_help_menu() -> void:
	var camera_menu = preload("res://scenes/level editor/help_menu/editor_camera_question.tscn").instantiate()
	add_child(camera_menu)

func _open_save_help_menu() -> void:
	var save_menu = preload("res://scenes/level editor/help_menu/editor_save_question.tscn").instantiate()
	add_child(save_menu)
