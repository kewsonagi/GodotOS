# extends Control
# class_name FakeFolder

# ## A folder that can be opened and interacted with.
# ## Files like text/image files are just folders with a different file_type_enum.

# enum file_type_enum {FOLDER, TEXT_FILE, IMAGE}
# @export var file_type: file_type_enum

# @export var folderIcon: Texture2D
# @export var photoViewerIcon: Texture2D
# @export var textEditIcon: Texture2D
# @export var FOLDER_COLOR: Color = Color("4efa82")
# @export var TEXT_FILE_COLOR: Color = Color("4deff5")
# @export var IMAGE_COLOR: Color = Color("f9ee13")

# var folder_name: String
# var folder_path: String # Relative to user://files/

# var is_mouse_over: bool

# func _ready() -> void:
# 	$"Hover Highlight".self_modulate.a = 0
# 	$"Selected Highlight".visible = false
# 	%"Folder Title".text = "[center]%s" % folder_name
	
# 	if file_type == file_type_enum.FOLDER:
# 		$Folder/TextureRect.modulate = FOLDER_COLOR
# 		$Folder/TextureRect.texture = folderIcon
# 	elif file_type == file_type_enum.TEXT_FILE:
# 		$Folder/TextureRect.modulate = TEXT_FILE_COLOR
# 		$Folder/TextureRect.texture = textEditIcon
# 	elif file_type == file_type_enum.IMAGE:
# 		$Folder/TextureRect.modulate = IMAGE_COLOR
# 		$Folder/TextureRect.texture = photoViewerIcon

# func _input(event: InputEvent) -> void:
# 	if event is InputEventMouseButton and event.is_pressed():
# 		if !is_mouse_over:
# 			hide_selected_highlight()
# 		else:
# 			show_selected_highlight()
# 			if !is_mouse_over or event.button_index != 1:
# 				return
			
# 			if $"Double Click".is_stopped():
# 				$"Double Click".start()
# 			else:
# 				accept_event()
# 				open_folder()
# 	if $"Selected Highlight".visible and !$"Control/Title Edit Container".visible:
# 		if event.is_action_pressed("delete"):
# 			delete_file()
# 		elif event.is_action_pressed("ui_copy"):
# 			CopyPasteManager.copy_folder(self)
# 		elif event.is_action_pressed("ui_cut"):
# 			CopyPasteManager.cut_folder(self)
		
# 		if event.is_action_pressed("ui_up"):
# 			accept_event()
# 			get_parent().select_folder_up(self)
# 		elif event.is_action_pressed("ui_down"):
# 			accept_event()
# 			get_parent().select_folder_down(self)
# 		elif event.is_action_pressed("ui_left"):
# 			accept_event()
# 			get_parent().select_folder_left(self)
# 		elif event.is_action_pressed("ui_right"):
# 			accept_event()
# 			get_parent().select_folder_right(self)
# 		elif event.is_action_pressed("ui_accept"):
# 			accept_event()
# 			open_folder()

# func _on_mouse_entered() -> void:
# 	show_hover_highlight()
# 	is_mouse_over = true

# func _on_mouse_exited() -> void:
# 	hide_hover_highlight()
# 	is_mouse_over = false

# # ------

# func show_hover_highlight() -> void:
# 	var tween: Tween = create_tween()
# 	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
# 	tween.tween_property($"Hover Highlight", "self_modulate:a", 1, 0.25).from(0.1)

# func hide_hover_highlight() -> void:
# 	var tween: Tween = create_tween()
# 	tween.set_trans(Tween.TRANS_CUBIC)
# 	tween.tween_property($"Hover Highlight", "self_modulate:a", 0, 0.25)

# func show_selected_highlight() -> void:
# 	$"Selected Highlight".visible = true

# func hide_selected_highlight() -> void:
# 	$"Selected Highlight".visible = false

# func spawn_window() -> void:
# 	var window: FakeWindow
	
# 	var windowName:String=folder_path
# 	var windowID:String="%s/%s" % [folder_path, folder_name]
# 	var windowParent:Node=get_tree().current_scene
# 	var windowData: Dictionary = {}

# 	var filename: String = folder_name;
# 	if(!folder_path.is_empty()):
# 		filename = "%s/%s" % [folder_path, folder_name]
	
# 	if file_type == file_type_enum.FOLDER:
# 		windowData["StartPath"] = folder_path;
		
# 		window = DefaultValues.spawn_window("res://Scenes/Window/File Manager/file_manager_window.tscn", windowName, windowID, windowData,windowParent)
# 	elif file_type == file_type_enum.TEXT_FILE:
# 		windowData["Filename"] = filename;
		
# 		window = DefaultValues.spawn_window("res://Scenes/Window/Text Editor/text_editor.tscn", windowName, windowID, windowData, windowParent)
# 	elif file_type == file_type_enum.IMAGE:
# 		windowData["Filename"] = filename;

# 		window = DefaultValues.spawn_window("res://Scenes/Window/Image Viewer/image_viewer.tscn", windowName, windowID, windowData, windowParent)
	
# 	window.title_text = windowName#%"Folder Title".text
	
# 	var taskColor: Color = FOLDER_COLOR;
	
# 	if file_type == file_type_enum.FOLDER:
# 		taskColor = FOLDER_COLOR
# 	if file_type == file_type_enum.TEXT_FILE:
# 		taskColor = TEXT_FILE_COLOR
# 	elif file_type == file_type_enum.IMAGE:
# 		taskColor = IMAGE_COLOR
	
# 	DefaultValues.AddWindowToTaskbar(window, taskColor, $Folder/TextureRect.texture)

# func delete_file() -> void:
# 	if file_type == file_type_enum.FOLDER:
# 		var delete_path: String = ProjectSettings.globalize_path("user://files/%s" % folder_path)
# 		if !DirAccess.dir_exists_absolute(delete_path):
# 			return
# 		OS.move_to_trash(delete_path)
# 		#looking for a file manager currently open with the deleted folder
# 		#if found, close it
# 		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
# 			if file_manager.file_path.begins_with(folder_path):
# 				file_manager.close_window()
# 			elif get_parent() is FileManagerWindow and file_manager.file_path == get_parent().file_path:
# 				file_manager.delete_file_with_name(folder_name)
# 				file_manager.update_positions()
# 	else:
# 		var delete_path: String = ProjectSettings.globalize_path("user://files/%s/%s" % [folder_path, folder_name])
# 		if !FileAccess.file_exists(delete_path):
# 			return
# 		OS.move_to_trash(delete_path)
# 		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
# 			if file_manager.file_path == folder_path:
# 				file_manager.delete_file_with_name(folder_name)
# 				file_manager.sort_folders()
	
# 	if folder_path.is_empty() or (file_type == file_type_enum.FOLDER and len(folder_path.split('/')) == 1):
# 		var desktop_file_manager: DesktopFileManager = get_tree().get_first_node_in_group("desktop_file_manager")
# 		desktop_file_manager.delete_file_with_name(folder_name)
# 		desktop_file_manager.sort_folders()
# 	# TODO make the color file_type dependent?
# 	NotificationManager.spawn_notification("Moved [color=59ea90][wave freq=7]%s[/wave][/color] to trash!" % folder_name)
# 	queue_free()

# func open_folder() -> void:
# 	hide_selected_highlight()
# 	if get_parent().is_in_group("file_manager_window") and file_type == file_type_enum.FOLDER:
# 		get_parent().reload_window(folder_path)
# 	else:
# 		spawn_window()
