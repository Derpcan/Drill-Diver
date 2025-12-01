extends CharacterBody2D
class_name RangedDrone

@export var start_state : Node
@export var drone_hurtbox : Area2D

@export var idle_to_patrol_delay : float = 1
@export var patrol_to_idle_delay : float = 3
@export var engage_to_action_delay : float = 1.5
@export var detection_range : float = 200
@export var fire_range : float = 80
@export var approach_speed : float = 40
@export var patrol_dist : float = 10
@export var patrol_speed : float = 30
@export var reposition_speed : float = 50
@export var reposition_angle : float = 65
@export var return_speed : float = 30
@export var acceleration : float = 20
@export var fire_probability : float = 0.6
@export var entity_health : int = 1
@export var projectile_offset : float = 10

@onready var sprites : AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine : Node = $States
@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var projectile_path : String = "res://scenes/enemy/projectile.tscn"

const EPSILON := 1.5 # Margin of error for comparisons

var start_position : Vector2 = Vector2(-1.0, -1.0)
var to_player : Vector2 = Vector2(-1.0, -1.0) # The distance vector between this entity and the player
var can_be_hurt : bool = true
var collided_last_frame : bool = false

var in_editor:bool = false

func _ready() -> void:
	if in_editor:
		return
	
	start_position = self.global_position
	
	# Wire up each state
	for state in state_machine.get_children():
		state.entity = self
	
	# Start the state machine at the designated state
	state_machine.change_state(start_state)

func _physics_process(delta: float) -> void:
	if in_editor or player == null:
		return
	
	if player.global_position.x < global_position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	_calc_vec_to_player()
	state_machine._process(delta)
	collided_last_frame = move_and_slide()
	
	# Manually poll for hurtbox collisions
	for area in drone_hurtbox.get_overlapping_areas():
		if area.name == "DashHitbox" and can_be_hurt:
			can_be_hurt = false # (The way hit lockout works right now is broken, drones can only properly have 1 HP)
			state_machine.change_state(state_machine.hurt_state)

func _calc_vec_to_player() -> void:
	if player == null:
		return
	var player_glb = player.global_position
	var enemy_glb = self.global_position
	to_player = player_glb - enemy_glb
