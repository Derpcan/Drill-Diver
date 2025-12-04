extends CanvasLayer
@export var level_select:TextureButton
@export var retry:TextureButton
func _make_visible():
	level_select.grab_focus()
	level_select.visible = true
	level_select.disabled = false
	retry.visible = true
	retry.disabled = false	
