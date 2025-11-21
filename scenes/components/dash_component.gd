extends Node
class_name DashComponent

@onready var dash_hitbox: Area2D = owner.get_node_or_null("DashHitbox")

@export var dash_speed:float = 200

var dash_timer:Timer

var dash_cooldown_timer:Timer
@export var dash_time_cooldown:float
var on_dash_cooldown:bool = false

@export var dash_time:float = 0.25
var can_dash:bool = true

signal dash_start(new_velocity:Vector2)
signal dash_end

func _ready() -> void:
	dash_timer = Timer.new()
	dash_timer.autostart = false
	dash_timer.one_shot = true
	dash_timer.connect("timeout", _emit_dash_end_signal)
	dash_timer.timeout.connect(_disable_dashing)
	add_child(dash_timer)
	
	dash_cooldown_timer = Timer.new()
	dash_cooldown_timer.timeout.connect(_enable_dashing)
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.autostart = false
	add_child(dash_cooldown_timer)


func _enable_dashing() -> void:
	on_dash_cooldown = false

func _disable_dashing() -> void:
	on_dash_cooldown = true
	dash_cooldown_timer.start(dash_time_cooldown)

# Calculates the dash velocity given the direction.
# Starts a timer that lasts for the duration of the dash
func _calculate_dash(direction:Vector2) -> void:
	if on_dash_cooldown:
		return
	if can_dash and direction != Vector2.ZERO and dash_timer.is_stopped():
		var new_vel:Vector2 = direction * dash_speed
		emit_signal("dash_start", new_vel)
		# Timer is connected to movement component and will stop gravity from applying during the time the dash is active
		dash_timer.start(dash_time)
		_enable_hitbox() 
		can_dash = false
		

func _emit_dash_end_signal() -> void:
	emit_signal("dash_end")
	_disable_hitbox()
	dash_timer.stop()

func _disable_dash() -> void:
	can_dash = false

func _enable_dash() -> void:
	can_dash = true
	
func is_dashing() -> bool:
	return !dash_timer.is_stopped()
	
func _enable_hitbox() -> void:
	if dash_hitbox and dash_hitbox.get_child_count() > 0:
		dash_hitbox.get_child(0).disabled = false

func _disable_hitbox() -> void:
	if dash_hitbox and dash_hitbox.get_child_count() > 0:
		dash_hitbox.get_child(0).disabled = true
