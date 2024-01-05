@tool
extends EditorScript


func _run() -> void:
	var modules_root_path = "res://modules/"
	var files_modules: Dictionary
	var modules_dependencies: Dictionary
	
	var modules = _get_modules_paths(modules_root_path)
	for module_path in modules:
		for file_path in _get_files_at_recursive(module_path):
			files_modules[file_path] = module_path 
	
	for module_path in modules:
		var dependencies_hash: Dictionary
		for dependency_info in _get_directory_content_dependencies(module_path):
			var dependency_file_path = dependency_info.get_slice("::", 2)
			
			if not files_modules.has(dependency_file_path):
				continue
			
			var dependency_module = files_modules[dependency_file_path]
			if dependency_module != module_path\
			and not dependencies_hash.has(dependency_module):
				dependencies_hash[dependency_module] = true
		
		modules_dependencies[module_path] = dependencies_hash.keys()
	
	var output_folder_path = "res://modules/dependencies_finder/output/"
	for module_path: String in modules_dependencies:
		var module_name = module_path.get_file()
		var dependencies = modules_dependencies[module_path].map(func(x):
			return x.get_file())
		
		var file_path = output_folder_path.path_join(module_name) + ".md"
		var output_file = FileAccess.open(file_path, FileAccess.WRITE)
		
		for dependency in dependencies:
			output_file.store_line("[[" + dependency + "]]")
		
		output_file.close()


func _get_modules_paths(root_path: String) -> Array[String]:
	var modules_paths: Array[String]
	
	for inner_directory in DirAccess.get_directories_at(root_path):
		var inner_directory_path = root_path.path_join(inner_directory)
		var directory_is_module = not DirAccess.get_files_at(inner_directory_path).is_empty()
		if directory_is_module:
			modules_paths.append(inner_directory_path)
			continue
		
		modules_paths.append_array(_get_modules_paths(inner_directory_path))
	
	return modules_paths


func _get_files_at_recursive(directory_path: String) -> Array[String]:
	var files: Array[String]
	for file_path in DirAccess.get_files_at(directory_path):
		files.append(directory_path.path_join(file_path))
	
	for inner_directory_name in DirAccess.get_directories_at(directory_path):
		var inner_directory_path = directory_path.path_join(inner_directory_name)
		files.append_array(_get_files_at_recursive(inner_directory_path))
	
	return files


func _get_directory_content_dependencies(directory_path: String,
		recursive = true) -> Array[String]:
	var dependencies_hash: Dictionary
	var dependencies: Array[String]
	
	for file_name in DirAccess.get_files_at(directory_path):
		var file_path = directory_path.path_join(file_name)
		for dependency in ResourceLoader.get_dependencies(file_path):
			if not dependencies_hash.has(dependency): # dictionary used for fast .has() check
				dependencies_hash[dependency] = true
				dependencies.append(dependency)
	
	if not recursive:
		return dependencies
	
	for inner_directory_name in DirAccess.get_directories_at(directory_path):
		var inner_directory_path = directory_path.path_join(inner_directory_name)
		for inner_dependency in _get_directory_content_dependencies(inner_directory_path):
			if not dependencies_hash.has(inner_dependency): # dictionary used for fast .has() check
				dependencies_hash[inner_dependency] = true
				dependencies.append(inner_dependency)
	
	return dependencies
