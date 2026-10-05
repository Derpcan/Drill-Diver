extends CanvasLayer
class_name Ranking
@export var rankletter:RankLetter
@export var bit:BitReaction
@export var time:Label
@export var timer:Timer



var minutes:float = 0.0:
	set(new_value):
		minutes = new_value
		time.text = "%02d:%02d.%02d" % [minutes, seconds, miliseconds]
		
var seconds:float = 0.0:
	set(new_value):
		seconds = new_value
		time.text = "%02d:%02d.%02d" % [minutes, seconds, miliseconds]
		
var miliseconds:float = 0.0:
	set(new_value):
		miliseconds = new_value
		time.text = "%02d:%02d.%02d" % [minutes, seconds, miliseconds]
var completeTime
var completeTimeMin
var completeTimeSec
var completeTimeMili
var sranktime
const LERP_SPEED:float = 0.5

func _ready():
	
	
	
	
	time.text = "%02d:%02d.%02d" % [minutes, seconds, miliseconds]
	

		
func _reveal_time():
	var tween = create_tween()
	$BuildUpSound.play()
	tween.set_parallel()
	tween.tween_method(Callable(self, "_update_minutes"), minutes, completeTimeMin, 2)
	tween.tween_method(Callable(self, "_update_seconds"), seconds, completeTimeSec, 2)
	tween.tween_method(Callable(self, "_update_mili"), miliseconds, completeTimeMili, 2)
	await tween.finished
	$BuildUpSound.stop()
	timer.start()
	await timer.timeout
	_decide_rank()
	
func _update_minutes(value:float):
	minutes=value
	
func _update_seconds(value:float):
	seconds=value

func _update_mili(value:float):
	miliseconds=value
	
		
func _decide_rank():
	var music_player:AudioStreamPlayer = AudioStreamPlayer.new()
	music_player.volume_db = 5
	music_player.autoplay = true
	if (completeTime <= sranktime):
		rankletter._play_S_rank()
		bit._play_S_rank()
		$"S Rank".play()
		randomize() 
		var random_number = randi_range(1, 3)	
		print(random_number)
		if random_number==1:
			music_player.stream = preload("res://assets/voices/bit/Woohoo.wav")
		elif random_number==2:
			music_player.stream = preload("res://assets/voices/bit/Piece of Cake.wav")
		else:
			music_player.stream = preload("res://assets/voices/bit/Almost Too Easy.wav")
		
		
		music_player.bus = "Sound Effects"
		music_player.stream.mix_rate = 48000
		music_player.play()
		add_child(music_player)
		
		
	elif (completeTime <= sranktime*1.5):
		rankletter._play_A_rank()
		bit._play_A_rank()
		$"A Rank".play()
		randomize() 
		var random_number = randi_range(1, 3)	
		if random_number==1:
			music_player.stream = preload("res://assets/voices/bit/Not Too Shabby.wav")
		elif random_number==2:
			music_player.stream = preload("res://assets/voices/bit/Allright!.wav")
		else:
			music_player.stream = preload("res://assets/voices/bit/NICE.wav")
			
		music_player.bus = "Sound Effect"
		music_player.stream.mix_rate = 48000
		music_player.play()
		add_child(music_player)
	elif (completeTime <= sranktime*1.8):
		rankletter._play_B_rank()
		bit._play_B_rank()
		$"B Rank".play()
		randomize() 
		var random_number = randi_range(1, 2)	
		if random_number==1:
			music_player.stream = preload("res://assets/voices/bit/Hey Could've Been Worse.wav")
		else:
			music_player.stream = preload("res://assets/voices/bit/Phew Just Made It.wav")
		music_player.bus = "Sound Effect"
		music_player.stream.mix_rate = 48000
		music_player.play()
		add_child(music_player)
	elif (completeTime <= sranktime*2):
		rankletter._play_C_rank()
		bit._play_C_rank()
		$"C Rank".play()
		randomize() 
		var random_number = randi_range(1, 3)	
		if random_number==1:
			music_player.stream = preload("res://assets/voices/bit/Mannnn.wav")
		elif random_number==2:
			music_player.stream = preload("res://assets/voices/bit/Really Not My Day.wav")
		else:
			music_player.stream = preload("res://assets/voices/bit/Ill get em next time.wav")
			
		music_player.bus = "Sound Effect"
		music_player.stream.mix_rate = 48000
		music_player.play()
		add_child(music_player)
	else:
		rankletter._play_D_rank()
		bit._play_D_rank()
		$"D Rank".play()
		randomize() 
		var random_number = randi_range(1, 2)	
		if random_number==1:
			music_player.stream = preload("res://assets/voices/bit/SCREAM.wav")
		else:
			music_player.stream = preload("res://assets/voices/bit/STUPID DRILL.wav")
		music_player.bus = "Sound Effect"
		music_player.stream.mix_rate = 48000
		music_player.play()
		add_child(music_player)

func _set_complete_time(timetaken:float):
	completeTime = timetaken
	completeTimeMin = float(int(completeTime / 60))
	completeTimeSec = int(completeTime) % 60
	completeTimeMili = round((completeTime - int(completeTime)) * 100)

func _set_S_rank_time(s_rank_time:float):
	sranktime = s_rank_time
	
func _A_rank():
	bit._play_A_rank()
	rankletter._play_A_rank()
	$"A Rank".play()

func _B_rank():
	bit._play_B_rank()
	rankletter._play_B_rank()
	$"B Rank".play()
	
func _C_rank():
	bit._play_C_rank()
	rankletter._play_C_rank()
	$"C Rank".play()
	
func _D_rank():
	bit._play_D_rank()
	rankletter._play_D_rank()
	$"D Rank".play()
	
func _S_rank():
	bit._play_S_rank()
	rankletter._play_S_rank()
	$"S Rank".play()
