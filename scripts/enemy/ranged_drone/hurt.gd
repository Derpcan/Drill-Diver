extends Node

var entity : RangedDrone = null
@onready var state_machine = get_parent()

var damage_handled := false

func enter() -> void:
	entity.sprites.play("hurt")
	entity.entity_health -= 1

	if entity.entity_health <= 0:
		entity.sprites.play("death")
		get_parent().get_parent().player._on_dash_hitbox_hit_something()
		get_parent().get_parent().get_node("DieSound").play()
		
		await get_parent().get_parent().get_node("DieSound").finished
		if get_parent().get_parent().can_be_hurt == false:
			get_parent().get_parent().visible = false
	
		return

	await entity.sprites.animation_finished
	damage_handled = true
	entity.can_be_hurt = true

func update(_delta: float) -> void:
	if damage_handled:
		# I'm making the assumption that if the drone was able to be hit by the player, then it is within detection & fire range
		# 	--> so transition back to the engage state
		state_machine.change_state(state_machine.engage_state)
