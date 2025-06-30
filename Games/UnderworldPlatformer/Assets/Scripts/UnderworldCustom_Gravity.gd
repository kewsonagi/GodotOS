extends RigidBody2D

# Custom gravity scale (if you want to adjust gravity for this specific object)
var gravity
@export var can_be_pushed : bool = false
var player : CharacterBody2D

@export_category("Gravity")
@export var affected_by_custom_gravity : bool = true
@export var custom_gravity_scale : float = 0.5
@export var invert_gravity : bool = false
@export var horizontal_gravity : bool = false

@export_category("Change Every Second")
@export var time_change : bool = false
@export var time : float = 2

@onready var timer = $Timer
@onready var anim = $AnimationPlayer

func _ready():
	player = UnderworldGlobal.PLAYER
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * (-1 if invert_gravity else 1)
	timer.wait_time = time
	if time_change && affected_by_custom_gravity:
		timer.start()

func is_pushed():
	global_position.x += player.direction_x

func _physics_process(delta):
	# Get the default gravity from project settings
	if affected_by_custom_gravity:
		if !time_change:
			gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * (-1 if invert_gravity else 1)
		else:
			if timer.time_left < 0.75:
				anim.play("shake")

	if !horizontal_gravity:
		linear_velocity.y += gravity * custom_gravity_scale * delta
	else:
		linear_velocity.x += gravity * custom_gravity_scale * delta

func _on_timer_timeout():
	gravity *= -1

func _on_body_entered(body):
	if !body.is_in_group("Player"):
		$AudioStreamPlayer2D.play()
