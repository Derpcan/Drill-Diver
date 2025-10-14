extends Area2D
class_name HitBox


@export var damage:int = 1

signal hit_something(parent, other_body)

func _ready() -> void:
	area_entered.connect(inflict_damage)



func inflict_damage(hurtbox:Hurtbox) -> void:
	hurtbox._take_damage(damage)
	
	if get_parent():
		emit_signal("hit_something", get_parent(), hurtbox.get_parent())
