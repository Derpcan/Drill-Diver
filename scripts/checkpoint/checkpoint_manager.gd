extends Node
class_name CheckpointManager


@export_category("Player")
## Keep track of the player in the level.
## If not assigned, will try to be found in _ready()
@export var player:Player


@export_category("Start Position")
## Keep track of the last position of the checkpoint, to start should make it the spawnpoint for the level.
@export var last_checkpoint_position:Vector2


@export_category("Checkpoints")
## An array of the checkpoints in the level. Can change type to be Checkpoints once they are made.
@export var checkpoints:Array[Vector2]



func _ready() -> void:
	# If the player is not set before startup
	if not player:
		# Attempt to find player in the current scene
		player = get_tree().current_scene.find_child("Player")
		
		if player: # If the player is successfully found
			print("Found: ", player)
		else:
			# Throw an error about not finding the Player
			printerr("No Player was found in scene tree.")
			assert(player != null, "ERROR: No Player was found.")
	
	
	connect_player_signals()


# Will connect the player's necessary signals to this manager
func connect_player_signals() -> void:
	player.health_component.died.connect(_player_died)
	

func _player_died() -> void:
	print("Player died")
	
