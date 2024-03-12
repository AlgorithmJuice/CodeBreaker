extends Node


var passphrase: Array = []
var rounds: int = 0

func _ready():
	passphrase = get_passphrase()
	rounds = passphrase.size()
	
	get_node("Passcode").text = display_passphrase()
	
func get_passphrase():
	var phrase = GameData.phrases[randi() % GameData.phrases.size()]	
	return phrase.split(" ")

func display_passphrase():
	var passphrase_text = ""
	
	for word in passphrase:
		passphrase_text += word + " "
		
	return passphrase_text.left(-1)
