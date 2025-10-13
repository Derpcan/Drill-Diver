extends CharacterBody2D

# 1. MOVEMENT PROPERTIES
@export var speed: float
@export var patrol_distance: float # How far the enemy walks from its start point
@export var gravity: float = 800.0 # Match your game's gravity

var direction: float = -1.0 # 1.0 for right, -1.0 for left
var initial_x: float = 0.0
var is_dead: bool = false # State variable for death

# 2. CACHE NODES
@onready var sprite = $AnimatedSprite2D
@onready var damage_area = $HitBox
@onready var hurtbox = $EnemyHurtbox

func _ready():
	initial_x = global_position.x # Record the starting X position
	# The enemy starts walking
	sprite.play("run")

func _physics_process(delta):
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
