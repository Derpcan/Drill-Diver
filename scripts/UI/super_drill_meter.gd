extends ProgressBar

func _ready():
	# Set an arbitrary initial value (will be handled dynamically later)
	self.value = 10
	
	GameManager.fill_meter.connect(_handle_fill_meter)
	GameManager.deplete_meter.connect(_handle_deplete_meter)
	GameManager.set_meter.connect(_handle_set_meter)
	
func _handle_fill_meter(amount: int) -> void:
	self.value = clamp(self.value + amount, self.min_value, self.max_value)
	
func _handle_deplete_meter(amount: int) -> void:
	self.value = clamp(self.value - amount, self.min_value, self.max_value)
	
func _handle_set_meter(amount: int) -> void:
	self.value = clamp(amount, self.min_value, self.max_value)
