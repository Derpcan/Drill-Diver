extends CanvasLayer
class_name ChangeButton


signal save_new_input(new_input:InputEvent, change_button:ChangeButton)
signal destroying(change_button:ChangeButton)

var previous_event:InputEvent = null
var event_pressed:InputEvent = null:
	set(new_event):
		previous_event = event_pressed
		event_pressed = new_event
		
		if input_label != null:
			input_label.text = event_pressed.as_text()


@onready var input_label:Label = $PanelContainer/MarginContainer/VFlowContainer/InputLabel

@onready var cancel_button:Button = $PanelContainer/MarginContainer/VFlowContainer/HFlowContainer/CancelButton
@onready var save_button:Button = $PanelContainer/MarginContainer/VFlowContainer/HFlowContainer/SaveButton

func _ready() -> void:
	save_button.grab_focus()
	cancel_button.pressed.connect(_cancel)
	save_button.pressed.connect(_save)

func _save() -> void:
	emit_signal("save_new_input", event_pressed, self)
	SceneManager.pop_scene()

func _cancel() -> void:
	emit_signal("destroying", self)
	SceneManager.pop_scene()


func _unhandled_input(event: InputEvent) -> void:
	if event_pressed and event.as_text() == event_pressed.as_text():
		return
	if event is InputEventMouseMotion:
		return
	if event.is_action_pressed("game_escape"):
		SceneManager.pop_scene()
		return
	
	event_pressed = event
