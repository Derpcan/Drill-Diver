extends CanvasLayer
@export var level_select:Button

func _make_visible():
	level_select.visible = true
	level_select.disabled = false
