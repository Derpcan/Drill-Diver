extends Node
class_name CheckpointManager


signal player_death_animation_ended(previous_checkpoint_pos:Vector2)


@export_category("Player")
## Keep track of the player in the level.
## If not assigned, will try to be found in _ready()
@export var player:Player

## Keep track of the ghost in the level.
## If not assigned, will try to be found in _ready()
@export var ghost:Ghost


@export_category("Start Position")
## Keep track of the last position of the checkpoint, to start should make it the spawnpoint for the level.
@export var last_checkpoint_position:Vector2


@export_category("Camera")
## Keep track of the game camera to have control over moving it back to respawn
@export var game_camera:GameCamera


func _ready() -> void:
	# If the ghost is not set before startup
	if not ghost:
		# Attempt to find ghost in the current scene
		ghost = get_tree().current_scene.find_child("Ghost")
		
		if ghost: # If the ghost is successfully found
			print_rich("[color=#DDFF00]Found: ", ghost, "[/color]")
		else:
			# Throw an error about not finding the Ghost
			printerr("No Ghost was found in scene tree.")
			
	
	# If the player is not set before startup
	if not player:
		# Attempt to find player in the current scene
		player = get_tree().current_scene.find_child("Player")
		
		if player: # If the player is successfully found
			print_rich("[color=#DDFF00]Found: ", player, "[/color]")
		else:
			# Throw an error about not finding the Player
			printerr("No Player was found in scene tree.")
			#assert(player != null, "ERROR: No Player was found.")
	
	# If the camera is not set before startup
	if not game_camera:
		# Attempt to find camera in the current scene
		game_camera = get_tree().current_scene.find_child("GameCamera")
		
		if game_camera: # If the camera is successfully found
			print_rich("[color=#00FFB3]Found: ", game_camera, "[/color]")
		else:
			# Throw an error about not finding the Camera
			printerr("No Camera was found in scene tree.")
			#assert(game_camera != null, "ERROR: No Camera was found.")
			
	if player:
		connect_player_signals()
		connect_camera_to_player()
		connect_camera_signals()
	if ghost:
		connect_ghost_signals()
		
	
	# Find all nodes belonging to the 'checkpoint' group
	var checkpoint_nodes = get_tree().get_nodes_in_group("checkpoint")
	for checkpoint in checkpoint_nodes:
		# Check if the node has the expected signal before trying to connect
		if checkpoint.has_signal("checkpoint_activated"):
			# Connect the checkpoint's activation signal to our update function
			checkpoint.checkpoint_activated.connect(_update_checkpoint_position)
			print_rich("[color=#66CCFF]Manager Connected to Checkpoint at: ", checkpoint.global_position, "[/color]")

# Receives the new position from an activated checkpoint and updates the respawn position.
func _update_checkpoint_position(new_position: Vector2) -> void:
	last_checkpoint_position = new_position
	print_rich("[color=#66FF66]RESPAWN POSITION UPDATED to: ", last_checkpoint_position, "[/color]")
	
	# Charlie: Save the current timer value when we reach a new checkpoint
	GameManager.save_time_at_checkpoint()


# Connects the camera to the player
func connect_camera_to_player() -> void:
	game_camera.call_deferred("reparent", player)
	game_camera.position = player.position
	

# Connects the camera's necessary signals to this manager
func connect_camera_signals() -> void:
	player_death_animation_ended.connect(game_camera._move_back_to_checkpoint)
	game_camera.back_at_checkpoint.connect(_camera_returned_restart)
	

# When the camera returns to the checkpoint
func _camera_returned_restart() -> void:
	player.state_machine._enter_state("idle")
	# Use the dynamically updated last_checkpoint_position for respawn
	player.global_position = last_checkpoint_position
	
	
	# Tween the modulation for the player to show up overtime
	var tween:Tween = create_tween()
	player.modulate.a = 0
	tween.tween_property(player, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	await tween.finished
	
	
	
	# Heal the player and re-enable input
	player.health_component._heal_fully()
	player.velocity = Vector2.ZERO
	player.movement_component.velocity = Vector2.ZERO
	
	# Attach the camera back to the player
	game_camera.reparent(player)
	


# Will connect the player's necessary signals to this manager
func connect_player_signals() -> void:
	
	player.health_component.died.connect(_player_died)
	player.animation_play.animation_finished.connect(_player_animation_finished)


# When the player's aniamtion finished, check specifically death animation being finished
func _player_animation_finished(animation_name:String) -> void:
	if animation_name == "default/death":
		game_camera.reparent(get_tree().current_scene)
		print_rich("[color=#ED6868]Death Caught", "[/color]")
		emit_signal("player_death_animation_ended", last_checkpoint_position)
		
		# Charlie: When the death animation is finished, stop the timer and reenable it to start again
		GameManager.set_timer_to(GameManager.get_time_at_checkpoint())
		GameManager.set_timer_can_start(true)


func _player_died() -> void:
	print("Player died")
	
	# Charlie: When the player dies, we want to stop the timer
	GameManager.stop_timer.emit()



# Will connect the ghost's necessary signals to this manager
func connect_ghost_signals() -> void:
	ghost.health_component.died.connect(_ghost_died)
	ghost.animation_play.animation_finished.connect(_ghost_animation_finished)


# When the ghost's aniamtion finished, check specifically death animation being finished
func _ghost_animation_finished(animation_name:String) -> void:
	if animation_name == "default/death":
		print_rich("[color=#ED6868]Death Caught", "[/color]")
		_respawn_ghost()

func _ghost_died() -> void:
	print("Ghost died")
	
	# Make the ghost fade out, temporary to look a bit nicer
	var tween:Tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.play()

func _respawn_ghost() -> void:
	ghost.state_machine._enter_state("idle")
	# Use the dynamically updated last_checkpoint_position for respawn
	ghost.global_position = last_checkpoint_position
	
	
	# Tween the modulation for the player to show up overtime
	var tween:Tween = create_tween()
	ghost.modulate.a = 0
	tween.tween_property(ghost, "modulate:a", 0.5, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	
	await tween.finished

	# Heal the ghost and re-enable input
	ghost.health_component._heal_fully()
	ghost.velocity = Vector2.ZERO
	ghost.movement_component.velocity = Vector2.ZERO
