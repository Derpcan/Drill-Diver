@tool
extends Control
class_name ShowEditBonusParameters


@onready var object_name_label:Label = $Container/MarginContainer/VBoxContainer/ObjectNameLabel
@onready var tile_position_label:Label = $Container/MarginContainer/VBoxContainer/TilePositionLabel
@onready var close_button:Button = $CloseButton

@export var object_name:String = "Example":
	set(new_name):
		object_name = new_name
		if new_name == "":
			object_name = "Example"
		
		if object_name_label:
			object_name_label.text = object_name


@export var tile_position:Vector2i = Vector2i.ZERO:
	set(new_position):
		tile_position = new_position
		
		if tile_position_label:
			tile_position_label.text = str(tile_position)


var bonus_parameters_dictionary:Dictionary = {}:
	set(new_dictionary):
		bonus_parameters_dictionary = new_dictionary.duplicate()
		
		for key in bonus_parameters_dictionary.keys():
			if key_to_line_edit_dict.has(key):
				key_to_line_edit_dict[key].text = str(bonus_parameters_dictionary[key])




signal bonus_parameter_changed(tile_position:Vector2i, bonus_parameters:Dictionary)
signal bonus_parameter_submitted(tile_position:Vector2i, bonus_parameters:Dictionary)


func _ready() -> void:
	add_bonus_parameters(bonus_parameters_dictionary)
	tile_position_label.text = str(tile_position)
	object_name_label.text = object_name
	close_button.connect("pressed", queue_free)




var key_to_line_edit_dict:Dictionary[String, LineEdit] = {}

@onready var bonus_params_holder:Control = $Container/MarginContainer/VBoxContainer/BonusParametersHolder

func add_bonus_parameters(dict:Dictionary) -> void:
	if dict == {}:
		$Container/MarginContainer/VBoxContainer/HSeparator2.hide()
		$Container/MarginContainer/VBoxContainer/Label.hide()
		bonus_params_holder.hide()
	else:
		$Container/MarginContainer/VBoxContainer/HSeparator2.show()
		$Container/MarginContainer/VBoxContainer/Label.show()
		bonus_params_holder.show()
	
	for key in dict.keys():
		var h_flow:HFlowContainer = HFlowContainer.new()
		var label:Label = Label.new()
		var line_edit:LineEdit
		
		if dict[key] is int:
			line_edit = preload("res://scenes/level editor/tile_selector_ui/number_edit.tscn").instantiate()
		else:
			line_edit = preload("res://scenes/level editor/bonus_parameters/custom_line_edit.tscn").instantiate()
		
		line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		h_flow.add_child(label)
		h_flow.add_child(line_edit)
		
		label.text = key + ": "
		line_edit.text = str(dict[key])
		
		
		bonus_params_holder.add_child(h_flow)
		
		key_to_line_edit_dict[key] = line_edit
		line_edit.placeholder_text = key
		line_edit.input_value_changed.connect(_update_bonus_parameters)
		line_edit.input_value_submitted.connect(_send_updated_bonus_parameters)


func _send_updated_bonus_parameters(_new_value, _place_holder_text) -> void:
	#if bonus_parameters_dictionary[place_holder_text] != new_value:
		#bonus_parameters_dictionary[place_holder_text] = new_value
	emit_signal("bonus_parameter_submitted", tile_position, bonus_parameters_dictionary)


func _update_bonus_parameters(new_value, place_holder_text:String) -> void:
	if bonus_parameters_dictionary[place_holder_text] != new_value:
		bonus_parameters_dictionary[place_holder_text] = new_value
		emit_signal("bonus_parameter_changed", tile_position, bonus_parameters_dictionary)
