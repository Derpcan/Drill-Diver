extends Area2D

signal checkpoint_activated(new_respawn_position: Vector2)

# Reference to the visual component
@onready var sprite = $Sprite2D 

# Flag to prevent re-activating the same checkpoint multiple times.
var is_active: bool = false

# Color constants
const dColor: Color = Color("303030") # Dark gray when deactivated
const aColor: Color = Color.WHITE # White reverts to full brightness

# Animation constants
const riseOffset: float = -5.0 # Initial rise
const riseDur: float = 1.0 # Rise duration
const bobDist: float = 1.5 # Bobbing distance
const bobDur: float = 2.0 # Bob loop duration
# -------------------------------------------------


func _ready() -> void:
	if sprite:
		# Set initial color to deactivated state
		sprite.modulate = dColor
		# Reset local position in case it was moved in the editor
		sprite.position = Vector2.ZERO 
		
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_active:
		activate_checkpoint()


func activate_checkpoint() -> void:
	is_active = true
	
	# Emit the signal to CheckpointManager to update respawn point
	checkpoint_activated.emit(global_position)
	
	if sprite:
		# Initialize tween
		var activation_tween = create_tween()
		
		# Activates color
		activation_tween.tween_property(sprite, "modulate", aColor, 0.2) 
		
		# Initial rise
		activation_tween.tween_property(
			sprite, 
			"position:y", 
			riseOffset, # Rise distance
			riseDur # Rise quickness
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT) 
		
		# Starts bob loop after rise
		await activation_tween.finished
		_start_bobbing()
		
	print_rich("[color=#00FFB3]Checkpoint Activated at: ", global_position, "[/color]")


# Runs bobbing loop
func _start_bobbing() -> void:
	# Initialize tween
	var bob_tween = create_tween()
	
	# Loop forever
	bob_tween.set_loops() 
	# Use since curve for bobbing
	bob_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Bob downward
	bob_tween.tween_property(
		sprite, 
		"position:y", 
		riseOffset + bobDist, 
		bobDur / 2.0 # Half the cycle duration
	)

	# Bob upward
	bob_tween.tween_property(
		sprite, 
		"position:y", 
		riseOffset, 
		bobDur / 2.0 # Half the cycle duration
	)
