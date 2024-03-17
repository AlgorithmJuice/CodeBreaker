extends Node

var text: String:
	get:
		return text
	set(new_text):
		text = new_text
		
		for child in $WordContainer.get_children():
			$WordContainer.remove_child(child)
			child.queue_free()
		
		for character in new_text:
			var label = Label.new()
			label.text = character
			$WordContainer.add_child(label)

func _ready():
	$ByteLabel.text = get_byte()
	
func _on_byte_timer_timeout():
	$ByteLabel.text = get_byte()
	
func get_byte():
	var byte = "x"
	var hex_chars = "0123456789ABCDEF"
	
	for i in range(2):
		var index = randi() % hex_chars.length()
		byte += hex_chars[index]
		
	return byte
