extends Node

var data = {}

func _ready():
	data["words"] = load_json("res://data/words.json")
	data["phrases"] = load_json("res://data/phrases.json")
	data["leet"] = load_json("res://data/leet.json")

func load_json(filepath: String):
	if not FileAccess.file_exists(filepath):
		return

	var file = FileAccess.open(filepath, FileAccess.READ)
	var results = JSON.parse_string(file.get_as_text())

	return results
