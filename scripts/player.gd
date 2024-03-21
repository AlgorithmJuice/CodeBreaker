class_name Player
extends Node


@export var id: int
@export var passphrase: Node
@export var timer: Node
@export var matrix: Node

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

func init():
	_init_passphrase()
	_init_timer()
	_init_matrix()

func _process(_delta):
	_on_input_joystick()
	_on_input_gamepad()
	_on_timer_timeout()

func _init_passphrase():
	passphrase.words = correct_passphrase
	passphrase.current_round = current_round
	passphrase.display()

func _init_timer():
	timer.init_time = round_time
	timer.start()
	
func _init_matrix():
	matrix.reset(current_wordlist)

func _on_input_joystick():
	if Input.is_action_just_pressed("bgs_right_p%d" % id):
		matrix.set_selected_index([1, 0])
	if Input.is_action_just_pressed("bgs_left_p%d" % id):
		matrix.set_selected_index([-1, 0])
	if Input.is_action_just_pressed("bgs_down_p%d" % id):
		matrix.set_selected_index([0, 1])
	if Input.is_action_just_pressed("bgs_up_p%d" % id):
		matrix.set_selected_index([0, -1])

func _on_input_gamepad():
	if Input.is_action_just_pressed("bgs_a_p%d" % id):
		var word = matrix.selected_word
		
		if word == current_password:
			_handle_correct_word()
		elif _is_leet(word):
			_handle_leet_word()
		else:
			_handle_wrong_word(word)

func _on_timer_timeout():
	# TODO: Fix timer timeout by penalty.
	
	if timer.time_left <= 0:
		matrix.reset(current_wordlist)
		
		timer.wait_time = round_time
		timer.start()

func _handle_correct_word():
	current_round += 1
	
	if current_round == total_rounds:
		get_tree().change_scene_to_file("res://scenes/final.tscn")
	else:
		matrix.reset(current_wordlist)
		passphrase.current_round = current_round
		timer.reset()

func _handle_leet_word():
	print("leet word") # TODO: Perform hacks!
	
func _handle_wrong_word(word):
	var found_chars = _compare_characters(word, current_password)
	matrix.add_known_chars(found_chars)
	
	timer.time_left -= time_penalty

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
