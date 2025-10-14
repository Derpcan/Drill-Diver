extends Label

func _ready():
	GameManager.update_timer.connect(_handle_update_timer)
	
func _handle_update_timer(seconds: float):
	self.text = GameManager.convert_to_readable_time(seconds)
