extends Control

signal start_timer
signal stop_timer
signal set_timer(time: int)

signal fill_meter(value: int)
signal deplete_meter(value: int)
signal set_meter(value: int)

signal set_record(time: int)

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
			start_timer.emit()
		"stop_timer":
			stop_timer.emit()
		"set_timer":
			set_timer.emit(0)
#----------------------------
		"fill_meter":
			fill_meter.emit(10)
		"deplete_meter":
			deplete_meter.emit(10)
		"set_meter":
			set_meter.emit(50)
#----------------------------
		"set_record":
			set_record.emit(0)
#----------------------------
		_:
			return
