extends Panel
class_name Notification

@export var mainText: RichTextLabel
@export var title: RichTextLabel
@export var background: Panel
@export var defaultDuration: float = 5.0

func SetNotificationText(text: String) -> void:
	mainText.text = text
func SetNotificationTitle(text: String) -> void:
	title.text = text

func _ready() -> void:
	# adjust_width()
	play_animation(defaultDuration)

func adjust_width() -> void:
	while true:
		if mainText.get_line_count() > 1:
			size.x += 20
			position.x -= 20
		else:
			size.x += 10
			position.x -= 10
			return

func play_animation(duration: float=5) -> void:
	TweenAnimator.punch_in(self, 0.3)
	await get_tree().create_timer(duration-1).timeout
	TweenAnimator.fade_out(self, 0.5)
	await get_tree().create_timer(0.5).timeout
	# var tween: Tween = create_tween()
	# tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	# tween.tween_property(self, "position:y", position.y - 75, duration)
	
	# await get_tree().create_timer(2).timeout
	# var fade: Tween = create_tween()
	# fade.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	# await fade.tween_property(mainText, "modulate:a", 0, duration/3).finished
	queue_free()
