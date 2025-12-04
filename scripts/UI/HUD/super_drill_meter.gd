extends TextureProgressBar

func _ready():
	# Set an arbitrary initial value (will be handled dynamically later)
	self.value = GameManager.get_current_charge()
	GameManager.update_meter.connect(_handle_update_meter)
	
func _handle_update_meter(amount: int) -> void:
	self.value = amount
