extends TextureRect

## The image viewer window.
@export var parentWindow: FakeWindow

func _ready() -> void:
	if(parentWindow.creationData.has("Filename")):
		import_image(parentWindow.creationData["Filename"])
		# parentWindow.titleText.text = parentWindow.creationData["Filename"]


func import_image(file_path: String) -> void:
	if !FileAccess.file_exists("user://files/%s" % file_path):
		NotificationManager.spawn_notification("Error: Cannot find file (was it moved or deleted?)")
		return
	var image: Image = Image.load_from_file("user://files/%s" % file_path)
	image.generate_mipmaps()
	var texture_import: ImageTexture = ImageTexture.create_from_image(image)
	texture = texture_import
