extends Node

var entity : RangedDrone = null
@onready var state_machine = get_parent()

var damage_handled := false

func enter() -> void:
	entity.sprites.play("hurt")
	entity.entity_health -= 1

	if entity.entity_health <= 0:
		entity.sprites.play("death")
		await entity.sprites.animation_finished
		entity.queue_free()
		return

	await entity.sprites.animation_finished
	damage_handled = true
	entity.can_be_hurt = true

func update(_delta: float) -> void:
	if damage_handled:
		# I'm making the assumption that if the drone was able to be hit by the player, then it is within detection & fire range
		# 	--> so transition back to the engage state
		state_machine.change_state(state_machine.engage_state)
