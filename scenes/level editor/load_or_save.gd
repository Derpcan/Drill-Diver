extends CanvasLayer
class_name LoadOrSave


signal load_level()

signal create_new_level()

@export var load_button:TextureButton
@export var create_button:TextureButton

func _ready() -> void:
	load_button.pressed.connect(_emit_load_level_signal)
	create_button.pressed.connect(_emit_create_new_level_signal)
	$AnimatedSprite2D/AnimationPlayer.play("loop")


func _emit_load_level_signal() -> void:
	load_level.emit()

func _emit_create_new_level_signal() -> void:
	create_new_level.emit()
