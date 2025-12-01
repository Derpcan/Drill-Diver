extends Node

@onready var idle_state = $Idle
@onready var following_state = $Following
@onready var evaded_state = $Evaded
@onready var detonate_state = $Detonate

var current_state : Node

func change_state(state: Node) -> void:
	current_state = state
	current_state.enter()

func _process(delta: float) -> void:
	current_state.update(delta)
