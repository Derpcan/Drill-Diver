@tool
extends Control
class_name PopupDialog

@export var text:String = "Example Text":
	set(new_value):
		text = new_value
		
		if label:
			label.text = text

@onready var label:Label = $Label

func _ready() -> void:
	label.text = text
	$AnimationPlayer.play("hover")
	$AnimationPlayer2.play("fade_out")
