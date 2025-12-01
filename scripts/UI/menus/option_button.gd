extends TextureButton
var mat = material
var focused = false
func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	get_parent().get_parent().get_node("ButtonSound").play()
	SceneManager.change_scene("res://scenes/options.tscn")

func _on_mouse_entered():
	if focused != true:
		mat.set_shader_parameter("useHologram", true)
		scale *= 1.1
		focused = true
 
func _on_mouse_exited():
	if focused == true:
		mat.set_shader_parameter("useHologram", false)
		scale /= 1.1
		focused = false
