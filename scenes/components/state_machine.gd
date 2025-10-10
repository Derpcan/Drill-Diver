extends Node
class_name StateMachine

# Dictionary is an index to the state value
var state_dict:Dictionary = {}
var states:Array = []


signal enter_state(state_name:String, state_index:int)

# Keep track of the current state
var current_state:int = -1:
	set(new_state):
		# Set previous state to the current state
		previous_state = current_state
		# Update the current state to the new state
		current_state = new_state
# Keep track of the previous state
var previous_state:int = -1

# Add a state to the states array
func _add_state(state_name:String) -> void:
	state_dict[len(state_dict)] = state_name
	states.append(state_name)
	#print("Added State " + state_name)
	print_rich("[color=#FF7A9E]Added State: ", state_name, "[/color]")

# Enter the state that is passed through
func _enter_state(new_state:String) -> void:
	if new_state == states[current_state]:
		return
	current_state = states.find(new_state)
	enter_state.emit(new_state, current_state)
