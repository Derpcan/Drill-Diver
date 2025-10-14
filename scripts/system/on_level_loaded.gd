extends Node

func _ready():
	connect("tree_exited", _handle_tree_exited)

# If this node detects an input, we start the timer because the level is now loaded and the player
#	has started moving. Additionally lock out the timer so it doesn't reenable before respawn if
#	stopped.
func _input(event) -> void:
	if event.is_pressed() and GameManager.timer_can_start():
		GameManager.start_timer.emit()
		GameManager.set_timer_can_start(false)

# If the level scene is forcibly removed from the scene tree (using the pause menu, on level end) we
#	need to reset everything within the GameManager.
func _handle_tree_exited():
	GameManager.stop_timer.emit()
	GameManager.set_timer_to(0)
	GameManager.save_time_at_checkpoint()
	GameManager.set_timer_can_start(true)
