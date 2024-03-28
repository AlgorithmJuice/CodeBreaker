extends GridContainer

var words = []
var selected_index: int = 0
var known_chars = []
var inactive_words = []
var word_scene: PackedScene = preload("res://scenes/packed/word.tscn")

signal selection_change

var selected_word: Node:
	get: return self.get_child(selected_index)

func clear():
	for child in self.get_children():
		self.remove_child(child)
		child.queue_free()

func display():
	for i in range(words.size()):
		var word = words[i]
		
		var word_instance = word_scene.instantiate()
		word_instance.word = word
		
		if i == selected_index:
			word_instance.highlight_word(inactive_words)
		else:
			word_instance.highlight_characters(known_chars,inactive_words)
		
		self.add_child(word_instance)

func reload():
	clear()
	display()

func reset():
	selected_index = 0
	known_chars = []
	inactive_words = []
	words.shuffle()

	clear()
	display()

func set_selected_index(input_vector):
	selection_change.emit()
	selected_word.unhighlight_word(inactive_words)
	selected_word.highlight_characters(known_chars, inactive_words)
	
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
	selected_word.highlight_word(inactive_words)

func add_inactive_word(word):
	inactive_words.append(word)

func add_known_chars(characters):
	for character in characters:
		if character not in known_chars:
			known_chars.append(character)
