@tool
extends LineEdit
class_name NumberEdit


signal input_value_changed(new_value:int, place_holder_text:String)
signal input_value_submitted(new_value:int, place_holder_text:String)

var input_int_value:int = 0:
	set(new_value):
		if input_int_value != new_value:
			input_int_value = new_value
			emit_signal("input_value_changed", input_int_value, placeholder_text)


func _ready() -> void:
	text_changed.connect(_check_is_int)
	text_submitted.connect(_send_submitted_change)





func _send_submitted_change(_new_text:String) -> void:
	input_value_submitted.emit(input_int_value, placeholder_text)


func _check_is_int(new_text:String) -> void:
	var caret_pos = caret_column
	
	var is_valid:bool = new_text.is_valid_int()
	
	if is_valid:
		input_int_value = new_text.to_int()
	else:
		var num_removed:int = 0
		
		var index:int = 0
		while index < new_text.length():
			if not new_text.substr(index, 1).is_valid_int():
				num_removed += 1
				new_text = new_text.erase(index, 1)
				
			else:
				index += 1
		
		
		text = new_text
		input_int_value = text.to_int()
		caret_column = caret_pos-num_removed
