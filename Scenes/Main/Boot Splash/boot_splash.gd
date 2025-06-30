extends CanvasLayer
class_name BootSplash

## The boot splash animation that's shown when GodotOS is opened or powered off.
## It uses a CanvasGroup with 2D nodes for masking, hence why it adjusts scale manually.

@export var quit_animation: bool
@export var bootBackground: Sprite2D
@export var bootImage: Sprite2D
@export var bootImageShadow: Sprite2D
@export var timeLength: float = 0.5
@export var scaleAmount: Vector2 = Vector2(2,2)

func _ready() -> void:
	visible = true
	scale /= get_window().content_scale_factor
	if quit_animation:
		play_quit_animation()
	else:
		play_animation()

func play_animation() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.set_parallel(true)
	tween.tween_property(bootImageShadow, "scale", scaleAmount, timeLength)
	tween.tween_property(bootImage, "scale", scaleAmount, timeLength)
	
	tween.tween_property(bootImageShadow, "self_modulate:a", 0, timeLength)
	
	await get_tree().create_timer(timeLength).timeout
	queue_free()

func play_quit_animation() -> void:
	#Start scaled to max, go to 1
	bootImageShadow.scale = scaleAmount
	bootImageShadow.self_modulate.a = 0
	bootImage.scale = scaleAmount
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.set_parallel(true)
	tween.tween_property(bootImageShadow, "scale", Vector2(1, 1), 2)
	tween.tween_property(bootImage, "scale", Vector2(1, 1), timeLength/2)
	
	await get_tree().create_timer(timeLength/2).timeout
	
	var tween2: Tween = create_tween()
	tween2.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(bootImageShadow, "self_modulate:a", 1, timeLength/2)
	
	await get_tree().create_timer(timeLength/2).timeout
	get_tree().quit()

func _physics_process(_delta: float) -> void:
	var window_size: Vector2 = DisplayServer.window_get_size() as Vector2
	bootBackground.scale = window_size
	bootBackground.global_position = window_size / 2
	bootImage.global_position = window_size / 2
	bootImageShadow.global_position = window_size / 2
