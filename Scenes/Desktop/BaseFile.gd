extends Control
class_name BaseFile

## A folder that can be opened and interacted with.
## Files like text/image files are just folders with a different file_type_enum.

enum E_FILE_TYPE {FOLDER, TEXT_FILE, IMAGE, UNKNOWN}
@export var eFileType: E_FILE_TYPE

@export var fileIcon: Texture2D
@export var fileColor: Color = Color("4efa82")

var szFileName: String
var szFilePath: String # Relative to user://files/

var bMouseOver: bool

@export var hoverHighlightControl: Control
@export var selectedHighlightControl: Control
@export var fileTexture: TextureRect
@export var doubleClickTimer: Timer
@export var titleEditBox: TextEdit
@export var fileTitleControl: RichTextLabel


func _ready() -> void:
	hoverHighlightControl.self_modulate.a = 0
	selectedHighlightControl.visible = false
	fileTitleControl.text = "[center]%s" % szFileName
	
	fileTexture.modulate = fileColor
	fileTexture.texture = fileIcon

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"LeftClick"):
		if !bMouseOver:
			hide_selected_highlight()
		else:
			show_selected_highlight()
			if !bMouseOver or event.button_index != 1:
				return
			
			if doubleClickTimer.is_stopped():
				doubleClickTimer.start()
			else:
				accept_event()
				OpenFile()
	if selectedHighlightControl.visible and !titleEditBox.visible:
		if event.is_action_pressed("delete"):
			DeleteFile()
		elif event.is_action_pressed("ui_copy"):
			CopyPasteManager.copy_file(self)
		elif event.is_action_pressed("ui_cut"):
			CopyPasteManager.cut_file(self)
		
		if event.is_action_pressed("ui_up"):
			accept_event()
			get_parent().select_folder_up(self)
		elif event.is_action_pressed("ui_down"):
			accept_event()
			get_parent().select_folder_down(self)
		elif event.is_action_pressed("ui_left"):
			accept_event()
			get_parent().select_folder_left(self)
		elif event.is_action_pressed("ui_right"):
			accept_event()
			get_parent().select_folder_right(self)
		elif event.is_action_pressed("ui_accept"):
			accept_event()
			# open_folder()
			OpenFile()

func _on_mouse_entered() -> void:
	show_hover_highlight()
	bMouseOver = true

func _on_mouse_exited() -> void:
	hide_hover_highlight()
	bMouseOver = false

func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(fileTexture.get_parent().duplicate())
	return self

# ------

func show_hover_highlight() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(hoverHighlightControl, "self_modulate:a", 1, 0.25).from(0.1)

func hide_hover_highlight() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(hoverHighlightControl, "self_modulate:a", 0, 0.25)

func show_selected_highlight() -> void:
	selectedHighlightControl.visible = true

func hide_selected_highlight() -> void:
	selectedHighlightControl.visible = false

func delete_file() -> void:
	if eFileType == E_FILE_TYPE.FOLDER:
		var delete_path: String = ProjectSettings.globalize_path("user://files/%s" % szFilePath)
		if !DirAccess.dir_exists_absolute(delete_path):
			return
		OS.move_to_trash(delete_path)
		#looking for a file manager currently open with the deleted folder
		#if found, close it
		for file_manager: FileManagerWindow in get_tree().get_nodes_in_group("file_manager_window"):
			if file_manager.file_path.begins_with(szFilePath):
				file_manager.close_window()
			elif get_parent() is FileManagerWindow and file_manager.file_path == get_parent().file_path:
				file_manager.delete_file_with_name(szFileName)
				file_manager.update_positions()
	else:
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
	NotificationManager.ShowNotification("Moved [color=59ea90][wave freq=7]%s[/wave][/color] to trash!" % szFileName)
	queue_free()

func OpenFile() -> void:
	var filePath: String = ProjectSettings.globalize_path("user://files/%s/%s" % [szFilePath, szFileName])
	OS.shell_open(filePath)
	return
func DeleteFile() -> void:
	delete_file()
	return
