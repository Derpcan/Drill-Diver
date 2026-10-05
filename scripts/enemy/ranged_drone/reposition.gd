extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

var reposition_done : bool = false

func enter() -> void:
	entity.sprites.play("move")
	
	reposition_done = false

func update(delta: float) -> void:
	var dist = entity.to_player.length()
	if !reposition_done:
		# Reposition
		# Move towards player_pos + fire_range/1.5 radius at all times
		var start_angle = deg_to_rad(180 + entity.reposition_angle)
		var end_angle = deg_to_rad(360 - entity.reposition_angle)
		var theta = randf() * (end_angle - start_angle) + start_angle
		var target_point = entity.player.global_position + Vector2(cos(theta), sin(theta)) * (entity.fire_range / 1.5)

		var direction = (target_point - entity.global_position).normalized()
		entity.velocity = entity.velocity.move_toward(direction * entity.reposition_speed, entity.acceleration * delta)
		
		var to_target = abs((entity.global_position - target_point).length())
		if (to_target <= entity.EPSILON) || entity.collided_last_frame:
			reposition_done = true
	else:
		# Reposition done, transition to engage
		state_machine.change_state(state_machine.engage_state)
		return
