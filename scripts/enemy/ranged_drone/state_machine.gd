extends Node

@onready var idle_state = $Idle
@onready var patrol_state = $Patrol
@onready var approach_state = $Approach
@onready var return_state = $Return
@onready var engage_state = $Engage
@onready var reposition_state = $Reposition
@onready var fire_state = $Fire
@onready var hurt_state = $Hurt

var current_state : Node

func change_state(state: Node) -> void:
	#print("----------------")
	#print("Entered: ", state)
	#print("----------------")
	current_state = state
	current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
