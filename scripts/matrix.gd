extends GridContainer

var words = []
var selected_index: int = 0
var known_chars = []
var word_scene: PackedScene = preload("res://scenes/packed/word.tscn")
var themes: Dictionary = {
	"default": null,
	"highlighted_word": preload("res://themes/highlighted_word.tres"),
	"highlighted_character": preload("res://themes/highlighted_character.tres")
}

var selected_word: String:
	get: return self.get_child(selected_index).word

func _highlight_word(word):
	word.get_node("WordContainer").set_theme(themes["highlighted_word"])
	
func _highlight_characters(word):
	for character in word.get_node("WordContainer").get_children():
		if character.text in known_chars:
			character.set_theme(themes["highlighted_character"])

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
			_highlight_word(word_instance)
		else:
			_highlight_characters(word_instance)
		
		self.add_child(word_instance)

func reload():
	clear()
	display()

func reset():
	selected_index = 0
	known_chars = []
	words.shuffle()
	
	clear()
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
