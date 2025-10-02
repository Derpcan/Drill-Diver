extends Label

func _ready():
	GameManager.update_record.connect(_handle_update_record)
	
func _handle_update_record(seconds: float):
	var readable_time = GameManager.convert_to_readable_time(seconds)
	self.text = readable_time
