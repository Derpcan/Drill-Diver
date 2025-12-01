extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

func enter() -> void:
	# Detonate
	entity.sprites.play("explosion")
	
	await get_tree().create_timer(entity.hit_delay).timeout
	
	entity.velocity = Vector2.ZERO
	
	# Re-enable the explosion hitbox
	entity.detonation_hitbox.monitoring = true
	
	await get_tree().create_timer(entity.hit_linger).timeout
	
	# Disable the hitbox once again
	entity.detonation_hitbox.monitoring = false
	
	entity.queue_free()


func update(_delta: float) -> void:
	pass
