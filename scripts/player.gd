class_name Player
extends Node


@export var id: int
@export var passphrase: Node
@export var timer: Node
@export var matrix: Node
@export var sfx_player: Node

var correct_passphrase: Array = []
var wordlists: Array = []
var current_round: int = 0
var round_time: int = 0
var time_penalty: int = 0
var current_password: String:
	get: return correct_passphrase[current_round]
var current_wordlist: Array:
	get: return wordlists[current_round]
var total_rounds: int:
	get: return correct_passphrase.size()

var move_delay = 0.5
var move_repeat_rate = 0.09
var move_timer = 0.0
var last_direction = Vector2.ZERO

signal timer_out
signal wrong_word
signal correct_word

func init():
	_init_passphrase()
	_init_timer()
	_init_matrix()
	_init_sfx_player()

func _process(delta):
	_on_input_joystick(delta)
	_on_input_gamepad()

func _init_passphrase():
	passphrase.words = correct_passphrase
	passphrase.current_round = current_round
	passphrase.display()

func _init_timer():
	timer.find_child("CountdownTimer").timeout.connect(_on_timer_timeout)
	timer.init_time = round_time
	timer.start()
	
func _init_matrix():
	matrix.words = current_wordlist
	matrix.reset()
	
func _init_sfx_player():
	matrix.selection_change.connect(sfx_player._on_matrix_selection_change)
	sfx_player._init_sfx(id)

func _on_input_joystick(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("bgs_right_p%d" % id):
		direction = Vector2.RIGHT
	elif Input.is_action_pressed("bgs_left_p%d" % id):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("bgs_down_p%d" % id):
		direction = Vector2.DOWN
	elif Input.is_action_pressed("bgs_up_p%d" % id):
		direction = Vector2.UP

	if direction != Vector2.ZERO:
		if direction != last_direction or move_timer <= 0.0:
			matrix.set_selected_index(direction)
			last_direction = direction 
			move_timer = move_delay 
		else:
			move_timer -= delta
	else:
		last_direction = Vector2.ZERO 
		move_timer = 0.0 

	if move_timer < 0.0:
		move_timer += move_repeat_rate
		matrix.set_selected_index(last_direction)

func _on_input_gamepad():
	if Input.is_action_just_pressed("bgs_a_p%d" % id):
		var word = matrix.selected_word.word
		
		if word == current_password:
			_handle_correct_word()
		elif _is_leet(word):
			_handle_leet_word()
		else:
			_handle_wrong_word(word)

func _on_timer_timeout():
	# TODO: Fix timer timeout by penalty.
	matrix.reset()
	timer_out.emit()
	timer.stop()
	timer.wait_time = round_time
	timer.start()

func _handle_correct_word():
	current_round += 1
	
	if current_round == total_rounds:
		GameStats.winner = id
		GameStats.stop_timestamp = Time.get_unix_time_from_system()
		
		SceneManager.change_scene("res://scenes/game_over.tscn")
	else:
		correct_word.emit()
		matrix.words = current_wordlist
		matrix.reset()
		passphrase.current_round = current_round
		timer.reset()

func _handle_leet_word():
	print("leet word") # TODO: Perform hacks!
	
func _handle_wrong_word(word):
	var found_chars = _compare_characters(word, current_password)
	wrong_word.emit()
	matrix.add_known_chars(found_chars)
	matrix.add_inactive_word(word)
	
	timer.time_left = timer.time_left - time_penalty

func _is_leet(word):
	var regex = RegEx.new()
	regex.compile("[@$0-9]")
	
	return regex.search(word)
	
func _compare_characters(word1, word2):
	var characters = []
	
	for character in word1:
		if word2.find(character) != -1 and character not in characters:
			characters.append(character)
			
	return characters
