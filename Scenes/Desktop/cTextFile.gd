extends BaseFile
class_name cTextFile

func _ready() -> void:
	super._ready()

func OpenFile() -> void:
	var window: FakeWindow
	
	var windowName:String=szFilePath
	var windowID:String="%s/%s" % [szFilePath, szFileName]
	var windowParent:Node=get_tree().current_scene
	var windowData: Dictionary = {}

	var filename: String = szFileName;
	if(!szFilePath.is_empty()):
		filename = "%s/%s" % [szFilePath, szFileName]
	
	windowData["Filename"] = filename;
	window = DefaultValues.spawn_window("res://Scenes/Window/Text Editor/text_editor.tscn", windowName, windowID, windowData, windowParent)
	window.title_text = windowName#%"Folder Title".text
	
	DefaultValues.AddWindowToTaskbar(window, fileColor, $Folder/TextureRect.texture)
	return
	
func DeleteFile() -> void:
	var delete_path: String = ProjectSettings.globalize_path("user://files/%s/%s" % [szFilePath, szFileName])
	if !FileAccess.file_exists(delete_path):
		return
	OS.move_to_trash(delete_path)
	for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
		if file_manager.file_path == szFilePath:
			file_manager.delete_file_with_name(szFileName)
			file_manager.sort_folders()

	if szFilePath.is_empty() or (eFileType == E_FILE_TYPE.FOLDER and len(szFilePath.split('/')) == 1):
		var desktop_file_manager: DesktopFileManager = get_tree().get_first_node_in_group("desktop_file_manager")
		desktop_file_manager.delete_file_with_name(szFileName)
		desktop_file_manager.sort_folders()
	# TODO make the color file_type dependent?
	NotificationManager.spawn_notification("Moved [color=59ea90][wave freq=7]%s[/wave][/color] to trash!" % szFileName)
	queue_free()