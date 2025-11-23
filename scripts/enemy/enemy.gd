extends CharacterBody2D
class_name Enemy
# 1. MOVEMENT PROPERTIES
@export var speed: float = 20
@export var patrol_distance: float = 10: # How far the enemy walks from its start point
	set(new_distance):
		patrol_distance = new_distance
		
		if not in_editor:
			return
		
		if line_2d != null:
			line_2d.clear_points()
			line_2d.add_point(Vector2(-patrol_distance, 0))
			line_2d.add_point(Vector2(+patrol_distance, 0))
			
		else:
			#line_2d = Line2D.new()
			#line_2d.add_point(Vector2(-patrol_distance, 0))
			#line_2d.add_point(Vector2(+patrol_distance, 0))
			#line_2d.default_color = Color.from_rgba8(255, 255, 255, 160)
			#line_2d.width = 3
			pass
			#add_child(line_2d)
		
@export var gravity: float = 800.0 # Match your game's gravity

var direction: float = -1.0 # 1.0 for right, -1.0 for left
var initial_x: float = 0.0
var is_dead: bool = false # State variable for death

# 2. CACHE NODES
@onready var sprite = $AnimatedSprite2D
@onready var damage_area = $HitBox
@onready var hurtbox = $EnemyHurtbox

var in_editor:bool = false

var line_2d:Line2D = null

signal died(enemy)

func _ready():
	if in_editor:
		line_2d = Line2D.new()
		line_2d.add_point(Vector2(-patrol_distance, 0))
		line_2d.add_point(Vector2(+patrol_distance, 0))
		line_2d.default_color = Color.from_rgba8(255, 255, 255, 200)
		line_2d.width = 3
		add_child(line_2d)
		return
	
	initial_x = global_position.x # Record the starting X position
	# The enemy starts walking
	sprite.play("run")

func _physics_process(delta):
	if in_editor:
		return
	
	if is_dead:
		# Stop movement and exit the physics loop if dead
		velocity = Vector2.ZERO
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Walk back and forth logic
	velocity.x = speed * direction
	

	# Check if the enemy reached a turning point
	var current_dist = global_position.x - initial_x

	if direction == 1.0 and current_dist >= patrol_distance:
		direction = -1.0
		sprite.flip_h = true # Adjust sprite facing direction
	elif direction == -1.0 and current_dist <= -patrol_distance:
		direction = 1.0
		sprite.flip_h = false # Adjust sprite facing direction
		
	# Move the enemy
	move_and_slide()


func _on_enemy_hurtbox_area_entered(area: Area2D) -> void:
	print("ENEMY HIT! Colliding Area: ", area.name, " Group: ", area.is_in_group("DashHitbox"))
	if area.name == "DashHitbox": # Checks for the specific Area2D name
		if not is_dead:
			die()
			emit_signal("died", self)

func die():
	is_dead = true
	
	# IMMEDIATE DEACTIVATION: This is the critical change.
	# We must instantly stop the enemy from being a threat.
	damage_area.monitoring = false 
	damage_area.monitorable = false
	
	# Also disable the body collision immediately so the player can pass through
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	damage_area.set_collision_layer_value(2, false)
	damage_area.set_collision_mask_value(2, false)
	hurtbox.set_collision_layer_value(4, false)
	
	# Stop movement
	velocity = Vector2.ZERO
	
	# Disable the hit detection area as well
	hurtbox.monitoring = false
	hurtbox.monitorable = false
	
	# Play death animation
	sprite.play("death")
	
	# Wait for the animation to finish and then remove the enemy
	await sprite.animation_finished
	queue_free() # Remove the enemy from the scene after the death animation
