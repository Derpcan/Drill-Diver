extends Node
class_name SuperDrillComponent

@onready var dash_hitbox: Area2D = owner.get_node("DashHitbox")

@export var super_drill_speed:float = 175

var super_drill_timer:Timer

@export var super_drill_time:float = 0.25
var can_super_drill:bool = true

signal super_drill_start(new_velocity:Vector2)
signal super_drill_end

func _ready() -> void:
	super_drill_timer = Timer.new()
	super_drill_timer.autostart = false
	super_drill_timer.one_shot = true
	super_drill_timer.connect("timeout", _emit_super_drill_end_signal)
	add_child(super_drill_timer )

# Calculates the dash velocity given the direction.
# Starts a timer that lasts for the duration of the dash
func _calculate_dash(direction:Vector2) -> void:
	if can_super_drill and direction != Vector2.ZERO and super_drill_timer.is_stopped():
		var new_vel:Vector2 = direction * super_drill_speed
		emit_signal("super_drill_start", new_vel)
		print("super drill")
		# Timer is connected to movement component and will stop gravity from applying during the time the dash is active
		super_drill_timer.start(super_drill_time)
		_enable_hitbox() 
		can_super_drill = false
		

func _emit_super_drill_end_signal() -> void:
	emit_signal("super_drill_end")
	_disable_hitbox()
	super_drill_timer.stop()

func _disable_dash() -> void:
	can_super_drill = false

func _enable_dash() -> void:
	can_super_drill = true
	
func is_dashing() -> bool:
	return !super_drill_timer.is_stopped()
	
func _enable_hitbox() -> void:
	if dash_hitbox and dash_hitbox.get_child_count() > 0:
		dash_hitbox.get_child(0).disabled = false

func _disable_hitbox() -> void:
	if dash_hitbox and dash_hitbox.get_child_count() > 0:
		dash_hitbox.get_child(0).disabled = true
