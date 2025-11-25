extends Node2D
class_name Goal

@export var GeneratorPlayer:AnimationPlayer
@export var ExplosionPlayer:AnimationPlayer
var Sranktime:float
var blown_up:bool = false
@export var ranking:Ranking

signal score_shown

signal new_time_got(new_time:float)

func _ready():
	#Sranktime = get_parent().s_rank_time
	GeneratorPlayer.play("Running")




func _on_area_2d_area_entered(area):
	if blown_up == false:
		get_tree().get_first_node_in_group("hud").visible = false
		if Sranktime == 0:
			ranking._set_S_rank_time(get_tree().current_scene.s_rank_time)
		else:
			ranking._set_S_rank_time(Sranktime)
		
		GameManager.stop_timer.emit()
		
		ranking._set_complete_time(GameManager.get_current_time())
		ExplosionPlayer.play("Blow Up")
		
		get_tree().get_first_node_in_group("player")._end_level()
		#get_parent().get_node("Player")._end_level()
		
		await ExplosionPlayer.animation_finished
		
		GeneratorPlayer.play("Broken")
		blown_up = true
		ranking.visible = true
		ranking._reveal_time()
		score_shown.emit()
		new_time_got.emit(GameManager.get_current_time())
	
