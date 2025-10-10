extends Area2D
class_name HitBox


@export var damage:int = 1


func _ready() -> void:
	area_entered.connect(inflict_damage)



func inflict_damage(hurtbox:Hurtbox) -> void:
	hurtbox._take_damage(damage)
