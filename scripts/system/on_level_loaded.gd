extends Node

# If this node detects an input, we start the timer because the level is now loaded and the player
#	has started moving. Additionally lock out the timer so it doesn't reenable before respawn if
#	stopped.
func _input(event) -> void:
	if event.is_pressed() and GameManager.timer_can_start():
		GameManager.start_timer.emit()
		GameManager.set_timer_can_start(false)
