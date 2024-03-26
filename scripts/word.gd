extends Node

var _word: String = ""
var themes: Dictionary = {
	"default": null,
	"highlighted_word": preload("res://themes/highlighted_word.tres"),
	"highlighted_character": preload("res://themes/highlighted_character.tres")
}

var word: String:
	get: return _word
	set(text): _set_word(text)

func _ready():
	$ByteLabel.text = _get_byte()
	
func _on_byte_timer_timeout():
	$ByteLabel.text = _get_byte()
	
func _get_byte():
	var byte = "x"
	var hex_chars = "0123456789ABCDEF"
	
	for i in range(2):
		var index = randi() % hex_chars.length()
		byte += hex_chars[index]
		
	return byte

func _set_word(text):
	_word = text
	
	for child in $WordContainer.get_children():
		$WordContainer.remove_child(child)
		child.queue_free()
	
	for character in text:
		var label = Label.new()
		label.text = character
		$WordContainer.add_child(label)
		
func highlight_word():
	$WordContainer.set_theme(themes["highlighted_word"])
	
func unhighlight_word():
	$WordContainer.set_theme(themes["default"])
	
func highlight_characters(known_characters):
	for character in $WordContainer.get_children():
		if character.text in known_characters:
			character.set_theme(themes["highlighted_character"])
