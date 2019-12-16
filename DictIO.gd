extends Node

#Dictionary Manipulation:
####################################################################

func manipulate_nested_dict(nested_dict:Dictionary, path, mode, insert, trace):
	"""
	Reads or writes in a nested dictionary at the 'path', a array of 'key' value for the dictionary.
	Returns 'null' if incorrect mode. Return type adopted from the type of the dictionary content if 'mode' 
	is set to 'read'. Returns a updated dictionary in case 'mode' is 'write'.
	"""
	trace = [nested_dict] # else first key gets lost, the complete dict gets preallocated

	if mode == 'read':
		var output = IO_recursive_nested_dict(nested_dict, path, mode, insert, trace)
		return(output)
	elif mode == 'write':
		var output = IO_recursive_nested_dict(nested_dict, path, mode, insert, trace)
		return(output)
		
	else: 
		print("\n 'mode' argument specified incorrectly.")
		return(null)

func build_nested_dict(path:Array, endpoint:='empty', dict:={}) -> Dictionary:
	#Helper function for IO_recursive_nested_dict.
	var key = path[0]
	if path.size() > 1:	
		path.erase(path[0])
		dict = {key:build_nested_dict(path, endpoint, dict)}
	elif path.size() == 1:
		if endpoint == 'empty':
			dict[key] = "EMPTY"
		elif endpoint == 'emptydict':
			dict[key] = {}
	return(dict)

func IO_recursive_nested_dict(nested_dict:Dictionary, path:Array, mode:String, insert, trace:Array):
	#Helper function for 'manipulate_nested_dict'. 
	
	if not nested_dict.keys().has(path[0]) and mode == 'write':
		if path.size() > 1: #next 7 lines for splitting into element path[0] and tmp
			var i = 0
			var tmp = []
			for element in path:
				if i > 0:
					tmp.append(element)
				i += 1
				
			nested_dict[path[0]] = build_nested_dict(tmp)
		elif typeof(insert) == TYPE_DICTIONARY: #in case path len is short and insert dict
			nested_dict[path[0]] = 'Empty'
		else:
			nested_dict[path[0]] = insert

	var content = nested_dict.get(path[0])
	
	if typeof(content) == TYPE_DICTIONARY and path.size() > 0:
	
		if path.size() > 1:
			path.erase(path[0])
		trace.append(content)
		IO_recursive_nested_dict(content, path, mode, insert, trace)
		

		
	var lowest = trace[trace.size()-1] #'lowest' for readability
	var read_result

	if mode == "read":
		if path[0] in lowest.keys():
			read_result = lowest.get(path[0])
			return(read_result)
		else:
			print("\n Warning: latest entry in path could not be used as key. Returning as is.")
			return(lowest)
	elif mode == "write":
		if lowest.keys().has(path[0]) and not lowest.keys().size() == 0:
			lowest[path[0]] = insert	
			trace[trace.size()-1] = lowest	
		else:
			print('Enpoint is empty dictionary')
			lowest['new'] = insert
		return(trace[0])

func create_students(dict:Dictionary, group:String, students:Array, content):

	var tmpdict = {}
	for name in students:
		tmpdict[name] = content

	var path = ['Classes', group]
		
	dict = DictIO.manipulate_nested_dict(dict, path, 'write', tmpdict, [])
	return(dict)
