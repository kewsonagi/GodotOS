extends Node2D

class_name BootGame

@export var mainGameScene: PackedScene
var spawnedWindow: Node = null
@export var gameData: Dictionary = {}

func _ready() -> void:
	StartGame()

func StartGame() -> void:
	if(!spawnedWindow):
		spawnedWindow = DefaultValues.spawn_game_window(mainGameScene.resource_path, "","", gameData,null)
	
func getStartScene() -> Node:
	return spawnedWindow
