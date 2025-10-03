extends Node
class_name DashComponent


@export var dash_speed:float = 200

var dash_timer:Timer

@export var dash_time:float = 0.25
var can_dash:bool = true

signal dash_start(new_velocity:Vector2)
signal dash_end

func _ready() -> void:
	dash_timer = Timer.new()
	dash_timer.autostart = false
	dash_timer.one_shot = true
	dash_timer.connect("timeout", _emit_dash_end_signal)
	add_child(dash_timer)

# Calculates the dash velocity given the direction.
# Starts a timer that lasts for the duration of the dash
func _calculate_dash(direction:Vector2) -> void:
	if can_dash and direction != Vector2.ZERO and dash_timer.is_stopped():
		var new_vel:Vector2 = direction * dash_speed
		emit_signal("dash_start", new_vel)
		# Timer is connected to movement component and will stop gravity from applying during the time the dash is active
		dash_timer.start(dash_time) 
		can_dash = false
		

func _emit_dash_end_signal() -> void:
	emit_signal("dash_end")
	dash_timer.stop()

func _disable_dash() -> void:
	can_dash = false

func _enable_dash() -> void:
	can_dash = true
