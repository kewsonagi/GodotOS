extends Control

## A window's taskbar button. Used to minimize/restore a window.
## Also shows which window is selected or minimized via colors.

@export var texture_rect: TextureRect# = $"TextureMargin/TextureRect"
@export var selected_background: TextureRect# = $SelectedBackground
@export var hoverPreviewTexture: TextureRect
var storeOldTextureRect: Texture
@export var previewNode: Control

var target_window: FakeWindow

@export var active_color: Color = Color("6de700")
@export var disabled_color: Color = Color("908a8c")

func _ready() -> void:
	target_window.minimized.connect(_on_window_minimized)
	target_window.deleted.connect(_on_window_deleted)
	target_window.selected.connect(_on_window_selected)
	texture_rect.self_modulate = active_color
	storeOldTextureRect = texture_rect.texture

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"LeftClick"):
		if target_window.is_minimized:
			target_window.show_window()
		else:
			if(target_window.is_selected):
				target_window.hide_window()
			else:
				target_window.select_window(true)

func _on_mouse_entered() -> void:
	TweenAnimator.float_bob(self, 6, .4)#(self, 1.3, 0.2)

	TweenAnimator.fade_in(previewNode, 0.3)
	previewNode.visible = true;

	if(!target_window.is_minimized):
		hoverPreviewTexture.texture = target_window.previewCaptureViewport.get_viewport().get_texture()

func _on_mouse_exited() -> void:
	print("mouse exit")
	TweenAnimator.float_bob(self, 6, .4)#(self, 1.3, 0.2)
	TweenAnimator.fade_out(previewNode, 0.3)
	previewNode.visible = false;

func _on_window_minimized(is_minimized: bool) -> void:
	hoverPreviewTexture.texture = target_window.previewCaptureViewport.get_viewport().get_texture()

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if is_minimized:
		tween.tween_property(texture_rect, "self_modulate", disabled_color, 0.25)
	else:
		tween.tween_property(texture_rect, "self_modulate", active_color, 0.25)

func _on_window_deleted(window: FakeWindow) -> void:
	queue_free()

func _on_window_selected(selected: bool) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	if selected:
		tween.tween_property(selected_background, "self_modulate:a", 1, 0.25)
	else:
		tween.tween_property(selected_background, "self_modulate:a", 0, 0.25)
