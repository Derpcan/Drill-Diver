extends HSlider


@export var ghost:Ghost

func _ready() -> void:
	
	await get_tree().physics_frame
	ghost.input_component._set_replay_frame(0)
	
	max_value = len(ghost.input_component.key_array)
	step = 1
	
	value_changed.connect(ghost.input_component._set_replay_frame)
	ghost.input_component.key_array_index_changed.connect(_update_slider)
	
	drag_started.connect(ghost.input_component._enable_pause_playback)
	drag_ended.connect(ghost.input_component._disable_pause_playback)

func _update_slider(new_value:int) -> void:
	value = new_value
