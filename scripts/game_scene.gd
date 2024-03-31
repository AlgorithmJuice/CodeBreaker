extends Control


@export var num_words: int
@export var num_leet: int
@export var round_time: int
@export var time_penalty: int
@export var player1: Node
@export var player2: Node
@export var music_player: Node

signal game_start

func _ready():
	var passphrase = _gen_passphrase()
	var wordlists = _gen_wordlists(passphrase)
	game_start.connect(Music._on_game_start)
	game_start.emit()
	
	_init_stats(passphrase)
	_init_player(player1, passphrase, wordlists)
	_init_player(player2, passphrase, wordlists)

func _gen_passphrase():
	var phrase = GameData.phrases[randi() % GameData.phrases.size()]	
	return phrase.split(" ")

func _gen_wordlists(passphrase):
	var wordlists = []
	
	for i in range(passphrase.size()):
		var password = passphrase[i]
		var wordlist = _get_words(password)
		var leets = _get_leets(password)
		
		wordlists.append(wordlist + leets + [password])
		
	return wordlists

func _get_words(password):
	var selected_words = []
	var total_words = num_words - (num_leet + 1) # Exclude leets words and correct word.
	var length = str(password.length())
	var wordlist = GameData.words[length].duplicate()
	
	while selected_words.size() < total_words and wordlist.size() > 0:
		var index = randi() % wordlist.size()
		var word = wordlist[index]
		
		if word != password:
			selected_words.append(word)
			
		wordlist.remove_at(index)
	
	return selected_words

func _get_leets(password):
	var selected_leets = []
	var length = str(password.length())
	var leetlist = GameData.leet[length].duplicate()
	
	# Add the leet words.
	for i in range(num_leet):
		var index = randi() % leetlist.size()
		var leet = leetlist[index]
		
		selected_leets.append(leet)
		leetlist.remove_at(index)
		
	return selected_leets

func _init_player(player, passphrase, wordlists):
	player.correct_passphrase = passphrase
	player.wordlists = wordlists.duplicate(true)
	player.round_time = round_time
	player.time_penalty = time_penalty
	
	player.init()

func _init_stats(passphrase):
	GameStats.passphrase = passphrase
	GameStats.start_timestamp = Time.get_unix_time_from_system()
	
	GameStats.winner = 0
	GameStats.stop_timestamp = 0
