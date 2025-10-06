extends Node
class_name HealthComponent


signal died()
signal took_damage(new_health_value:int)

@export var max_hp:int = 1

var current_hp:int = 0:
	set(new_hp):
		if new_hp <= 0:
			current_hp = 0
			print("Died")
			emit_signal("died")
			return
		
		if new_hp < current_hp:
			print("Took Damage")
			emit_signal("took_damage", new_hp)
		
		current_hp = clamp(new_hp, 0, max_hp)


func _ready() -> void:
	current_hp = max_hp
