extends Control

var debug_signal_map = {
	"TEST_TIMER_START": "start_timer",
	"TEST_TIMER_STOP": "stop_timer",
	"TEST_TIMER_SET": "set_timer",
	
	"TEST_METER_FILL": "fill_meter",
	"TEST_METER_DEPLETE": "deplete_meter",
	"TEST_METER_SET": "set_meter",
	
	"TEST_RECORD_SET": "set_record"
}

func _ready():
	# Connect each button in the debug hud to its intended signal
	for button in get_children():
		if button is Button:
			button.pressed.connect(Callable(self, "_on_press_emit_signal").bind(button.name))

func _on_press_emit_signal(button_name: String) -> void:
	if not debug_signal_map.has(button_name):
		print("HUD: No signal mapped for button: ", button_name)
		return
	
	var signal_name = debug_signal_map[button_name]
	print("HUD: Emitting signal: ", signal_name)
	
	match signal_name:
		"start_timer":
			GameManager.start_timer.emit()
		"stop_timer":
			GameManager.stop_timer.emit()
		"set_timer":
			GameManager.set_timer_to(100.55)
#----------------------------
		"fill_meter":
			GameManager.fill_meter.emit(10)
		"deplete_meter":
			GameManager.deplete_meter.emit(20)
		"set_meter":
			GameManager.set_meter.emit(50)
#----------------------------
		"set_record":
			GameManager.update_record.emit(GameManager.get_current_time())
#----------------------------
		_:
			return
