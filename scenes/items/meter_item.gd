extends Area2D

@export var fill_amount: int = 10  # same value used by button (10%)
@onready var player : Player = get_tree().get_first_node_in_group("player")
var can_be_picked_up = true
var in_editor = false
func _ready():
	if in_editor:
		return
	body_entered.connect(_on_body_entered)
	player.died.connect(_respawn)
func _on_body_entered(body):
	if body.name == "Player" and can_be_picked_up:
		# Emit the same signal the button uses
		body._play_item_collect()
		GameManager.fill_meter.emit(fill_amount)
		# Optionally print for debugging
		print("Item collected: emitting fill_meter(", fill_amount, ")")
		
		# Remove item after pickup
		visible = false
		can_be_picked_up = false
		
func _respawn():
	visible = true
	can_be_picked_up = true
	
