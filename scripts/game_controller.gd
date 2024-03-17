extends Node


@export var num_words: int
@export var num_leet: int
@export var round_time: float
@export var time_penalty: int

var passphrase: Array = []
var words: Array = []
var focused_index: int = 0
var discovered_letters: Array = []
var current_round: int = 0
var total_rounds: int = 0
var passphrase_label: Label = null
var current_password: String:
	get: 
		return passphrase[current_round] if (current_round >= 0 and current_round < total_rounds) else ""
var countdown_label: Label = null
var countdown_timer: Timer = null
var matrix_container: GridContainer = null
var word_root: PackedScene = null
var theme_highlight: Theme = null

func _ready():
	word_root = preload("res://nodes/word.tscn")
	theme_highlight = preload("res://themes/highlight.tres")
	passphrase = get_passphrase()
	total_rounds = passphrase.size()
	words = get_words()
	
	init_passphrase()
	init_countdown()
	init_matrix()

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
	if current_round == total_rounds:
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
	var selected_words = []
	var total_words = num_words - (num_leet + 1) # Exclude leets words and correct word.
	var word_length = str(current_password.length())
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

func add_pass_word(text):
	var instance = word_root.instantiate()
	instance.text = text
	matrix_container.add_child(instance)
	
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
	#no need to differentiate password/leetword/regular words
	#correct word is public variable for checks
	#leet words will always contain numbers to check for
	
	#add passcode word
	#add leet words
	#add remaining words based on total words - (leet words + password)
	add_pass_word(current_password)
	for word in words: add_pass_word(word)
	for leet in get_leets(): add_pass_word(leet)
	
	#shuffle
	shuffle_matrix()
	#set default focus
	#set_default_matrix_focus()
	set_cursor_position(0)

func init_matrix():
	matrix_container = $MarginContainer/VerticalContainer/MatrixContainer
	
	clear_matrix()
	display_matrix()
	
func set_cursor_position(index):
	#un-highlight word at focused index
	update_theme(matrix_container.get_child(focused_index),null)
	focused_index = index
	update_theme(matrix_container.get_child(focused_index),theme_highlight)
	#highlight word at focused index

func update_theme(node, theme):
	node.set_theme(theme)

func on_joystick():
	#original parameter pass: ("bgs_right_p%d" % player)
	#This is hecking fast
	var new_index = focused_index
	if Input.is_action_just_pressed("bgs_right_p1"):
		new_index += 1
	if Input.is_action_just_pressed("bgs_left_p1"):
		new_index -= 1
	if Input.is_action_just_pressed("bgs_down_p1"):
		new_index += matrix_container.columns
	if Input.is_action_just_pressed("bgs_up_p1"):
		new_index -= matrix_container.columns
	
	#handle out of bounds case
	if new_index != focused_index:
		set_cursor_position(new_index)

func on_gamepad_button():
	if Input.is_action_just_pressed("bgs_a_p1"):
		var container = matrix_container.get_child(focused_index)
		var selected_word = container.text
		var regex = RegEx.new()
		regex.compile("\\d")
		
		if selected_word == current_password:
			_on_passcode_pressed()
		elif regex.search(selected_word):
			_on_leet_pressed()
		else:
			_on_word_pressed(selected_word)


