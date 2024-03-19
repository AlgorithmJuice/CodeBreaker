extends GridContainer

var selected_index: int = 0
var known_chars = []
var word_scene: PackedScene = preload("res://scenes/packed/word.tscn")
var themes: Dictionary = {
	"default": null,
	"highlight": preload("res://themes/highlight.tres")
}

var selected_word: String:
	get: return self.get_child(selected_index).word

func _highlight_selected_word():
	self.get_child(selected_index).set_theme(themes["highlight"])

func clear():
	for child in self.get_children():
		self.remove_child(child)
		child.queue_free()

func shuffle():
	var children = self.get_children()
	children.shuffle()
	
	for child in children:
		self.remove_child(child)
		self.add_child(child)

func display(words):
	for word in words:
		var word_instance = word_scene.instantiate()
		word_instance.word = word
		
		self.add_child(word_instance)

	shuffle()
	_highlight_selected_word()

func reset(words):
	selected_index = 0
	known_chars = []
	clear()
	
	display(words)

func set_selected_index(input_vector):
	self.get_child(selected_index).set_theme(themes["default"])
	
	# TODO: Fix out-of-bounds errors.
	selected_index += (input_vector[0] + (input_vector[1] * self.columns))
	
	_highlight_selected_word()

func add_known_chars(chars):
	for char in chars:
		if char not in known_chars:
			known_chars.append(char)
