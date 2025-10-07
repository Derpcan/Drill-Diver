extends Area2D

@export var fill_amount: int = 10  # same value used by button (10%)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		# Emit the same signal the button uses
		GameManager.fill_meter.emit(fill_amount)
		
		# Optionally print for debugging
		print("Item collected: emitting fill_meter(", fill_amount, ")")
		
		# Remove item after pickup
		queue_free()
