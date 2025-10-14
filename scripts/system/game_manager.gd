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

signal fill_meter(amount: int)
signal deplete_meter(amount: int)
signal set_meter(amount: int)

# UI Elements
signal update_timer(seconds: float)
signal update_record(seconds: float)

signal update_meter(amount: int)

@warning_ignore_restore("unused_signal")

## Game Data and Stats ---------------------------------------------------------
# Game Timer
var _timer_running: bool = false
var _timer_can_be_started: bool = true
var _current_time: float = 0.0 # Time elapsed in seconds
var _best_time: float = 0.0 # The current record best time in seconds (temporary)

# Super Drill
const DRILL_METER_MIN = 0
const DRILL_METER_MAX = 100
var _drill_meter_charge: int = 0 # The current amount of drill meter charge

func _ready():
	print("Game Manager running...")
	
	self.start_timer.connect(_handle_start_timer)
	self.stop_timer.connect(_handle_stop_timer)
	
	self.fill_meter.connect(_handle_fill_meter)
	self.deplete_meter.connect(_handle_deplete_meter)
	self.set_meter.connect(_handle_set_meter)

## Game Timer Functionality ----------------------------------------------------
func _handle_start_timer() -> void:
	_timer_running = true

func _handle_stop_timer() -> void:
	_timer_running = false

# Sets the UI HUD timer to the designated time in seconds
func set_timer_to(seconds: float) -> void:
	_current_time = seconds
	self.update_timer.emit(_current_time)

# Sets the UI HUD record to the designated time in seconds
func set_record_to(seconds: float) -> void:
	_best_time = seconds
	self.update_record.emit(_best_time)

# Public accessor for the current timer value in seconds
func get_current_time():
	return _current_time

# Public utility for locking out timer-starting nodes
func timer_can_start() -> bool:
	return _timer_can_be_started and (not _timer_running)

# Public setter of the timer lockout flag
func set_timer_can_start(flag: bool) -> void:
	_timer_can_be_started = flag

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

## Super Drill Meter -----------------------------------------------------------
func _handle_fill_meter(amount: int) -> void:
	_drill_meter_charge = clamp(_drill_meter_charge + amount, DRILL_METER_MIN, DRILL_METER_MAX)
	self.update_meter.emit(_drill_meter_charge)
	
func _handle_deplete_meter(amount: int) -> void:
	_drill_meter_charge = clamp(_drill_meter_charge - amount, DRILL_METER_MIN, DRILL_METER_MAX)
	self.update_meter.emit(_drill_meter_charge)
	
func _handle_set_meter(amount: int) -> void:
	_drill_meter_charge = clamp(amount, DRILL_METER_MIN, DRILL_METER_MAX)
	self.update_meter.emit(_drill_meter_charge)

# Public accessor for the current drill meter charge
func get_current_charge() -> int:
	return _drill_meter_charge
