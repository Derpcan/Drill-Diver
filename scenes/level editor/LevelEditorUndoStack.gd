extends Resource
class_name UndoStack


var stack_array:Array = []

var max_len:int = 50


func push_array(new_array:Array) -> void:
	# Remove any arrays of size 1
	for arr in stack_array:
		if len(arr) == 1:
			stack_array.erase(arr)
	
	# Add new array
	stack_array.append(new_array)
	
	# If there is too many, delete the first element
	if len(stack_array) > max_len:
		stack_array.pop_front()


func push_dictionary(new_dict:Dictionary) -> void:
	# Remove any arrays of size 1
	for dict in stack_array:
		if len(dict[false]) == 0 and len(dict[true]) == 0:
			stack_array.erase(dict)
	
	# Add new array
	stack_array.append(new_dict)
	
	# If there is too many, delete the first element
	if len(stack_array) > max_len:
		stack_array.pop_front()

# Add to the last array
func push(data, is_deleting:bool) -> void:
	if len(stack_array) <= 0:
		stack_array.append({false:[], true:[]})
	
	
	if data not in stack_array.back():
		#stack_array.back().append(new_tile_position)
		stack_array.back()[is_deleting].append(data)


func pop() -> Dictionary:
	while peek() != {}:
		print("STACK AT POP: ", stack_array)
		for i in range(len(stack_array)-1, 0, -1):
			
			if len(peek()[false]) != 0 or len(peek()[true]) != 0:
				return stack_array.pop_back()
		#stack_array.pop_back()
		
		return stack_array.pop_back()
	return {}

func peek() -> Dictionary:
	if len(stack_array) == 0:
		return {}
	return stack_array.back()
