extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()
signal can_respawn
func enter() -> void:
	# Detonate
	if get_parent().get_node("Idle").can_detonate == true:
		
		entity.sprites.play("explosion")
		get_parent().get_node("Idle").can_detonate = false
		await get_tree().create_timer(entity.hit_delay).timeout
		
		entity.velocity = Vector2.ZERO
		
		# Re-enable the explosion hitbox
		entity.detonation_hitbox.monitoring = true
		
		await get_tree().create_timer(entity.hit_linger).timeout
		
		# Disable the hitbox once again
		entity.detonation_hitbox.monitoring = false
		
		get_parent().get_parent().visible = false
		
		
		
	else:
		state_machine.change_state(state_machine.idle_state)


func update(_delta: float) -> void:
	pass
