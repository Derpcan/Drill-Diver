extends Node

const DEFAULT_SCENE = "res://scenes/main_menu.tscn"

var scene_stack: Array = []

func _ready():
	print("Scene Manager running...")
	
	# Set the main menu as the starting scene
	change_scene(DEFAULT_SCENE)

# Immediately switches to the given scene, overriding the scene stack
func change_scene(scene: String) -> bool:
	_clear_stack()
	return _load_scene(scene)

# Pushes the given scene onto the scene stack, rendering all scenes
func push_scene(scene: String) -> bool:
	if scene_stack.size() > 0:
		# If we are rendering multiple scenes, disable the previous scene
		var previous_scene = scene_stack[-1] # the most recently-added scene
		previous_scene.process_mode = Node.PROCESS_MODE_DISABLED
		#previous_scene.paused = true
		previous_scene.visible = false
		
	return _load_scene(scene)

# Pops the last scene off of the stack, unrendering it
func pop_scene() -> void:
	if scene_stack.is_empty():
		return
	
	var current_scene = scene_stack.pop_back()
	current_scene.queue_free()
	
	if scene_stack.size() > 0:
		# If we just disabled a scene, we need to reenable it when we pop the blocking scene
		var previous_scene = scene_stack[-1]
		previous_scene.process_mode = Node.PROCESS_MODE_INHERIT
		#previous_scene.paused = false
		previous_scene.visible = true

# Free and clear the scene stack if it needs to be overridden
func _clear_stack() -> void:
	for scene in scene_stack:
		print("Previous Scene Stack:------------")
		print(scene)
		print("---------------------------------")
		scene.queue_free()
	scene_stack.clear()

# Load and instantiate a specific scene
func _load_scene(scene: String) -> bool:
	var new_scene = load(scene)
	if not new_scene:
		# Something went wrong, give error message and return
		print("ERROR: SCENE MANAGER: failed to load scene " + scene)
		return false
	
	var scene_instance = new_scene.instantiate()
	get_tree().root.add_child.call_deferred(scene_instance)
	scene_stack.push_back(scene_instance)
	
	return true
