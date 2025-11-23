extends Node2D
@export var GeneratorPlayer:AnimationPlayer
@export var ExplosionPlayer:AnimationPlayer
var Sranktime
var blown_up:bool = false
@export var ranking:Ranking
func _ready():
	Sranktime = get_parent().s_rank_time
	GeneratorPlayer.play("Running")




func _on_area_2d_area_entered(area):
	if blown_up == false:
		get_parent().get_node("Hud").visible = false
		ranking._set_S_rank_time(get_parent().s_rank_time)
		ranking._set_complete_time(GameManager.get_current_time())
		ExplosionPlayer.play("Blow Up")
		get_parent().get_node("Player")._end_level()
		
		await ExplosionPlayer.animation_finished
		
		GeneratorPlayer.play("Broken")
		blown_up = true
		ranking.visible = true
		ranking._reveal_time()
	
