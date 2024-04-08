extends Control

@export var player1: Button
@export var player2: Button

var _active: bool = true

func _ready():
	player1.get_node("Sfx")._init_sfx(1)
	player2.get_node("Sfx")._init_sfx(2)

func _process(_delta):
	if _active:
		if player1.active and player2.active:
			SceneManager.change_scene("res://scenes/game.tscn", .5)
			_active = false
