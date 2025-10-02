extends Node

# This enables global signal transfer in the case where many different nodes may send the same sign-
# al to one recipient (or many recipients), which unties signals from specific nodes as a broker.

# Add any signals you want to be globally available below, then use them like:
#	emitter		==> "GameManager.custom_signal.emit(args)"
#	receiver	==> "GameManager.custom_signal.connect(handler)"
@warning_ignore_start("unused_signal")

# Game Logic
signal start_timer
signal stop_timer

# UI Elements
signal update_timer(seconds: float)

signal fill_meter(amount: int)
signal deplete_meter(amount: int)
signal set_meter(amount: int)

signal update_record(time: int)

@warning_ignore_restore("unused_signal")

func _ready():
	print("Game Manager running...")
	
	self.start_timer.connect(_handle_start_timer)
	self.stop_timer.connect(_handle_stop_timer)

# Game Timer Functionality -----------------------------------------------------
var _timer_running: bool = false
var _current_time: float = 0.0 # Time elapsed in seconds

func _handle_start_timer() -> void:
	_timer_running = true

func _handle_stop_timer() -> void:
	_timer_running = false

# Sets the UI HUD timer to the designated time in seconds
func set_timer_to(seconds: float) -> void:
	_current_time = seconds
	self.update_timer.emit(_current_time)

# Public accessor for the current timer value in seconds
func get_current_time():
	return _current_time

# Utility function for getting a string-formatted timer value
func convert_to_readable_time(seconds: float):
	var minutes: int = int(seconds / 60)
	var remainder: int = int(seconds) % 60
	var fractional: int = int((seconds - int(seconds)) * 100)
	
	var readable_time = "%02d:%02d.%02d" % [minutes, remainder, fractional]
	
	return readable_time

# Godot built-in for updating every frame
func _process(delta):
	if _timer_running:
		_current_time += delta
		self.update_timer.emit(_current_time)
