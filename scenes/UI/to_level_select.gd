extends CanvasLayer
@export var level_select:TextureButton

func _make_visible():
	level_select.visible = true
	level_select.disabled = false
