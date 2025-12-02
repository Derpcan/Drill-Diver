extends CanvasLayer
class_name AudioSettings



@export var master_audio_slider:HSlider
@export var master_label:Label

@export var sfx_audio_slider:HSlider
@export var sfx_label:Label

@export var music_audio_slider:HSlider
@export var music_label:Label

@export var typing_audio_slider:HSlider
@export var typing_label:Label


func _ready() -> void:
	master_audio_slider.grab_focus()
	master_audio_slider.value_changed.connect(_update_master_audio)
	sfx_audio_slider.value_changed.connect(_update_sfx_audio)
	music_audio_slider.value_changed.connect(_update_music_audio)
	typing_audio_slider.value_changed.connect(_update_typing_audio)
	
	load_audio_sliders()
	
	tree_exiting.connect(_save_audio_settings)


static func load_audio_settings() -> void:
	if not FileAccess.file_exists(folder_path + file_path):
		return
	
	var file:FileAccess = FileAccess.open(folder_path + file_path, FileAccess.READ)
	var json = JSON.to_native(JSON.parse_string(file.get_as_text()))
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(json["Master"]/100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), linear_to_db(json["Sound"]/100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(json["Music"]/100.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Typing"), linear_to_db(json["Typing"]/100.0))


static var folder_path:String = "user://settings/"
static var file_path:String = "audio_settings.cfg"
func _save_audio_settings() -> void:
	DirAccess.make_dir_recursive_absolute(folder_path)
	var file:FileAccess = FileAccess.open(folder_path + file_path, FileAccess.WRITE)
	
	var audio_dict:Dictionary[String, float] = {
		"Master":AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))*100,
		"Sound":AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Sound Effects"))*100,
		"Music":AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))*100,
		"Typing":AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Typing"))*100,
	}
	
	file.store_string(JSON.stringify(JSON.from_native(audio_dict), "\t"))


func load_audio_sliders() -> void:
	master_audio_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))*100
	sfx_audio_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Sound Effects"))*100
	music_audio_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))*100
	typing_audio_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Typing"))*100


func _update_master_audio(new_value:float) -> void:
	var new_volume_level:float = new_value/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(new_volume_level))
	master_label.text = "Master Audio: " + str(new_volume_level*100) + "%"

func _update_sfx_audio(new_value:float) -> void:
	var new_volume_level:float = new_value/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), linear_to_db(new_volume_level))
	sfx_label.text = "Sound Effects Audio: " + str(new_volume_level*100) + "%"

func _update_music_audio(new_value:float) -> void:
	var new_volume_level:float = new_value/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(new_volume_level))
	music_label.text = "Music Audio: " + str(new_volume_level*100) + "%"

func _update_typing_audio(new_value:float) -> void:
	var new_volume_level:float = new_value/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Typing"), linear_to_db(new_volume_level))
	typing_label.text = "Typing Audio: " + str(new_volume_level*100) + "%"
