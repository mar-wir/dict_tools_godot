extends Node


#Dictionary Export to CSV as flattened, tidy data frame:
####################################################################
func trace_paths_recursive(nested_dict:Dictionary, trace:Array):
	var keys = nested_dict.keys()

	for key in keys:
		var content = nested_dict.get(key)
		trace.append(key)
		if typeof(content) == TYPE_DICTIONARY: 		
			trace_paths_recursive(content, trace)
		else:
			trace.append(null)
	
	return(trace)

func get_nested_values(nested_dict:Dictionary, end_entry:Array):
	var keys = nested_dict.keys()

	for key in keys:
		var content = nested_dict.get(key)
		if typeof(content) == TYPE_DICTIONARY: 		
			get_nested_values(content, end_entry)
		else:
			end_entry.append(content)
  
	return(end_entry)

func delimit_array_content(array:Array):

	var container = []
	var tmp = []

	for element in array:
		tmp.append(element)
		if element == null:
			tmp.erase(null)
			container.append(tmp)
			tmp = []

	return(container)

func complete_paths_iterate(delim_paths:Array):
	var tmp = []
	var container = []
	var max_path = delim_paths.max() #first longest path
	 
	for element in delim_paths:
		var e_size = element.size()
		var i = 0
		for l in max_path:
			if i <= (max_path.size()-e_size-1):
				tmp.append(l)
				i += 1
		max_path = tmp+element #new longest path is the last constructed
		container.append(max_path)
		tmp = []
	
	return(container)

func flatten_dictionary(nested_dict:Dictionary, output:String):

	var raw_paths = trace_paths_recursive(nested_dict, [])
	var delim_paths = delimit_array_content(raw_paths)
	var complete_paths = complete_paths_iterate(delim_paths)
	if output == 'paths':
		return(complete_paths)
	var raw_values = get_nested_values(nested_dict, [])
	if output == 'values':
		return(raw_values)

	var i = 0

	if output == 'dictionary':
		var container = {}
		for key in complete_paths:
			
			container[key] = raw_values[i]
			i += 1
		return(container)
	elif output == 'array':
		var container = []
		for i in complete_paths.size():
			container.append([complete_paths[i],raw_values[i]])
		return(container)
	else:
		print("Wrong output format specified. Your options are: dictionary, array, values and paths.")

func export_nested_dict_to_csv(nested_dict:Dictionary, path:String, filename:String, sep:String):
	var flat = flatten_dictionary(nested_dict, "dictionary")
	var container = []

	var i = 0
	for element in flat.keys():
		var curr_val = flat.values()[i]
		element.insert(element.size(), curr_val)
		container.append(element)
		i += 1
	
	var end_dir = path+"/"+filename+".csv"
	var file = File.new()
	if (file.open(end_dir, File.WRITE)== OK):
		for i in range(container.size()):
			file.store_csv_line(container[i], sep)
		file.close()
####################################################################