@tool
extends LineEdit
class_name CustomLineEdit


signal input_value_changed(new_value:String, place_holder_text:String)
signal input_value_submitted(new_value:String, place_holder_text:String)

var input_value:String = "":
	set(new_value):
		if input_value != new_value:
			input_value = new_value
			emit_signal("input_value_changed", input_value, placeholder_text)


func _ready() -> void:
	text_changed.connect(_check_is_int)
	text_submitted.connect(_send_submitted_change)
	


func _check_is_int(new_text:String) -> void:
	input_value = new_text

func _send_submitted_change(new_text:String) -> void:
	input_value_submitted.emit(new_text, placeholder_text)
