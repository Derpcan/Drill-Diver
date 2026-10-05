extends CharacterBody2D

@export var projectile_speed : float
@export var lifetime : float
@export var hit_linger : float

@onready var sprites : AnimatedSprite2D = $AnimatedSprite2D
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var projectile_hitbox : Area2D = $HitBoxProjectile
@onready var explosion_hitbox : Area2D = $HitBoxExplosion

var direction : Vector2 = Vector2.ZERO
#var velocity : Vector2 = Vector2.ZERO
var can_explode : bool = true
var timer : Timer = null

func _ready() -> void:	
	# If the projectile direct hits a player, it explodes
	projectile_hitbox.connect("area_entered", _explode_handler)
	
	# If long enough passes, the projectile explodes
	var timer = get_tree().create_timer(lifetime)
	timer.connect("timeout", _explode)
	
	# Disable the explosion hitbox until exploded
	explosion_hitbox.monitoring = false
	
	# Play the idle sprite
	sprites.play("bullet_idle")
	
	# Set the initial velocity of the projectile
	velocity = direction * projectile_speed

func _physics_process(delta: float) -> void:
	# Keep moving the projectile in a straight line towards its target
	# If the projectile base collides with something, it automatically explodes
	if move_and_slide():
		_explode()

func _explode_handler(_area: Area2D) -> void:
	_explode()

func _explode() -> void:
	if !can_explode:
		return
	
	can_explode = false
	
	# The projectile explodes, so we switch animations
	sprites.play("bullet_explode")
	
	velocity = Vector2.ZERO
	
	# Enable the explosion hitbox
	explosion_hitbox.monitoring = true
	
	await get_tree().create_timer(hit_linger).timeout
	
	# Disable the hitbox once again
	explosion_hitbox.monitoring = false
	
	queue_free()
	
