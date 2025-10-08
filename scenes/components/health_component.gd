extends Node
class_name HealthComponent


signal died()
signal took_damage(new_health_value:int)
signal healed_fully()

## The max hp the object or character should have
@export var max_hp:int = 1

# Keeps track of the current health
var current_hp:int = 0:
	set(new_hp): # Setter
		if new_hp <= 0: # If the new health <= 0, the object should be dead
			current_hp = 0 # Make sure the health can't go below 0
			print("Died") 
			emit_signal("died") # Emit died signal
			return
		
		if new_hp < current_hp: # If the object took damage
			print("Took Damage")
			emit_signal("took_damage", new_hp) # Emit hurt signal
		
		current_hp = clamp(new_hp, 0, max_hp) # Update current health, maxing at max_hp and min at 0

# Sets health to max at start
func _ready() -> void:
	current_hp = max_hp

# Heals to max health
func _heal_fully() -> void:
	current_hp = max_hp
	emit_signal("healed_fully")
