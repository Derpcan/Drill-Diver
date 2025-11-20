extends Control
class_name TileSelector

@export var open_close_button:Button


@export var anim_player:AnimationPlayer


@export var is_open:bool = true

signal tile_selector_state_changed(is_open:bool)

signal tile_selector_new_tile_selected(new_tile_string:String)


func _ready() -> void:
	open_close_button.pressed.connect(open_close_button_pressed)
	
	for hbox in $ColorRect/VBoxContainer.get_children():
		for child in hbox.get_children():
			child.tile_selected.connect(_tile_selected_handler)


func _tile_selected_handler(text:String) -> void:
	emit_signal("tile_selector_new_tile_selected", text)



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quick_toggle_tile_selector"):
		open_close_button_pressed()
	
	



func open_close_button_pressed() -> void:
	if is_open == true:
		emit_signal("tile_selector_state_changed", false)
		anim_player.play("close")
	
	if is_open == false:
		emit_signal("tile_selector_state_changed", true)
		anim_player.play("open")
