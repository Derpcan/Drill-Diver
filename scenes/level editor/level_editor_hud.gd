extends CanvasLayer
class_name LevelEditorHud


@export var test_level_button:TextureButton
@export var help_button:TextureButton
@export var tile_selector:TileSelector


func _ready() -> void:
	tile_selector.toggle_visible_help_button.connect(_toggle_help_visibility)
	tile_selector.toggle_visible_test_button.connect(_toggle_test_visibility)
	help_button.button_down.connect(_show_help_panel)


func _toggle_help_visibility() -> void:
	help_button.visible = not help_button.visible

func _toggle_test_visibility() -> void:
	test_level_button.visible = not test_level_button.visible


var help_panel = null
func _show_help_panel() -> void:
	if help_panel == null:
		help_panel = preload("res://scenes/level editor/help_menu/level_editor_help_menu.tscn").instantiate()
		add_child(help_panel)
	else:
		help_panel._close()
		help_panel = null
