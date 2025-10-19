extends AnimationPlayer
class_name AnimationPlay

# Contains inherent signals
# animation_changed(old_anim_name, new_anim_name). Emitted when the animation changes
# animation_finished(anim_name). Emitted when the animation ends

@export var json_loader:JSONLoader
@export var animation_sprite:AnimationSprite
@export var state_machine:StateMachine

func _ready() -> void:
	# Create library to add animations to
	var lib:AnimationLibrary = AnimationLibrary.new()
	
	# Check if the state machine exists
	if state_machine:
		# Connect the animation added connection to the _add_state
		lib.animation_added.connect(state_machine._add_state)
		
		state_machine.enter_state.connect(_start_state_animation)
	
	
	var creature_name:String = animation_sprite.creature_name
	
	# Create variables to store path of folders and the saved animation file
	var folder_path:String = "res://animations/" + creature_name
	var save_path:String =  folder_path + "/" + creature_name +"_animation_library.tres"
	
	# Check if the saved animation exists already, if not make the animation file from JSON
	if FileAccess.file_exists(save_path):
		# The animation file exists and can return early
		lib = load(save_path)
		#print(lib.get_animation_list())
		add_animation_library("default", lib)
		print("Animation Library successfully loaded.")
		
		for anim in lib.get_animation_list():
			state_machine._add_state(anim)
		
		return
	
	
	
	# Create animations parsed from the JSON file
	create_animations(lib, creature_name)
	
	# Add the library to the animation player so they can be called
	add_animation_library("default", lib)
	
	# Save the animation library to allow skipping having to load from JSON
	save_animation_library(lib, save_path, folder_path)


# Is connected to the state machines enter_state so it will start the animation for the state
func _start_state_animation(state_name:String, state_index:int) -> void:
	print_rich("[color=#E4ED98]Started the State ", state_name, "[/color]")
	#print("Started the State " + state_name)
	play("default/"+state_name)


# Save the animation library to file system to load faster than parsing JSON
func save_animation_library(lib:AnimationLibrary, save_path:String, folder_path:String) -> void:
	# Create folders needed for storing the animations if they don't exist
	DirAccess.make_dir_recursive_absolute(folder_path)
	
	# Save the library to the save path
	var err:Error = ResourceSaver.save(lib, save_path)
	
	# Check if it was saved properly or not
	if err == OK:
		print("Animation Library saved to ", save_path)
	else:
		push_error("Failed to save Animation Library, error code: %s", % err)
	

# Creates all the animations for the AnimationLibrary
func create_animations(lib:AnimationLibrary, creature_name:String) -> void:
	
	# Go through the animations in the animation sprite, which were parsed from JSON earlier
	for anim_name in animation_sprite.sprite_frames.get_animation_names():
		
		# if there is an animation named default just skip
		if anim_name != "default":
			
			# Get the JSON animation dictionary
			var json_animation:Dictionary = json_loader.json_file.data[creature_name]["sprites"][anim_name]
			
			# Parse from the json how long the animation should take
			var time_length:float = json_animation["time_length"]
			
			# Parse from the json how long the animation should take
			var frame_count:float = json_animation["frames_x"] * json_animation["frames_y"]
			
			# Set the should_loop variable to loop if loop is true in JSON and loop_none if loop is false in JSON
			var should_loop: = Animation.LOOP_LINEAR if json_animation["loop"] else Animation.LOOP_NONE
			
			
			
			# Add each animation to the library
			add_animation_to_library(anim_name, lib, time_length, should_loop, frame_count)


# Make an animation and add it to the library
func add_animation_to_library(animation_name:String, lib:AnimationLibrary, time_length:float, should_loop, frame_count:float) -> void:
	# Create an animation to store new data
	var anim:Animation = Animation.new()
	
	# Set the length of the animation
	anim.length = time_length
	
	anim.loop_mode = should_loop
	
	# Make a new track for the animation to add steps to
	var track = anim.add_track(Animation.TYPE_VALUE)
	
	# Make the animation update discretely so there is not interpolation
	anim.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
	
	# Get the path by omitting the extra stuff in front of the Path
	var relative_path = get_path_to(animation_sprite).slice(1)
	
	# Set the path to the animation sprite's frame so it can step through the frames
	anim.track_set_path(track, str(relative_path)+":frame")
	
	# Calculate the time step between each frame
	var frame_time_step:float = anim.length / frame_count
	
	if animation_name != "dash":
		# Insert each frame into the animation at each time step
		for i in range(0,frame_count):
			anim.track_insert_key(track, (i)*frame_time_step, i)
	else:
		anim.track_insert_key(track, 0, 0)
		anim.track_insert_key(track, 0.05, 1)
		anim.track_insert_key(track, 0.1, 2)
	
	# Make a new track for the animation to set the animation for the AnimationSprite so it uses the proper sprites
	var track2 = anim.add_track(Animation.TYPE_VALUE)
	
	# Set the path to the animation sprite's animation so it can swap to the right sprites
	anim.track_set_path(track2, str(relative_path)+":animation")
	
	# Insert at the beginning the animation to use
	anim.track_insert_key(track2, 0, animation_name)
	
	
	# Add the animation to the library
	lib.add_animation(animation_name, anim)
	
	
	
	
	
	
	
