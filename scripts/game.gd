extends Control


@export var num_words: int
@export var num_leet: int
@export var round_time: float
@export var time_penalty: int

var current_round: int = 0
var total_rounds: int = 0
var passphrase: Array = []
var words: Array = []
var passphrase_node: Node = null
var timer_node: Node = null
var matrix_node: Node = null

var current_password: String:
	get: return _get_current_round()

func _ready():
	passphrase = _get_passphrase()
	total_rounds = passphrase.size()
	words = _get_words()
	passphrase_node = _init_passphrase()
	timer_node = _init_timer()
	matrix_node = _init_matrix()

func _process(_delta):
	_on_input_joystick()
	_on_input_gamepad()
	_on_timer_timeout()

func _on_input_joystick():
	# TODO: Handle input action for all players.
	if Input.is_action_just_pressed("bgs_right_p1"):
		matrix_node.set_selected_index([1, 0])
	if Input.is_action_just_pressed("bgs_left_p1"):
		matrix_node.set_selected_index([-1, 0])
	if Input.is_action_just_pressed("bgs_down_p1"):
		matrix_node.set_selected_index([0, 1])
	if Input.is_action_just_pressed("bgs_up_p1"):
		matrix_node.set_selected_index([0, -1])

func _on_input_gamepad():
	# TODO: Handle input action for all players.
	if Input.is_action_just_pressed("bgs_a_p1"):
		var word = matrix_node.selected_word
		
		if word == current_password:
			_handle_correct_word()
		elif _is_leet(word):
			_handle_leet_word()
		else:
			_handle_wrong_word(word)

func _on_timer_timeout():
	if timer_node.time_left <= 0:
		matrix_node.reset(words + _get_leets() + [current_password])
		
		timer_node.wait_time = round_time
		timer_node.start()

func _get_passphrase():
	var phrase = GameData.phrases[randi() % GameData.phrases.size()]	
	return phrase.split(" ")

func _init_passphrase():
	var tree_passphrase = $MarginContainer/VerticalContainer/HorizontalContainer/Passphrase
	
	tree_passphrase.words = passphrase
	tree_passphrase.current_round = current_round
	tree_passphrase.display()
	
	return tree_passphrase

func _init_timer():
	var tree_timer = $MarginContainer/VerticalContainer/HorizontalContainer/Timer
	
	tree_timer.init_time = round_time
	tree_timer.start()
	
	return tree_timer

func _get_words():
	var selected_words = []
	var total_words = num_words - (num_leet + 1) # Exclude leets words and correct word.
	var wordlist = GameData.words[str(current_password.length())].duplicate()
	
	while selected_words.size() < total_words and wordlist.size() > 0:
		var index = randi() % wordlist.size()
		var word = wordlist[index]
		
		if not passphrase.has(word):
			selected_words.append(word)
			
		wordlist.remove_at(index)
	
	return selected_words

func _get_leets():
	var selected_leets = []
	var leetlist = GameData.leet[str(current_password.length())].duplicate()
	
	# Add the leet words.
	for i in range(num_leet):
		var index = randi() % leetlist.size()
		var leet = leetlist[index]
		
		selected_leets.append(leet)
		leetlist.remove_at(index)
		
	return selected_leets

func _is_leet(word):
	var regex = RegEx.new()
	regex.compile("[@$0-9]")
	
	return regex.search(word)

func _get_current_round():
	if current_round < 0 or current_round > total_rounds:
		return ""
		
	return passphrase[current_round]

func _init_matrix():
	var tree_instance = $MarginContainer/VerticalContainer/Matrix
	tree_instance.reset(words + _get_leets() + [current_password])
	
	return tree_instance

func _compare_characters(word1, word2):
	var characters = []
	
	for char in word1:
		if word2.find(char) != -1 and char not in characters:
			characters.append(char)
			
	return characters

func _handle_correct_word():
	current_round += 1
	
	if current_round == total_rounds:
		get_tree().change_scene_to_file("res://scenes/final.tscn")
	else:
		words = _get_words()
		matrix_node.reset(words + _get_leets() + [current_password])
		passphrase_node.current_round = current_round
		timer_node.reset()

func _handle_leet_word():
	print("leet word") # TODO: Perform hacks!

func _handle_wrong_word(word):
	var found_chars = _compare_characters(word, current_password)
	matrix_node.add_known_chars(found_chars)
	
	timer_node.time_left -= time_penalty
