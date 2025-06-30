extends Area2D

@onready var anim : AnimatedSprite2D = $DoorSprite
@onready var PopUp : CanvasLayer = $"PopUp"
var is_active : bool = false
var player
var is_opened : bool = false

func _process(_delta):
	if !UnderworldGlobal.has_save_file:
		anim.play("closed_key")
	else:
		anim.play("closed_no_key")
	if Input.is_action_just_pressed("Interact") && is_active:
		if !is_opened:
			if !UnderworldGlobal.has_save_file:
					PopUp.set_visible(true)
			else:
				anim.play("opened")
				is_opened = true
		elif is_opened:
			UnderworldGlobal.load_scene(UnderworldGlobal.max_level, true)
			$Game_Start_Audio.play()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		is_active = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		is_active = false
		player = null
		PopUp.set_visible(false)

func _on_button_pressed():
	PopUp.set_visible(false)
