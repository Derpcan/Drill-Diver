extends CanvasLayer
@export var rankletter:RankLetter
@export var bit:BitReaction
@export var time:Label
@export var timer:Timer
var minutes
var seconds
var miliseconds
var completeTime
var completeTimeMin
var completeTimeSec
var completeTimeMili
var sranktime
const LERP_SPEED:float = 0.5

func _ready():
	minutes = 0.0
	seconds = 0.0
	miliseconds = 0.0
	_set_complete_time(4000)
	
	
	sranktime = 1520.0
	time.text = "%02d:%02d.%02d" % [minutes, seconds, miliseconds]


func _process(delta):
	minutes = move_toward(minutes, completeTimeMin, LERP_SPEED)
	seconds = move_toward(seconds, completeTimeSec, LERP_SPEED)
	miliseconds = move_toward(miliseconds, completeTimeMili, LERP_SPEED)
	time.text = "%02d:%02d.%02d" % [minutes, seconds, miliseconds]
	if is_equal_approx(minutes,completeTimeMin) && is_equal_approx(seconds,completeTimeSec) && is_equal_approx(miliseconds,completeTimeMili):
		set_process(false)
		timer.start()
		await timer.timeout
		_decide_rank()
		
func _decide_rank():
	if (completeTime <= sranktime):
		rankletter._play_S_rank()
		bit._play_S_rank()
	elif (completeTime <= sranktime*1.5):
		rankletter._play_A_rank()
		bit._play_A_rank()
	elif (completeTime <= sranktime*1.8):
		rankletter._play_B_rank()
		bit._play_B_rank()
	elif (completeTime <= sranktime*2):
		rankletter._play_C_rank()
		bit._play_C_rank()
	else:
		rankletter._play_D_rank()
		bit._play_D_rank()

func _set_complete_time(timetaken:float):
	completeTime = timetaken
	completeTimeMin = float(int(completeTime / 60))
	completeTimeSec = int(completeTime) % 60
	completeTimeMili = round((completeTime - int(completeTime)) * 100)

	
func _A_rank():
	bit._play_A_rank()
	rankletter._play_A_rank()

func _B_rank():
	bit._play_B_rank()
	rankletter._play_B_rank()
	
func _C_rank():
	bit._play_C_rank()
	rankletter._play_C_rank()
	
func _D_rank():
	bit._play_D_rank()
	rankletter._play_D_rank()
	
func _S_rank():
	bit._play_S_rank()
	rankletter._play_S_rank()
