extends Node

var entity : Node2D = null
@onready var state_machine = self.get_parent()

var detonate_timeout : float = 0.0
var evaded_dir : Vector2 = Vector2(0.0, 0.0)

func enter() -> void:
	entity.sprites.play("armed_slow")
	
	evaded_dir = entity.velocity.normalized()
	detonate_timeout = 0.0

func update(delta: float) -> void:
	detonate_timeout += delta
	
	# The detonate timer has run out, transition to detonate
	if detonate_timeout >= entity.evaded_lifetime and get_parent().get_node("Idle").can_detonate:
		state_machine.change_state(state_machine.detonate_state)
		return
	else:
		state_machine.change_state(state_machine.idle_state)
	
	# The detonate timer is still going, stay evaded
	# Continue moving in the direction we were going when evaded
	entity.velocity = entity.velocity.move_toward(evaded_dir * entity.max_speed, entity.acceleration * delta)
