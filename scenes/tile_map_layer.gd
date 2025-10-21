extends TileMapLayer
## If not assigned, will try to be found in _ready()
@export var player:Player

func _ready() -> void:
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
	
	player.super_drill_tile.connect(_delete_tile)


func _delete_tile(coords:Vector2):
	#print("DELETE")
	var tile_data = get_cell_tile_data(coords)
	#print("coords:", coords)
	#print("tile data:", tile_data)
	if tile_data and tile_data.has_custom_data("hardness") and tile_data.get_custom_data("hardness") == 1 :
			# Erase the tile by setting the cell to -1 (empty)
			var particle: GPUParticles2D = preload("res://scenes/particles/super_drill_break_particle.tscn").instantiate()
			particle.global_position =map_to_local(coords)
			add_child(particle)
			particle.finished.connect(particle.queue_free)
			particle.emitting = true
			erase_cell(coords)
