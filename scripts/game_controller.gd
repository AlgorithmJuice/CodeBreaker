extends Node


@export var num_words: int = 50
@export var current_round: int = 0
@export var round_time: float = 30

var passphrase: Array = []
var words: Array = []
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
	clear_matrix()
	display_matrix()

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
	var selected_words = []
	var length = str(passphrase[current_round].length())
	var wordlist = GameData.words[length].duplicate()
	
	selected_words.append(passphrase[current_round])
	while selected_words.size() < num_words and wordlist.size() > 0:
		var index = randi() % wordlist.size()
		var word = wordlist[index]
		
		if not selected_words.has(word):
			selected_words.append(word)
			
		wordlist.remove_at(index)
	
	return selected_words
	
func clear_matrix():
	for child in matrix_container.get_children():
		matrix_container.remove_child(child)

func display_matrix():
	var shuffled_words = words.duplicate()
	shuffled_words.shuffle()
	
	for word in shuffled_words:
		var label = Label.new()
		
		label.text = word
		matrix_container.add_child(label)

func init_matrix():
	matrix_container = $MarginContainer/VerticalContainer/MatrixContainer
	
	display_matrix()
