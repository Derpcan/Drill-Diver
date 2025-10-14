extends Label

func _ready():
	GameManager.update_record.connect(_handle_update_record)
	
func _handle_update_record(seconds: float):
	self.text = GameManager.convert_to_readable_time(seconds)
