extends Node


@export var passphrase: Array = []
@export var current_round: int = 0

var total_rounds: int = 0

func _ready():
	passphrase = get_passphrase()
	total_rounds = passphrase.size()
	
	get_node("Passcode/PasscodeLabel").text = display_passphrase()
	
func _on_passcode_timer_timeout():
	get_node("Passcode/PasscodeLabel").text = display_passphrase()
	
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
