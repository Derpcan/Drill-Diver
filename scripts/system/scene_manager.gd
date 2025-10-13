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

## Pushes the given scene onto the scene stack, rendering all scenes
func push_scene(scene: String) -> void:
	if scene_stack.size() > 0:
		# If we are rendering multiple scenes, disable all previous scenes
		get_tree().paused = true
		#for s in scene_stack:
			#if is_instance_valid(s):
				#_pause_scene(s)
		
	# Load the scene and attach it to the stack root
	var overlay_scene = load(scene).instantiate()
	overlay_scene.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	scene_stack.push_back(overlay_scene)
	get_tree().root.add_child(overlay_scene)

## Pops the last scene off of the stack, unrendering it
func pop_scene() -> void:
	if scene_stack.is_empty():
		return
	
	# remove and free sceen from root
	#_remove_scene(scene_stack.pop_back())
	
	if scene_stack.size() > 0:
		# If we just disabled a scene, we need to reenable it when we pop the blocking scene
		_unpause_scene(scene_stack.back())

## Pauses a given scene (disabling input and process steps)
func _pause_scene(scene: Node) -> void:
	scene.process_mode = Node.PROCESS_MODE_DISABLED

## Unpauses a given scene (reenabling input and processing)
func _unpause_scene(scene: Node) -> void:
	scene.process_mode = Node.PROCESS_MODE_INHERIT
