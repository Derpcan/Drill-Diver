extends Node2D
class_name OpeningScene
@export var animation:AnimationPlayer
@export var player:Player

signal break_out_ended

func _ready():
	$Player.input_component._disable_inputs()
	_play_floating()


func _play_floating():
	animation.play("Floating")
	Dialogic.start("res://dialogue/Timelines/Opening.dtl")
	await  Dialogic.timeline_ended
	_play_break_out()
	
func _play_break_out():
	
	animation.play("Break Out")
	await animation.animation_finished
	Dialogic.start("res://dialogue/Timelines/Opening2.dtl")
	await  Dialogic.timeline_ended
	break_out_ended.emit()


func _on_break_out_ended():
	#animation.play("Start Gameplay")
	#await  animation.animation_finished
	#$Player.visible = true
	#$Bit.visible = false
	
	
	$Player.visible = true
	$Bit.visible = false
	
	$Player.input_component._enable_inputs()
	$Music.play()
	pass
