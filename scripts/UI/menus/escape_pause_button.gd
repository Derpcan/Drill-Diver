extends TextureButton
var mat = material
var focused = false
func _ready():
	grab_focus()
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	SceneManager.pop_scene()

#func _input(event):
	#if event.is_action_pressed("escape"):
		#SceneManager.pop_scene()

func _on_mouse_entered():
	if focused != true:
		mat.set_shader_parameter("useHologram", true)
		scale *= 1.1
		
 
func _on_mouse_exited():
	if focused == true:
		mat.set_shader_parameter("useHologram", false)
		scale /= 1.1
		focused = false
