extends Control
class_name TileSelector

@export var open_close_button:Button


@export var anim_player:AnimationPlayer




@export var is_open:bool = true

signal tile_selector_state_changed(is_open:bool)

signal tile_selector_new_tile_selected(new_tile_string:String, bonus_params:Dictionary)


func _ready() -> void:
	open_close_button.pressed.connect(open_close_button_pressed)
	
	for hbox in get_tree().get_nodes_in_group("tile_selector_holder"):#$ColorRect/VBoxContainer.get_children():
		for child in hbox.get_children():
			child.tile_selected.connect(_tile_selected_handler)
	
	$AnimationPlayer2.play("hover")
	
	
	$OpenLabel.text = "Press \"" + InputMap.action_get_events("editor_quick_toggle_tile_selector")[0].as_text() + "\" to open!"
	$CloseLabel.text = "Press \"" + InputMap.action_get_events("editor_quick_toggle_tile_selector")[0].as_text() + "\" to close!"
	


func _tile_selected_handler(text:String, bonus_params:Dictionary) -> void:
	emit_signal("tile_selector_new_tile_selected", text, bonus_params)



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("editor_quick_toggle_tile_selector") and get_parent().visible == true:
		open_close_button_pressed()
	
	if Input.is_action_pressed("editor_move_down") or Input.is_action_pressed("editor_move_left") or\
Input.is_action_pressed("editor_move_up") or  Input.is_action_pressed("editor_move_right"):
		$Label.hide()


var times_opened_or_closed:int = 0:
	set(new_value):
		times_opened_or_closed = new_value
		
		if times_opened_or_closed > 5:
			$OpenLabel.hide()
			$CloseLabel.hide()




func show_open_label() -> void:
	pass



func open_close_button_pressed() -> void:
	if is_open == true:
		#if not anim_player.is_playing():
		times_opened_or_closed += 1
		emit_signal("tile_selector_state_changed", false)
		anim_player.play("close")
	
	if is_open == false:
		#if not anim_player.is_playing():
		times_opened_or_closed += 1
		#times_opened_or_closed += 1
		emit_signal("tile_selector_state_changed", true)
		anim_player.play("open")
