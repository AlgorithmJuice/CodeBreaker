extends Label


@export var words: Array = []
var current_round: int = 0

func _on_passphrase_timer_timeout():
	display()

func display():
	var cracked_passphrase = ""
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	for i in range(words.size()):
		var word = words[i]
		
		if i < current_round:
			cracked_passphrase += word
		else:
			for c in word:
				var index = randi() % alphabet.length()
				cracked_passphrase += alphabet[index]
			
		cracked_passphrase += " "
	
	self.text = cracked_passphrase.left(-1)
