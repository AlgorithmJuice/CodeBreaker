extends Control

@export var player1: Button
@export var player2: Button

func _process(_delta):
	if player1.active and player2.active:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
