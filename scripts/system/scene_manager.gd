extends Node

const DEFAULT_SCENE = "res://scenes/main_menu.tscn"

var scene_stack: Array[Node] = []

func _ready():
	print("Scene Manager running...")
	
	# Set the main menu as the starting scene
	change_scene(DEFAULT_SCENE)

## Immediately switches to the given scene, overriding the scene stack
func change_scene(scene: String) -> void:
	# We no longer need to track the layering of scenes (they'll be freed by change_scene_to_packed())
	scene_stack.clear()
	
	# Load the new scene, track it, and switch to it
	get_tree().change_scene_to_file.call_deferred(scene)
	await get_tree().node_added
	scene_stack.push_back(get_tree().current_scene)


func change_scene_extra_args(scene:String, args:Array) -> void:
	# We no longer need to track the layering of scenes (they'll be freed by change_scene_to_packed())
	scene_stack.clear()
	
	get_tree().change_scene_to_file.call_deferred(scene)
	
	await get_tree().node_added
	
	scene_stack.push_back(get_tree().current_scene)
	get_tree().current_scene.level_file_path = args[0]
	


## Pushes the given scene onto the scene stack, rendering all scenes
func push_scene(scene: String) -> void:
	if scene_stack.size() > 0:
		# If we are rendering multiple scenes, disable all previous scenes
		_pause_scene()
		scene_stack.back().process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Load the scene and attach it to the stack root
	var overlay_scene = load(scene).instantiate()
	overlay_scene.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	scene_stack.push_back(overlay_scene)
	get_tree().root.add_child(overlay_scene)

## Pops the last scene off of the stack, unrendering it
func pop_scene() -> void:
	if scene_stack.is_empty():
		return
	
	# Remove and free the last scene from the root
	var previous_scene = scene_stack.pop_back()
	get_tree().root.remove_child(previous_scene)
	previous_scene.queue_free()
	
	if scene_stack.size() > 0:
		# If we just disabled a scene, we need to reenable it when we pop the blocking scene
		_unpause_scene()

## Pauses a given scene (disabling input and process steps)
func _pause_scene() -> void:
	get_tree().paused = true

## Unpauses a given scene (reenabling input and processing)
func _unpause_scene() -> void:
	get_tree().paused = false
