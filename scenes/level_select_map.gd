extends Node2D

# ---- CONFIG ----
@export var move_speed := 400.0    # Speed of automatic movement

# ---- STATE ----
var stops := []                    # Stores all level stop data
var current_index := 1             # Index of the stop you are currently at
var is_moving := false             # True while walking between stops
var target_offset := 0.0           # Where we are walking to (PathFollow2D offset)

# ---- REFERENCES ----
@onready var path := $Path2D
@onready var path_follow := $Path2D/PathFollow2D
@onready var player := $AnimatedSprite2D
@onready var label := $NameLabel/Label
@onready var label_container := $NameLabel
@onready var stops_parent := $LevelStops

# ==========================================
#                INITIAL SETUP
# ==========================================
func _ready():
	build_stop_list()
	snap_to_stop(1)  # Start at first stop
	$FileDialog.file_selected.connect(file_selected)
	#label_container.visible = false

# Builds internal "stops" array with offset, name, and scene data.
func build_stop_list():
	for stop in stops_parent.get_children():
		var offset = path.curve.get_closest_offset(stop.global_position)
		stops.append({
			"node": stop,
			"offset": offset,
			"name": stop.get_meta("level_name"),
			"scene": stop.get_meta("file_path")
		})

	# Ensure stops are in left-to-right order
	stops.sort_custom(func(a, b): return a["offset"] < b["offset"])


# ==========================================
#                INPUT HANDLING
# ==========================================
#func _unhandled_input(event):
	#if is_moving:
		#return  # Ignore input while already walking
#
	#if event.is_action_pressed("ui_right"):
		#try_move_to(current_index + 1)
#
	#elif event.is_action_pressed("ui_left"):
		#try_move_to(current_index - 1)
#
	#elif event.is_action_pressed("ui_accept"):
		#enter_level()
		
func _unhandled_input(event):
	if is_moving:
		return

	# Move Right
	if Input.is_action_just_pressed("game_move_right"):
		try_move_to(current_index + 1)

	# Move Left
	elif Input.is_action_just_pressed("game_move_left"):
		try_move_to(current_index - 1)

	# Enter/Confirm (keep as before)
	elif Input.is_action_just_pressed("game_jump"):
		enter_level()
		
	elif Input.is_action_just_pressed("game_dash"):
		enter_level()
		
	elif Input.is_action_just_pressed("game_super_drill"):
		enter_level()
		
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.change_scene("res://scenes/main_menu.tscn")


# ==========================================
#             MOVEMENT LOGIC
# ==========================================
func try_move_to(index):
	if index < 0 or index >= stops.size():
		return  # No stop in that direction

	current_index = index
	var offset = stops[index]["offset"]
	
	var max_offset = path.curve.get_baked_length()
	target_offset = clamp(offset, 0, max_offset)
	
	is_moving = true
	
	label_container.visible = false

	# Animate running
	player.play("run")
	$MovementSound.play()
	player.flip_h = target_offset < path_follow.progress


#func _process(delta):
	#if not is_moving:
		#return
#
	## Move toward the target stop
	#var dir = sign(target_offset - path_follow.progress)
	#path_follow.progress += dir * move_speed * delta
	#
	#var max_offset = path.curve.get_baked_length()
	#path_follow.progress = clamp(path_follow.progress, 0, max_offset)
#
	## Follow with the player sprite
	#player.global_position = path_follow.global_position
#
	## If we're close enough to the stop, snap to it
	#if abs(path_follow.progress - target_offset) < 2.0:
		#snap_to_stop(current_index)
		
func _process(delta):
	if not is_moving:
		$MovementSound.stop()
		return

	var distance = target_offset - path_follow.progress

	# Check if we will reach or overshoot the target this frame
	var move_amount = move_speed * delta

	if abs(distance) <= move_amount:
		# Snap immediately
		snap_to_stop(current_index)
	else:
		# Move in direction
		var dir = sign(distance)
		path_follow.progress += dir * move_amount
		player.global_position = path_follow.global_position


# ==========================================
#            SNAP TO A STOP
# ==========================================
func snap_to_stop(index):
	is_moving = false
	var data = stops[index]

	# Snap position
	path_follow.progress = data["offset"]
	player.global_position = path_follow.global_position

	# Idle animation
	player.play("idle")

	# Show stop name
	label.text = data["name"]
	label_container.visible = true


# ==========================================
#            ENTER LEVEL FROM STOP
# ==========================================
#func enter_level():
	#if is_moving:
		#return  # Can't enter while moving
#
	#var data = stops[current_index]
	#if data["scene"] == null:
		#return
#
	#get_tree().change_scene_to_file(data["scene"])
	
#func enter_level():
	#if is_moving:
		#return  # Don’t allow entering while moving
#
	#if stops.size() == 0:
		#return
#
	#var data = stops[current_index]
	#var lvl_path = data.get("scene", null)
#
	#if lvl_path == null:
		#push_warning("No level path assigned to stop %d" % current_index)
		#return
		#
	#if current_index == 0:
		#$FileDialog.show()
	#elif current_index == 1:
		#SceneManager.change_scene(
		#"res://scenes/level editor/testing/tutorial_level_loader.tscn")
	#else:
		## Call your existing SceneManager function
		#SceneManager.change_scene_extra_args(
			#"res://scenes/level editor/testing/test_custom_level_editor.tscn",
			#[lvl_path]
		#)
		#
#func file_selected(file_path:String):
	#SceneManager.change_scene_extra_args(
		#"res://scenes/level editor/testing/test_custom_level_editor.tscn", 
		#[file_path]
	#)
	
func enter_level():
	if is_moving:
		return  # Don’t allow entering while moving

	if stops.size() == 0 or current_index >= stops.size():
		push_warning("Invalid stop index: %d" % current_index)
		return

	var data = stops[current_index]
	var lvl_path = data.get("scene", null)

	if lvl_path == null:
		push_warning("No level path assigned to stop %d" % current_index)
		return

	match current_index:
		0:
			$FileDialog.show()
		1:
			$BitVoice.play()
			$LevelEnter.play()
			await $LevelEnter.finished
			SceneManager.change_scene(
				"res://scenes/level editor/testing/tutorial_level_loader.tscn")
		_:
		 # Safely pass the level path
			print("Entering level with path:", lvl_path)
			$BitVoice.play()
			$LevelEnter.play()
			await $LevelEnter.finished
			SceneManager.change_scene_extra_args(
				"res://scenes/level editor/testing/test_custom_level_editor.tscn",
				[lvl_path]
			)
	
func file_selected(file_path:String):
	$BitVoice.play()
	$LevelEnter.play()
	await $LevelEnter.finished
	SceneManager.change_scene_extra_args(
		"res://scenes/level editor/testing/test_custom_level_editor.tscn", 
		[file_path]
	)


	
