extends TextureButton
var mat = material
var focused = false

func _ready():
	self.grab_focus()
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	if get_parent().get_node("ButtonSound"):
		get_parent().get_node("ButtonSound").play()
	SceneManager.push_scene("res://scenes/UI/audio_settings/audio_settings.tscn")
	


func _on_mouse_entered():
	if focused != true:
		mat.set_shader_parameter("useHologram", true)
		scale *= 1.1
		focused = true
		
 
func _on_mouse_exited():
	if focused==true:
		mat.set_shader_parameter("useHologram", false)
		scale /= 1.1
		focused = false

func _unhandled_input(event):
	if focused == false and get_parent().get_node("Edit Keybinds").focused == false and get_parent().get_node("Back").focused == false:
		self.grab_focus()
