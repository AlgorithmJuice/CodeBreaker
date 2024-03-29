extends Control

@export var stat_winner: Label
@export var stat_passphrase: Label
@export var stat_time: Label
@export var player1: Button
@export var player2: Button

signal final_start

func _ready():	
	final_start.connect(Music._on_menu_start)
	final_start.emit()
	stat_winner.text = _format_winner(GameStats.winner)
	stat_passphrase.text = _format_passphrase(GameStats.passphrase)
	stat_time.text = _format_elapsed_time(GameStats.start_timestamp, GameStats.stop_timestamp)

func _process(_delta):
	if player1.active and player2.active:
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _format_winner(winner):
	return "Player %s" % winner

func _format_passphrase(passphrase):
	return " ".join(passphrase)

func _format_elapsed_time(start_time, stop_time):
	var elapsed_seconds = stop_time - start_time
	
	var minutes = int(elapsed_seconds / 60)
	var seconds = int(elapsed_seconds) % 60
	
	return "%02dm %02ds" % [minutes, seconds]
