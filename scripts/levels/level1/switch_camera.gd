extends Button

var cameras : Array[Camera2D]
var active_cam : Camera2D
var active_index : int

func _ready() -> void:
	var nodes = get_node("/root/Level1Main/Player").get_children()
	for node in nodes:
		if node is Camera2D:
			cameras.append(node)

	active_cam = get_viewport().get_camera_2d()
	active_index = cameras.find(active_cam)
	
	connect("pressed", _switch_camera)

func _switch_camera() -> void:
	if active_index == (cameras.size() - 1):
		active_index = 0
	else:
		active_index += 1
	
	active_cam = cameras[active_index]
	active_cam.set_enabled(true)
	active_cam.make_current()
