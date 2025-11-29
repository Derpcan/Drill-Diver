@tool
extends TextureButton
class_name CustomButton

var mat = material
var hover = texture_hover
var empty = texture_disabled
var normal = texture_normal

@onready var label:Label = $HBoxContainer/Label
@onready var textBox:HBoxContainer = $HBoxContainer
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
	
	#mat.set_shader_parameter("useHologram", true)
	textBox.position.y = 4.579
	
 
func _on_mouse_exited():
	#mat.set_shader_parameter("useHologram", false)
	textBox.position.y = 2.579
	


func _on_button_down():
	texture_focused = empty
	texture_normal = normal
	textBox.position.y = 6.579


func _on_focus_entered():
	texture_focused =hover
	texture_normal = empty
	textBox.position.y = 4.579 
	


func _on_focus_exited():
	texture_normal = normal
	textBox.position.y = 2.579
