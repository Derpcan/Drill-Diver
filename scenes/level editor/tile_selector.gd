extends Control
class_name TileSelector

@export var open_close_button:Button


@export var anim_player:AnimationPlayer


@export var is_open:bool = true

signal tile_selector_state_changed(is_open:bool)


func _ready() -> void:
	open_close_button.pressed.connect(open_close_button_pressed)


func open_close_button_pressed() -> void:
	if is_open == true:
		emit_signal("tile_selector_state_changed", false)
		anim_player.play("close")
	
	if is_open == false:
		emit_signal("tile_selector_state_changed", true)
		anim_player.play("open")
