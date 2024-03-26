extends GridContainer

var words = []
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
	self.get_child(selected_index).get_node("WordContainer").set_theme(themes["highlight"])

func clear():
	for child in self.get_children():
		self.remove_child(child)
		child.queue_free()

func display():
	for word in words:
		var word_instance = word_scene.instantiate()
		word_instance.word = word
		
		self.add_child(word_instance)
	_highlight_selected_word()

func reset():
	selected_index = 0
	known_chars = []
	clear()
	
	words.shuffle()
	display()

func set_selected_index(input_vector):
	clear()
	
	var index
	if selected_index % self.columns == 0 and input_vector[0] < 0:
		index = self.columns - 1
	elif selected_index % self.columns == self.columns - 1 and input_vector[0] > 0:
		index = -(self.columns - 1)
	elif selected_index / self.columns == 0 and input_vector[1] < 0:
		index = self.get_children().size() - self.columns
	elif selected_index / self.columns == (self.get_children().size() / self.columns) - 1 and input_vector[1] > 0:
		index = -(self.get_children().size() - self.columns)
	else:
		index = (input_vector[0] + (input_vector[1] * self.columns))
	
	selected_index += index
	display()

func add_known_chars(characters):
	for character in characters:
		if character not in known_chars:
			known_chars.append(character)
