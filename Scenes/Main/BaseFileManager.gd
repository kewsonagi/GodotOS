extends SmoothContainer
class_name BaseFileManager

## The base file manager inherited by desktop file manager and the file manager window.

## The file manager's path (relative to user://files/)
@export var windowTitle: RichTextLabel
@export var szFilePath: String
var directories: PackedStringArray
var itemLocations: Dictionary = {}
@export var startingUserDirectory: String = "user://files/"
@export var baseFile: PackedScene # = preload("res://Scenes/Desktop/TextFile.tscn")
@export var textFile: PackedScene # = preload("res://Scenes/Desktop/TextFile.tscn")
@export var extensionsForText: PackedStringArray = ["txt", "md"]
@export var imageFile: PackedScene # = preload("res://Scenes/Desktop/ImageFile.tscn")
@export var extensionsForImage: PackedStringArray = ["png", "jpg", "jpeg", "webp", "tif", "ico", "svg"]
@export var folderFile: PackedScene # = preload("res://Scenes/Desktop/FolderFile.tscn")
static var masterFileManagerList: Array[BaseFileManager]
@export var parentWindow: FakeWindow
@export var pathToIcons: String
static var iconList: Dictionary = {}

func _ready() -> void:
	super._ready()
	if(iconList.is_empty()):
		var iconFiles: PackedStringArray = DirAccess.get_files_at(pathToIcons)
		for iconFile in iconFiles:
			if(extensionsForImage.has(iconFile.get_extension())):
				# print("base filename %s" % iconFile.get_basename())
				# print("path to load %s/%s" % [pathToIcons.get_base_dir(), iconFile])
				iconList[iconFile.get_basename()] = "%s/%s" % [pathToIcons.get_base_dir(), iconFile]

func populate_file_manager() -> void:
	for child in get_children():
		if child is BaseFile:
			child.queue_free()

	directories.clear()
	directories = DirAccess.get_directories_at("%s%s" % [startingUserDirectory, szFilePath])
	itemLocations.clear()
	if (directories):
		for folder_name in directories:
			if szFilePath.is_empty():
				PopulateWithFolder(folder_name, folder_name)
			else:
				PopulateWithFolder(folder_name, "%s/%s" % [szFilePath, folder_name])
	
	directories.clear()
	directories = DirAccess.get_files_at("%s%s" % [startingUserDirectory, szFilePath])
	for file_name: String in directories:
		if(extensionsForText.has(file_name.get_extension())):
		# if file_name.ends_with(".txt") or file_name.ends_with(".md"):
			PopulateWithFile(file_name, szFilePath, BaseFile.E_FILE_TYPE.TEXT_FILE)
		# elif file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg") \
		# or file_name.ends_with(".webp"):
		elif (extensionsForImage.has(file_name.get_extension())):
			PopulateWithFile(file_name, szFilePath, BaseFile.E_FILE_TYPE.IMAGE)
		else:
			PopulateWithFile(file_name, szFilePath, BaseFile.E_FILE_TYPE.UNKNOWN)
	
	if(!DirAccess.dir_exists_absolute("%s%s" % [startingUserDirectory, szFilePath])):
		if(parentWindow):
			parentWindow._on_close_button_pressed()
		# queue_free()
	directories.clear()
	await get_tree().process_frame
	await get_tree().process_frame # TODO fix whatever's causing a race condition :/
	sort_folders()

	if(windowTitle):
		windowTitle.text = "%s" % [szFilePath]

func PopulateWithFolder(file_name: String, path: String) -> void:
	#print("adding file or folder in file manager: path: %s - name: %s" % [path, file_name])
	var folder: BaseFile = folderFile.instantiate()
	var file_type: BaseFile.E_FILE_TYPE = BaseFile.E_FILE_TYPE.FOLDER
	folder.szFileName = file_name
	folder.szFilePath = path
	folder.eFileType = file_type
	add_child(folder)
	itemLocations["%s%s" % [path, file_name]] = Vector2(0, 0)

func PopulateWithFile(file_name: String, path: String, file_type: BaseFile.E_FILE_TYPE) -> void:
	#print("adding file or folder in file manager: path: %s - name: %s" % [path, file_name])
	var file: BaseFile# = baseFileScene.instantiate()
	if(file_type == BaseFile.E_FILE_TYPE.TEXT_FILE):
		file = textFile.instantiate()
	elif(file_type == BaseFile.E_FILE_TYPE.IMAGE):
		file = imageFile.instantiate()
	elif(file_type == BaseFile.E_FILE_TYPE.FOLDER):
		file = folderFile.instantiate()
	else:
		file = baseFile.instantiate()
	#load a thumbnail if one exists for this file extension
	if(iconList.has(file_name.get_extension())):
		if(iconList.has(file_name.get_basename())):
			#see if we have an icon for this exact application
			file.fileIcon = ResourceLoader.load(iconList[file_name.get_basename()])
		else:
			file.fileIcon = ResourceLoader.load(iconList[file_name.get_extension()])
	

	file.szFileName = file_name
	file.szFilePath = path
	file.eFileType = file_type
	add_child(file)
	itemLocations["%s%s" % [path, file_name]] = Vector2(0, 0)


## Sorts all folders to their correct positions. 
func sort_folders() -> void:
	if len(get_children()) < 3:
		update_positions(false)
		return
	var sorted_children: Array[Node] = []
	for child in get_children():
		if child is BaseFile:
			sorted_children.append(child)
			remove_child(child)
	sorted_children.sort_custom(_custom_folder_sort)
	sorted_children.sort_custom(_custom_folders_first_sort)
	for child in sorted_children:
		add_child(child)
	
	await get_tree().process_frame
	update_positions(false)

## Creates a new folder.
## Not to be confused with instantiating which adds an existing real folder, this function CREATES one. 
func new_folder() -> void:
	var new_folder_name: String = "New Folder"
	var padded_file_path: String # Since I sometimes want the / and sometimes not
	if !szFilePath.is_empty():
		padded_file_path = "%s/" % szFilePath
	if DirAccess.dir_exists_absolute("%s%s%s" % [startingUserDirectory, padded_file_path, new_folder_name]):
		for i in range(2, 1000):
			new_folder_name = "New Folder %d" % i
			if !DirAccess.dir_exists_absolute("%s%s%s" % [startingUserDirectory, padded_file_path, new_folder_name]):
				break
	
	DirAccess.make_dir_absolute("%s%s%s" % [startingUserDirectory, padded_file_path, new_folder_name])
	for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
		if file_manager.szFilePath == szFilePath:
			file_manager.PopulateWithFile(new_folder_name, "%s%s" % [padded_file_path, new_folder_name], BaseFile.E_FILE_TYPE.FOLDER)
			await get_tree().process_frame # Waiting for child to get added...
			sort_folders()
	
	if szFilePath.is_empty():
		PopulateWithFolder(new_folder_name, "%s" % new_folder_name)
		sort_folders()

## Creates a new file.
## Not to be confused with instantiating which adds an existing real folder, this function CREATES one. 
func new_file(extension: String, file_type: BaseFile.E_FILE_TYPE) -> void:
	var new_file_name: String = "New File%s" % extension
	var padded_file_path: String # Since I sometimes want the / and sometimes not
	if !szFilePath.is_empty():
		padded_file_path = "%s/" % szFilePath
	
	if FileAccess.file_exists("%s%s%s" % [startingUserDirectory, padded_file_path, new_file_name]):
		for i in range(2, 1000):
			new_file_name = "New File %d%s" % [i, extension]
			if !FileAccess.file_exists("%s%s%s" % [startingUserDirectory, padded_file_path, new_file_name]):
				break
	
	# Just touches the file
	var _file: FileAccess = FileAccess.open("%s%s%s" % [startingUserDirectory, padded_file_path, new_file_name], FileAccess.WRITE)
	
	for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
		if file_manager.szFilePath == szFilePath:
			file_manager.PopulateWithFile(new_file_name, szFilePath, file_type)
			await get_tree().process_frame # Waiting for child to get added...
			file_manager.sort_folders()
	
	if szFilePath.is_empty():
		if (file_type == BaseFile.E_FILE_TYPE.FOLDER):
			PopulateWithFolder(new_file_name, szFilePath)
		else:
			PopulateWithFile(new_file_name, szFilePath, file_type)
		sort_folders()

## Finds a file/folder based on name and frees it (but doesn't delete it from the actual system)
func delete_file_with_name(file_name: String) -> void:
	for child in get_children():
		if !(child is BaseFile):
			continue
		
		if child.szFileName == file_name:
			itemLocations.erase(child.szFileName)
			child.queue_free()
	
	await get_tree().process_frame
	sort_folders()

## Keyboard controls for selecting files.
## Is kind of messy because the file manager can be horizontal or vertical, which changes which direction the next folder is.
func select_folder_up(current_folder: BaseFile) -> void:
	if direction == "Horizontal":
		select_previous_line_folder(current_folder)
	elif direction == "Vertical":
		select_previous_folder(current_folder)

func select_folder_down(current_folder: BaseFile) -> void:
	if direction == "Horizontal":
		select_next_line_folder(current_folder)
	elif direction == "Vertical":
		select_next_folder(current_folder)

func select_folder_left(current_folder: BaseFile) -> void:
	if direction == "Horizontal":
		select_previous_folder(current_folder)
	elif direction == "Vertical":
		select_previous_line_folder(current_folder)

func select_folder_right(current_folder: BaseFile) -> void:
	if direction == "Horizontal":
		select_next_folder(current_folder)
	elif direction == "Vertical":
		select_next_line_folder(current_folder)

func select_next_folder(current_folder: BaseFile) -> void:
	var target_index: int = current_folder.get_index() + 1
	if target_index >= get_child_count():
		return
	var next_child: Node = get_child(target_index)
	if next_child is BaseFile:
		current_folder.hide_selected_highlight()
		next_child.show_selected_highlight()

func select_next_line_folder(current_folder: BaseFile) -> void:
	var target_index: int = current_folder.get_index() + line_count
	if target_index >= get_child_count():
		return
	var target_folder: Node = get_child(target_index)
	if target_folder is BaseFile:
		current_folder.hide_selected_highlight()
		target_folder.show_selected_highlight()

func select_previous_folder(current_folder: BaseFile) -> void:
	var target_index: int = current_folder.get_index() - 1
	if target_index < 0:
		return
	var previous_child: Node = get_child(target_index)
	if previous_child is BaseFile:
		current_folder.hide_selected_highlight()
		previous_child.show_selected_highlight()

func select_previous_line_folder(current_folder: BaseFile) -> void:
	var target_index: int = current_folder.get_index() - line_count
	if target_index < 0:
		return
	var target_folder: Node = get_child(target_index)
	if target_folder is BaseFile:
		current_folder.hide_selected_highlight()
		target_folder.show_selected_highlight()


## Sorts folders based on their name
func _custom_folder_sort(a: BaseFile, b: BaseFile) -> bool:
	if a.szFileName.to_lower() < b.szFileName.to_lower():
		return true
	return false

## Puts folders first in the array (as opposed to files)
func _custom_folders_first_sort(a: BaseFile, b: BaseFile) -> bool:
	if a.eFileType == BaseFile.E_FILE_TYPE.FOLDER and a.eFileType != b.eFileType:
		return true
	return false

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if(data is BaseFile):
		if((data as BaseFile).szFilePath == self.szFilePath):
			return false
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if(data is BaseFile):
		var currentFile: BaseFile = (data as BaseFile)
		#look through children to see if we are dropping an item into ourself
		#if so, do nothing
		for child: Node in currentChildren:
			if (child == currentFile):
				return;
		
		#not an item in this window already, copy or move it
		# CopyPasteManager.cut_folder(currentFile)
		# CopyPasteManager.paste_folder(szFilePath)
		var from: String = "user://files/%s" % currentFile.szFilePath
		var to: String = "user://files/%s/" % szFilePath
		if(currentFile.eFileType != BaseFile.E_FILE_TYPE.FOLDER):
			from = "%s/%s" % [from, currentFile.szFileName]
		CopyAllFilesOrFolders([from], to, true, true)
		BaseFileManager.RefreshAllFileManagers()
		# CopyAllFilesOrFolders("%s/%s" % [currentFile.szFilePath, currentFile.szFileName], szFilePath)



static func RefreshAllFileManagers() -> void:
	for fileManager: BaseFileManager in masterFileManagerList:
		fileManager.populate_file_manager()

func _enter_tree() -> void:
	masterFileManagerList.append(self)
func _exit_tree() -> void:
	masterFileManagerList.erase(self)
	
func OnDroppedFolders(files: PackedStringArray) -> void:
	CopyAllFilesOrFolders(files)
		# get_tree().get_first_node_in_group("desktop_file_manager").populate_file_manager()
	populate_file_manager()

func CopyAllFilesOrFolders(files: PackedStringArray, to: String = "user://files/", override: bool = true, cut: bool = false) -> void:
	for thisFile: String in files:
		var dirToDelete: PackedStringArray
		#print(thisFile)
		var filename: String = thisFile.get_file()#get the end of the path/file, including extension
		
		#check if the filename has no extension, if so this is a folder to copy
		if(filename.is_empty() or filename.get_extension().is_empty()):
			var startingPathOnSystem: String = "%s/" % thisFile.get_base_dir()
			var startingPathLocal: String = to
			# print(startingPathOnSystem)
			# print(startingPathLocal)

			#start with current path
			var pathsToCreate: PackedStringArray = [thisFile.get_file()]
			while (pathsToCreate.size()>0):
				var curPath: String = pathsToCreate.get(0)
				if(cut):
					dirToDelete.append(curPath)
				pathsToCreate.remove_at(0)

				var pathToMake:String = "%s%s" % [startingPathLocal, curPath]
				var pathOnSystem:String = "%s%s" % [startingPathOnSystem, curPath]
				if(!DirAccess.dir_exists_absolute(pathToMake)):
					DirAccess.make_dir_absolute(pathToMake)

				#check for folders in this new directory, if so grab them and add them to the pathsToCreate array
				var newPathsInThisDir: PackedStringArray = DirAccess.get_directories_at(pathOnSystem)
				if(!newPathsInThisDir.is_empty()):
					for nextPath in newPathsInThisDir:
						var fullNextPath: String = "%s/%s" % [curPath, nextPath.get_file()]
						pathsToCreate.append(fullNextPath)
				
				var filesInThisDir: PackedStringArray = DirAccess.get_files_at(pathOnSystem)
				if(!filesInThisDir.is_empty()):
					for nextFile in filesInThisDir:
						var nextFilePath: String = "%s/%s" % [pathToMake, nextFile.get_file()]
						var nextFilePathOnSystem: String = "%s/%s" % [pathOnSystem, nextFile.get_file()]
						if(override or !FileAccess.file_exists(nextFilePath)):
							if(!cut):
								DirAccess.copy_absolute(nextFilePathOnSystem, nextFilePath)
							else:
								DirAccess.rename_absolute(nextFilePathOnSystem, nextFilePath)
			if(override or !FileAccess.file_exists("%s%s" % [to,filename])):
				if(!cut):
					DirAccess.copy_absolute(thisFile, "%s%s" % [to,filename])
				else:
					DirAccess.rename_absolute(thisFile, "%s%s" % [to,filename])
		else:
			if(override or !FileAccess.file_exists("%s%s" % [to,filename])):
				if(!cut):
					DirAccess.copy_absolute(thisFile, "%s%s" % [to,filename])
				else:
					DirAccess.rename_absolute(thisFile, "%s%s" % [to,filename])
		if(cut):
			dirToDelete.reverse()
			for dir in dirToDelete:
				DirAccess.remove_absolute("%s/%s" % [thisFile.get_base_dir(),dir])
			dirToDelete.clear()
	NotificationManager.ShowNotification("Dropped your files into %s" % to, NotificationManager.E_NOTIFICATION_TYPE.NORMAL, "Added files")
