extends Button

func _ready():
	self.pressed.connect(_handle_on_press)

func _handle_on_press():
	get_tree().quit()
