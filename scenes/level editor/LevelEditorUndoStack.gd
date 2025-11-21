extends Resource
class_name UndoStack


var stack_array:Array = []

var max_len:int = 50


func push_array(new_array:Array) -> void:
	stack_array.append(new_array)
	
	if len(stack_array) > max_len:
		pop()


# Add to the last array
func push(new_tile_position) -> void:
	if len(stack_array) <= 0:
		stack_array.append([])
	
	if new_tile_position not in stack_array.back():
		stack_array.back().append(new_tile_position)

func pop() -> Array:
	if len(stack_array) > 0:
		return stack_array.pop_back()
	return []

func peek() -> Array:
	if len(stack_array) == 0:
		return []
	return stack_array.back()
