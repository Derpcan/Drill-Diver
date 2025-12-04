extends Area2D
class_name Hurtbox

## The health component that should lose health when taking damage
@export var health_component:HealthComponent

## The collision shape that outlines the area that should register as getting hurt
@export var collision_shape:CollisionShape2D


signal got_hit


func _take_damage(damage_value:int) -> void:
	print("ow!")
	if health_component:
		health_component.current_hp -= damage_value
	got_hit.emit()
