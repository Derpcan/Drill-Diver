extends TextureButton
var mat = material

func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	get_tree().quit()
	
func _on_mouse_entered():
	mat.set_shader_parameter("useHologram", true)
	scale *= 1.1
 
func _on_mouse_exited():
	mat.set_shader_parameter("useHologram", false)
	scale /= 1.1
