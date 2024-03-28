extends Node

var _word: String = ""
var current_char_index = 0
var themes: Dictionary = {
	"default": null,
	"highlighted_word": preload("res://themes/highlighted_word.tres"),
	"highlighted_character": preload("res://themes/highlighted_character.tres"),
	"inactive_word": preload("res://themes/inactive_word.tres"),
	"inactive_highlighted_word": preload("res://themes/inactive_highlighted_word.tres")
}

var word: String:
	get: return _word
	set(text): _set_word(text)

func _ready():
	$ByteLabel.text = _get_byte()
	$Timer.wait_time += (randf() * 0.04) - 0.02 
	$Timer.start()

func _on_byte_timer_timeout():
	$ByteLabel.text = _get_byte()
	
func _on_timer_timeout():
	if current_char_index < _word.length():
		$WordContainer.get_child(current_char_index).visible = true
		current_char_index += 1
	else:
		$Timer.stop() # Stop the timer if all characters are revealed
	
func _get_byte():
	var byte = "x"
	var hex_chars = "0123456789ABCDEF"
	
	for i in range(2):
		var index = randi() % hex_chars.length()
		byte += hex_chars[index]
		
	return byte

func _set_word(text, is_new=false):
	_word = text
	
	if is_new:
		current_char_index = 0
	else:
		current_char_index = _word.length() - 1
	
	current_char_index = 0 # Reset the current index for typewriting effect
	
	for child in $WordContainer.get_children():
		$WordContainer.remove_child(child)
		child.queue_free()
	
	for character in text:
		var label = Label.new()
		label.text = character
		
		label.visible = !is_new
		$WordContainer.add_child(label)

func inactive_word_check(inactive_words):
	if _word in inactive_words:
		for character in $WordContainer.get_children():
			character.set_theme(themes["inactive_word"])
		return true
	return false
	
func inactive_highlight_word_check(inactive_words):
	if _word in inactive_words:
		for character in $WordContainer.get_children():
			character.set_theme(themes["inactive_highlighted_word"])
		return true
	return false

func highlight_word(inactive_words):
	if(inactive_highlight_word_check(inactive_words)):
		return
		
	for character in $WordContainer.get_children():
		character.set_theme(themes["highlighted_word"])
	#$WordContainer.set_theme(themes["highlighted_word"])
	
func unhighlight_word(inactive_words):
	if(inactive_word_check(inactive_words)):
		return
	#$WordContainer.set_theme(themes["default"])
	for character in $WordContainer.get_children():
		character.set_theme(themes["default"])
	
func highlight_characters(known_characters, inactive_words):
	if(inactive_word_check(inactive_words)):
		return
		
	for character in $WordContainer.get_children():
		if character.text in known_characters:
			character.set_theme(themes["highlighted_character"])
