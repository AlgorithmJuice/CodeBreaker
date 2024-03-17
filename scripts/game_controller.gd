extends Node


@export var num_words: int
@export var num_leet: int
@export var round_time: float
@export var time_penalty: int

var passphrase: Array = []
var words: Array = []
var discovered_letters: Array = []
var current_round: int = 0
var total_rounds: int = 0
var passphrase_label: Label = null
var countdown_label: Label = null
var countdown_timer: Timer = null
var matrix_container: GridContainer = null

func _ready():
	passphrase = get_passphrase()
	words = get_words()
	total_rounds = passphrase.size()
	
	init_passphrase()
	init_countdown()
	init_matrix()

func _process(_delta):
	countdown_label.text = display_countdown()

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
	print(discovered_letters)

	countdown_timer.stop()

	if wait_time <= 0.0:
		countdown_timer.wait_time = round_time
		_on_countdown_timer_timeout()
	else:
		countdown_timer.wait_time = wait_time
		
	countdown_timer.start()

func _on_passcode_pressed():
	current_round += 1
	win_condition_check()
	
	words = get_words()
	
	countdown_timer.stop()
	countdown_timer.wait_time = round_time
	countdown_timer.start()
	
	clear_discovered_letters()
	clear_matrix()
	display_matrix()

func win_condition_check():
	if current_round == (total_rounds - 1):
		get_tree().change_scene_to_file("res://scenes/final.tscn")
	return

func _on_leet_pressed():
	print("leet!")

func get_passphrase():
	var phrase = GameData.phrases[randi() % GameData.phrases.size()]	
	return phrase.split(" ")

func display_passphrase():
	var cracked_passphrase = ""
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	for i in range(passphrase.size()):
		var word = passphrase[i]
		
		if i < current_round:
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
	print(passphrase[current_round])
	var selected_words = []
	var total_words = num_words - (num_leet + 1) # Exclude leets words and correct word.
	var word_length = str(passphrase[current_round].length())
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
	var length = str(passphrase[current_round].length())
	
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
	
	matrix_container.add_child(instance)

func set_default_matrix_focus():
	matrix_container.get_child(0).get_node("PasscodeButton").grab_focus()
	
func shuffle_matrix():
	var children = matrix_container.get_children()
	children.shuffle()
	
	for child in children:
		matrix_container.remove_child(child)
		matrix_container.add_child(child)

func add_discovered_letters(word):
	var active_word = passphrase[current_round]
	for character in word:
		if character in active_word and character not in discovered_letters:
			discovered_letters.append(character)

func clear_discovered_letters():
	discovered_letters = []

func clear_matrix():	
	for child in matrix_container.get_children():
		matrix_container.remove_child(child)
		child.queue_free()

func display_matrix():
	var password_button_root = preload("res://nodes/passcode_button.tscn")
	var leet_button_root = preload("res://nodes/leet_button.tscn")
	
	add_passcode_button(password_button_root, passphrase[current_round], _on_passcode_pressed)
	for word in words: add_passcode_button(password_button_root, word, _on_word_pressed.bind(word))
	for leet in get_leets(): add_passcode_button(leet_button_root, leet, _on_passcode_pressed)
		
	shuffle_matrix()
	set_default_matrix_focus()

func init_matrix():
	matrix_container = $MarginContainer/VerticalContainer/MatrixContainer
	
	clear_matrix()
	display_matrix()
