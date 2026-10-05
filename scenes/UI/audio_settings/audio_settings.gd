extends CanvasLayer
class_name AudioSettings


@export var audio_player:AudioStreamPlayer

@export var master_audio_slider:HSlider
@export var master_label:Label

@export var sfx_audio_slider:HSlider
@export var sfx_label:Label

@export var music_audio_slider:HSlider
@export var music_label:Label

@export var typing_audio_slider:HSlider
@export var typing_label:Label


func _ready() -> void:
	randomize()
	master_audio_slider.grab_focus()
	master_audio_slider.value_changed.connect(_update_master_audio)
	sfx_audio_slider.value_changed.connect(_update_sfx_audio)
	music_audio_slider.value_changed.connect(_update_music_audio)
	typing_audio_slider.value_changed.connect(_update_typing_audio)
	
	load_audio_sliders()
	
	tree_exiting.connect(_save_audio_settings)
	timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	timer.connect("timeout", _stop_audio_player)
	add_child(timer)


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


var timer:Timer
func _stop_audio_player() -> void:
	audio_player.stop()


func _update_master_audio(new_value:float) -> void:
	var new_volume_level:float = new_value/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(new_volume_level))
	master_label.text = "Master Audio: " + str(new_volume_level*100) + "%"

func _update_sfx_audio(new_value:float) -> void:
	var new_volume_level:float = new_value/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), linear_to_db(new_volume_level))
	sfx_label.text = "Sound Effects Audio: " + str(new_volume_level*100) + "%"
	
	if timer:
		var arr:Array[AudioStreamWAV] = [
			preload("res://assets/sounds/DD - dash.wav"),
			preload("res://assets/sounds/DD - death.wav"),
			preload("res://assets/sounds/DD - drill start.wav"),
			preload("res://assets/sounds/dd - drill sound start only.wav"),
			preload("res://assets/sounds/DD - enemy death.wav"),
			preload("res://assets/sounds/DD - full meter cue.wav"),
			preload("res://assets/sounds/dd - gem pickup new.wav"),
		]
		audio_player.bus = "Sound Effects"
		if audio_player.stream not in arr:
			audio_player.stop()
			audio_player.stream = arr.pick_random()
			audio_player.play()
			
		if not audio_player.playing:
			audio_player.stop()
		
			audio_player.stream = arr.pick_random()
			audio_player.play()
	

func _update_music_audio(new_value:float) -> void:
	var new_volume_level:float = new_value/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(new_volume_level))
	music_label.text = "Music Audio: " + str(new_volume_level*100) + "%"
	
	if timer:
		audio_player.bus = "Music"
		if audio_player.stream != preload("res://assets/music/dd - song 2.wav") or not audio_player.playing:
			if audio_player.playing:
				audio_player.stop()
			audio_player.stream = preload("res://assets/music/dd - song 2.wav")
			audio_player.play()
			timer.start(5)

func _update_typing_audio(new_value:float) -> void:
	var new_volume_level:float = new_value/100.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Typing"), linear_to_db(new_volume_level))
	typing_label.text = "Typing Audio: " + str(new_volume_level*100) + "%"
	
	if timer:
		audio_player.bus = "Typing"
		if audio_player.playing:
			audio_player.stop()
		var arr:Array[AudioStreamWAV] = [
			preload("res://addons/dialogic/Example Assets/sound-effects/typing1.wav"),
			preload("res://addons/dialogic/Example Assets/sound-effects/typing2.wav"),
			preload("res://addons/dialogic/Example Assets/sound-effects/typing3.wav"),
			preload("res://addons/dialogic/Example Assets/sound-effects/typing4.wav"),
			preload("res://addons/dialogic/Example Assets/sound-effects/typing5.wav"),
		]
		audio_player.stream = arr.pick_random()
		audio_player.play()
