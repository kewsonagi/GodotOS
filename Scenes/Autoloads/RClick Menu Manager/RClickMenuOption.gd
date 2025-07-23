extends Panel
class_name RClickMenuOption

@export var optionText: RichTextLabel
@export var optionIcon: TextureRect

signal option_clicked()

func _on_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate:a", 1, 0.2)

func _on_mouse_exited() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate:a", 0.2, 0.2)

func _on_button_pressed() -> void:
	option_clicked.emit()