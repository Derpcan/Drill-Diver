extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

var fire_done : bool = false
var can_fire : bool = false

func enter() -> void:
	fire_done = false
	can_fire = false
	entity.sprites.play("attack")
	await entity.sprites.animation_finished
	can_fire = true

func update(delta: float) -> void:
	if !can_fire:
		return
	
	if !fire_done:
		# Fire
		# Spawn the projectile
		var projectile = load(entity.projectile_path).instantiate()
		var direction = entity.to_player.normalized()
		projectile.global_position = entity.global_position + direction * entity.projectile_offset
		projectile.direction = direction
		get_tree().current_scene.add_child(projectile)
		
		fire_done = true
	else:
		# Fire done, transition to engage
		state_machine.change_state(state_machine.engage_state)
		return
