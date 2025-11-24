@tool
extends TextureButton
class_name CustomButton

var mat = material

@onready var label:Label = $HBoxContainer/Label

@export var button_string:String:
	set(new_string):
		button_string = new_string
		
		if label:
			label.text = button_string

func _ready():
	self.pressed.connect(_handle_on_press)
	label.text = button_string
	

func _handle_on_press():
	pass


func _on_mouse_entered():
	mat.set_shader_parameter("useHologram", true)
	scale *= 1.1
 
func _on_mouse_exited():
	mat.set_shader_parameter("useHologram", false)
	scale /= 1.1
