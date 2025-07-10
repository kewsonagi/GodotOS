extends Control
# class_name NotificationManager
## Spawns notifications in the bottom right of the screen.
## Often used to show errors or file actions (copying, pasting).

@export var defaultNotification: PackedScene# = preload("res://Scenes/Autoloads/Notification Manager/notification.tscn")

func ShowNotification(text: String) -> Control:
	return ShowNotificationCustom(defaultNotification, text)

func ShowNotificationCustom(notiScene: PackedScene, defaultText: String) -> Control:
	var thisNotification: Notification = notiScene.instantiate()
	if(thisNotification):
		thisNotification.SetNotificationText(defaultText)
	add_child(thisNotification)
	return thisNotification
