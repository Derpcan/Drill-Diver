extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

var start_position : Vector2 = Vector2.ZERO
var random_position : Vector2 = Vector2.ZERO

func enter() -> void:
	start_position = entity.position
	entity.sprites.play("idle_close")
	
	var theta = randf() * TAU
	random_position = start_position + Vector2(cos(theta), sin(theta)) * entity.idle_drift

func update(delta: float) -> void:
	var dist = entity.to_player.length()
	# The player moved within follow range, transition to following
	if dist <= entity.detection_range:
		state_machine.change_state(state_machine.following_state)
		return
	
	# The player isn't nearby, idly bob around
	var direction = Vector2.ZERO
	if entity.global_position.distance_to(random_position) <= entity.EPSILON:
		direction = (entity.global_position.direction_to(start_position)).normalized()
	else:
		direction = (entity.global_position.direction_to(random_position)).normalized()
	entity.velocity = entity.velocity.move_toward(direction * entity.initial_speed, delta)
