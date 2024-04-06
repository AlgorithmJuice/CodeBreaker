extends Control

@export var player1: Button
@export var player2: Button

func _ready():
	player1.get_node("Sfx")._init_sfx(1)
	player2.get_node("Sfx")._init_sfx(2)

func _process(_delta):
	if player1.active and player2.active:
		SceneManager.change_scene("res://scenes/game.tscn")
