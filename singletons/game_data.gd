extends Node

var phrases: Array = []
var words: Dictionary = {}
var leet: Dictionary = {}

func _ready():
	phrases = load_json("res://data/phrases.json")
	words = load_json("res://data/words.json")
	leet = load_json("res://data/leet.json")

func load_json(filepath: String):
	if not FileAccess.file_exists(filepath):
		return

	var file = FileAccess.open(filepath, FileAccess.READ)
	var results = JSON.parse_string(file.get_as_text())

	return results
