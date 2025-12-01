extends CharacterBody2D
class_name HomingMine

@export var start_state : Node

@export var hit_delay : float		# The amount of time in seconds between the detection range proc and hitbox activation
@export var hit_linger : float		# The amount of time in seconds between the hitbox activating and deactivating
@export var detection_range : float	# Range in meters for the mine to begin following
@export var follow_range : float	# Range in meters for the mine to continue following
@export var detonate_range : float	# Range in meters for the mine to detonate manually
@export var evaded_lifetime : float	# The lifetime of the mine after being evaded
@export var initial_speed : float	# The speed at which the mine starts to move
@export var max_speed : float		# The top speed that the mine may move
@export var acceleration : float	# The acceleration of the mine
@export var turn_speed : float		# The speed at which the mine can turn (higher = faster)
@export var idle_drift : float		# The random bob distance of the mine in idle

@onready var detonation_hitbox : Area2D = $HitBox
@onready var sprites : AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine : Node = $States
@onready var player : Player = get_tree().get_first_node_in_group("player")

const EPSILON := 1.0 # Margin of error for comparisons

var to_player : Vector2 = Vector2(-1.0, -1.0) # The distance vector between this entity and the player

func _ready() -> void:
	# Disable the explosion hitbox
	detonation_hitbox.monitoring = false
	
	# Wire up each state
	for state in state_machine.get_children():
		state.entity = self
	
	# Start the state machine at the designated state
	state_machine.change_state(start_state)

func _physics_process(delta: float) -> void:
	_calc_vec_to_player()
	state_machine._process(delta)
	move_and_slide()

func _calc_vec_to_player() -> void:
	var player_glb = player.global_position
	var enemy_glb = self.global_position
	to_player = player_glb - enemy_glb
	#print("----------------------------")
	#print(to_player.length())
	#print("----------------------------")
