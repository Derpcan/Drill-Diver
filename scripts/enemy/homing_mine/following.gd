extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

var just_entered : bool = true

func enter() -> void:
	entity.sprites.play("open")
	entity.sprites.play("idle_open")

func update(delta: float) -> void:
	var dist = entity.to_player.length()
	# The player moved outside of the follow range, transition to evaded
	if dist > entity.follow_range:
		state_machine.change_state(state_machine.evaded_state)
		return
	
	# The player is within follow range but outside detonate range, continue following
	if (dist <= entity.follow_range) && (dist > entity.detonate_range):
		# If the player is very close to the mine, begin arming animation
		if dist <= (entity.detonate_range * 2):
			entity.sprites.play("armed_fast")
		else:
			entity.sprites.play("idle_open")
		
		# Continue moving towards the player
		var desired_dir = entity.to_player.normalized()
		
		# Smoothly turn
		var move_dir = entity.velocity.normalized()
		move_dir = move_dir.slerp(desired_dir, entity.turn_speed * delta).normalized()
		
		if just_entered:
			entity.velocity = move_dir * entity.initial_speed
			just_entered = false
		
		# Keep accelerating up to max speed
		entity.velocity = entity.velocity.move_toward(move_dir * entity.max_speed, entity.acceleration * delta)
		return
	
	# The player is within detonate range, transition to detonate
	if dist <= entity.detonate_range:
		state_machine.change_state(state_machine.detonate_state)
		return
