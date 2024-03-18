extends GridContainer

var words: Array = []
var focused_index: int = 0
var discovered_letters: Array = []
var word_root: PackedScene = null
var theme_highlight: Theme = null
@export_range(1, 2) var player_id:= 1

var current_password

# Called when the node enters the scene tree for the first time.
func _ready():
	word_root = preload("res://nodes/word.tscn")
	theme_highlight = preload("res://themes/highlight.tres")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func shuffle_matrix():
	var children = self.get_children()
	children.shuffle()
	
	for child in children:
		self.remove_child(child)
		self.add_child(child)



func clear_matrix():	
	for child in self.get_children():
		self.remove_child(child)
		child.queue_free()

func display_matrix():
	#no need to differentiate password/leetword/regular words
	#correct word is public variable for checks
	#leet words will always contain numbers to check for
	
	#add passcode word
	#add leet words
	#add remaining words based on total words - (leet words + password)
	
	#uncomment the following when add_word is added
	#add_pass_word(current_password)
	#for word in words: add_pass_word(word)
	#for leet in get_leets(): add_pass_word(leet)
	
	#shuffle
	shuffle_matrix()
	#set default focus
	#set_default_matrix_focus()
	set_cursor_position(0)

func init_matrix():
	clear_matrix()
	display_matrix()
	

func add_discovered_letters(word):
	var active_word = current_password
	for character in word:
		if character in active_word and character not in discovered_letters:
			discovered_letters.append(character)

func clear_discovered_letters():
	discovered_letters = []
	
func set_cursor_position(index):
	#un-highlight word at focused index
	update_theme(self.get_child(focused_index),null)
	focused_index = index
	update_theme(self.get_child(focused_index),theme_highlight)
	#highlight word at focused index
	

func update_theme(node, theme):
	node.set_theme(theme)

func add_pass_word(text):
	var instance = word_root.instantiate()
	instance.text = text
	matrix_container_1.add_child(instance)

func on_joystick():
	#original parameter pass: ("bgs_right_p%d" % player)
	#This is hecking fast ("bgs_down_p%d" % player)
	var new_index = focused_index
	if Input.is_action_just_pressed("bgs_right_p%d" % player_id):
		new_index += 1
	if Input.is_action_just_pressed("bgs_left_p%d" % player_id):
		new_index -= 1
	if Input.is_action_just_pressed("bgs_down_p%d" % player_id):
		new_index += columns
	if Input.is_action_just_pressed("bgs_up_p%d" % player_id):
		new_index -= columns
	
	#handle out of bounds case
	if new_index != focused_index:
		set_cursor_position(new_index)

func on_gamepad_button():
	if Input.is_action_just_pressed("bgs_a_p%d" % player_id):
		var container = self.get_child(focused_index)
		var selected_word = container.text
		var regex = RegEx.new()
		regex.compile("\\d")
		
		if selected_word == current_password:
			#_on_passcode_pressed()
			pass
		elif regex.search(selected_word):
			#_on_leet_pressed()
			pass
		else:
			#_on_word_pressed(selected_word)
			pass
