extends CanvasLayer
class_name LoadingScreen


@export var hidden:bool = true


func _ready() -> void:
	hide()

func _start_loading() -> void:
	$StopLoadingAnimationPlayer.stop()
	print("STARTING")
	visible = true
	hidden = false
	$Node2D.modulate = Color(1,1,1,1)
	$LoadingAnimationPlayer.play("start_load")




func _stop_loading() -> void:
	$StopLoadingAnimationPlayer.play("stop_loading")
