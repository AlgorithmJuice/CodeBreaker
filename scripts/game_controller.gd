extends Node


@export var num_words: int
@export var num_leet: int
@export var round_time: float
@export var time_penalty: int

var passphrase: Array = []
var words: Array = []
#var focused_index: int = 0
#var discovered_letters: Array = []
var current_round_player_1: int = 0
var current_round_player_2: int = 0
var total_rounds: int = 0
var passphrase_label: Label = null

var current_password_player_1: String:
	get: 
		return passphrase[current_round_player_1] if (current_round_player_1 >= 0 and current_round_player_1 < total_rounds) else ""
var current_password_player_2: String:
	get: 
		return passphrase[current_round_player_2] if (current_round_player_2 >= 0 and current_round_player_2 < total_rounds) else ""

var countdown_label: Label = null
var countdown_timer: Timer = null
var matrix_container_1: GridContainer = null
var matrix_container_2: GridContainer = null
#var word_root: PackedScene = null
#var theme_highlight: Theme = null

func _ready():
	passphrase = get_passphrase()
	total_rounds = passphrase.size()
	words = get_words()
	
	init_passphrase()
	init_countdown()
	matrix_container_root = preload("res://nodes/matrix_container.tscn")
	#instantiate two matrices

func _process(_delta):
	countdown_label.text = display_countdown()
	on_joystick()
	on_gamepad_button()

func _on_passphrase_timer_timeout():
	passphrase_label.text = display_passphrase()

func _on_countdown_timer_timeout():
	countdown_timer.wait_time = round_time
	clear_discovered_letters()
	clear_matrix()
	display_matrix()

func _on_word_pressed(word):
	var wait_time = countdown_timer.time_left - time_penalty
	add_discovered_letters(word)

	countdown_timer.stop()

	if wait_time <= 0.0:
		countdown_timer.wait_time = round_time
		_on_countdown_timer_timeout()
	else:
		countdown_timer.wait_time = wait_time
		
	countdown_timer.start()

func _on_passcode_pressed():
	current_round_player_1 += 1
	if win_condition_check():
		return
	
	words = get_words()
	
	countdown_timer.stop()
	countdown_timer.wait_time = round_time
	countdown_timer.start()
	
	clear_discovered_letters()
	clear_matrix()
	display_matrix()

func win_condition_check():
	if current_round_player_1 == total_rounds:
		get_tree().change_scene_to_file("res://scenes/final.tscn")
		return true
	return false

func _on_leet_pressed():
	print("leet!")

func get_passphrase():
	var phrase = GameData.phrases[randi() % GameData.phrases.size()]	
	print(phrase)
	return phrase.split(" ")

func display_passphrase():
	var cracked_passphrase = ""
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	for i in range(passphrase.size()):
		var word = passphrase[i]
		
		if i < current_round_player_1:
			cracked_passphrase += word
		else:
			for c in word:
				var index = randi() % alphabet.length()
				cracked_passphrase += alphabet[index]
			
		cracked_passphrase += " "
	
	return cracked_passphrase.left(-1)

func init_passphrase():
	passphrase_label = $MarginContainer/VerticalContainer/HorizontalContainer/PassphraseLabel
	passphrase_label.text = display_passphrase()

func display_countdown():
	return "%.2f" % countdown_timer.time_left

func init_countdown():
	countdown_label = $MarginContainer/VerticalContainer/HorizontalContainer/CountdownLabel
	countdown_timer = $MarginContainer/VerticalContainer/HorizontalContainer/CountdownLabel/CountdownTimer
	
	countdown_timer.wait_time = round_time
	countdown_timer.start()
	countdown_label.text = display_countdown()

func get_words():
	#split this between initialization and passing to matrix
	var selected_words = []
	var total_words = num_words - (num_leet + 1) # Exclude leets words and correct word.
	var word_length = str(current_password_player_1.length())
	var wordlist = GameData.words[word_length].duplicate()
	
	while selected_words.size() < total_words and wordlist.size() > 0:
		var index = randi() % wordlist.size()
		var word = wordlist[index]
		
		if not passphrase.has(word):
			selected_words.append(word)
			
		wordlist.remove_at(index)
	
	return selected_words

func get_leets():
	var selected_leets = []
	var length = str(current_password_player_1.length())
	
	# Add the leet words.
	var leetlist = GameData.leet[length].duplicate()
	for i in range(num_leet):
		var index = randi() % leetlist.size()
		var leet = leetlist[index]
		
		selected_leets.append(leet)
		leetlist.remove_at(index)
		
	return selected_leets

func add_passcode_button(object, text, signal_connection):
	var instance = object.instantiate()
	var button = instance.get_node("PasscodeButton")
	
	button.text = text
	button.connect("pressed", signal_connection)
	
	matrix_container_1.add_child(instance)
