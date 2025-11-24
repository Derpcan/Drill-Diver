extends CanvasLayer
class_name LoadOrSave


signal load_level()

signal create_new_level()

@export var load_button:TextureButton
@export var create_button:TextureButton
@export var back_button:TextureButton

func _ready() -> void:
	load_button.pressed.connect(_emit_load_level_signal)
	create_button.pressed.connect(_emit_create_new_level_signal)
	back_button.pressed.connect(_load_main_menu)
	$AnimatedSprite2D/AnimationPlayer.play("loop")

func _load_main_menu() -> void:
	SceneManager.pop_scene()
	SceneManager.change_scene("res://scenes/main_menu.tscn")


func _emit_load_level_signal() -> void:
	load_level.emit()

func _emit_create_new_level_signal() -> void:
	create_new_level.emit()
