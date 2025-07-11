extends Panel
class_name Notification

@export var mainText: RichTextLabel
@export var title: RichTextLabel
@export var background: Panel
@export var icon: TextureRect
@export var defaultDuration: float = 5.0

signal Done

func SetNotificationText(text: String) -> void:
	mainText.text = text
func SetNotificationTitle(text: String) -> void:
	title.text = text
func SetNotificationColor(color: Color) -> void:
	background.add_theme_color_override("bg_color", color);

func adjust_width() -> void:
	while true:
		if mainText.get_line_count() > 1:
			size.x += 20
			position.x -= 20
		else:
			size.x += 10
			position.x -= 10
			return

func BeginNoti(duration: float = defaultDuration) -> void:
	TweenAnimator.punch_in(self, 0.3)
	await get_tree().create_timer(duration-1).timeout
	TweenAnimator.fade_out(self, 0.5)
	await get_tree().create_timer(0.5).timeout

	Done.emit(self)
	queue_free()
