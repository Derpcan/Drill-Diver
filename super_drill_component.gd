extends Node
class_name SuperDrillComponent

@onready var dash_hitbox: Area2D = owner.get_node("DashHitbox")
@onready var super_hitbox: Area2D = owner.get_node("SuperHitbox")
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
	super_hitbox.body_entered.connect(_on_super_hitbox_body_entered)
	add_child(super_drill_timer )

# Calculates the dash velocity given the direction.
# Starts a timer that lasts for the duration of the dash
func _calculate_dash(direction:Vector2) -> void:
	if can_super_drill and direction != Vector2.ZERO and super_drill_timer.is_stopped() and GameManager.get_current_charge() == 100:
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
	GameManager.emit_signal("set_meter", 0)

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

func _enable_super_drill_hitbox(_vel:Vector2):
	
	super_hitbox.get_child(0).disabled = false
	
	_vel = _vel.normalized()
	super_hitbox.get_child(0).rotation = _vel.angle() + PI
	
	# Allows drilling from  at weird angles
	if _vel.angle() >= -2.35619449615479 && _vel.angle() <= -0.78539818525314:
		super_hitbox.get_child(0).rotation += PI
		super_hitbox.get_child(0).position.y = -1.0

func _disable_super_drill_hitbox():
	super_hitbox.get_child(0).set_deferred("disabled", true)
	super_hitbox.get_child(0).position.y = 1.0
	



func _on_super_hitbox_body_entered(body):
	print("entered")
	if body is TileMapLayer:
		var tilemap_node = body
		
		# Get the pixel position of the Area2D.
		# This will vary depending on your game logic and where the Area2D is.
		var area_global_position = super_hitbox.global_position
		
		# Convert the pixel position to the TileMap's cell coordinates
		var cell_position = tilemap_node.local_to_map(area_global_position)
		cell_position.x += 1
		# Get the ID of the tile in that cell
		get_parent().emit_signal("super_drill_tile", cell_position)
		get_parent().emit_signal("super_drill_tile", cell_position+Vector2i(0,1))
		get_parent().emit_signal("super_drill_tile", cell_position-Vector2i(0,1))
		# Check if the cell contains a tile
		
