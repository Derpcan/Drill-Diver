extends CanvasLayer
class_name LoadingScreen


@export var hidden:bool = true


func _ready() -> void:
	hide()

func _start_loading() -> void:
	print("STARTING")
	visible = true
	$LoadingAnimationPlayer.play("start_load")




func _stop_loading() -> void:
	$StopLoadingAnimationPlayer.play("stop_loading")
