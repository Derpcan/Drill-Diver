extends AnimatedSprite2D
class_name AnimationSprite


@export var json_loaded:JSONLoader
@export var creature_name:String

func _ready() -> void:
	# Create variables to store path of folders and the saved animation file
	var folder_path:String = "res://animations/" + creature_name
	#var folder_path:String = "user://animations/" + creature_name
	var save_path:String = folder_path + "/" + creature_name + "_sprite_frames.tres"
	
	# Check if the saved sprite frames exists already, if not make the sprite frames file from JSON
	if FileAccess.file_exists(save_path):
		# The sprite frames file exists and can return early
		var sprites:SpriteFrames = load(save_path)
		sprite_frames = sprites
		print("Sprite Frames successfully loaded.")
		return
	
	
	# Check if the JSON file exists
	if not json_loaded.json_file:
		return # Return early if the file doesn't exist
	
	
	# Create the animations from the data from the JSON file
	create_animations()
	
	save_sprite_frames(save_path, folder_path)
	

# Save the sprite frames to file system to avoid needing to parse JSON everytime
func save_sprite_frames(save_path:String, folder_path:String) -> void:
	# Create folders needed for storing the animations if they don't exist
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	# Save the library to the save path
	var err:Error = ResourceSaver.save(sprite_frames, save_path)
	
	# Check if it was saved properly or not
	if err == OK:
		print("Sprite Frames saved to ", save_path)
	else:
		push_error("Failed to save Sprite Frames, error code: %s", % err)


# Creates animations from the data from the JSON file. It provides the path, and number of sprites
func create_animations() -> void:
	# Create a SpriteFrames Object to store the parsed Animation from the JSON
	var new_sprite_frames:SpriteFrames = SpriteFrames.new()
	
	# Store the JSON file as a local variable
	var json_file:JSON = json_loaded.json_file
	
	# Go through all the animations in the JSON file for the player
	for key in json_loaded.json_file.data[creature_name]["sprites"].keys():
		create_individual_animation(json_file, key, new_sprite_frames)
	
	# Set the current spriteframes to the new sprite frames
	sprite_frames = new_sprite_frames
	
	

# Creates the individual animations.
func create_individual_animation(json_file:JSON, animation_key:String, new_sprite_frames:SpriteFrames) -> void:
	
	# Get the number of frames so the sprites can be parsed from the spritesheet properly
	var num_sprites_x:int = json_loaded.json_file.data[creature_name]["sprites"][animation_key]["frames_x"]
	var num_sprites_y:int = json_loaded.json_file.data[creature_name]["sprites"][animation_key]["frames_y"]
	
	# Get the sprite sheet texture from the path in the JSON file
	var sprite_sheet_texture:Texture2D = load(json_loaded.json_file.data[creature_name]["sprites"][animation_key]["path"])
	
	# Make a new animation in the sprite frames with the animation key value as the name
	new_sprite_frames.add_animation(animation_key)
	
	# Get the width and height of the sprite_sheet
	var frame_width = sprite_sheet_texture.get_width() / float(num_sprites_x)
	var frame_height = sprite_sheet_texture.get_height() / float(num_sprites_y)
	
	# Loop through the number of sprites
	for y in range(num_sprites_y):
		for x in range(num_sprites_x):
			# Get the region of each sprite
			var frame_region:Rect2 = Rect2(x*frame_width, y*frame_height, frame_width, frame_height)
			var atlas_texture:AtlasTexture = AtlasTexture.new()
			atlas_texture.atlas = sprite_sheet_texture
			atlas_texture.region = frame_region
		
			# Add the frame to the animation
			new_sprite_frames.add_frame(animation_key, atlas_texture)
	
	#print("Added animation to AnimationSprite " + str(animation_key))
	print_rich("[color=#8CFF90]Added animation to AnimationSprite: ", str(animation_key), "[/color]")
