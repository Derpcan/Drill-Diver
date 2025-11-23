extends Node2D
@export var GeneratorPlayer:AnimationPlayer
@export var ExplosionPlayer:AnimationPlayer
var blown_up:bool = false
func _ready():
	GeneratorPlayer.play("Running")




func _on_area_2d_area_entered(area):
	if blown_up == false:
		ExplosionPlayer.play("Blow Up")
		await ExplosionPlayer.animation_finished
		GeneratorPlayer.play("Broken")
		blown_up = true
	
