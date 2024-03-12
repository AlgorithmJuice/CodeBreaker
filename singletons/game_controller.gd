extends Node

var passphrase: Array = []
var rounds: int = 0

func _ready():
	passphrase = get_passphrase()
	rounds = passphrase.size()
	
func get_passphrase() -> Array:
	var phrase: String = GameData.phrases[randi() % GameData.phrases.size()]	
	return phrase.split(" ")
