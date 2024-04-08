extends Node

@export var bpm: int
var quarter_note_period: float
var sixteenth_note_period: float
var prev_sixteenth_timestamp: float
var prev_quarter_timestamp: float
var current_timestamp: float

signal sixteenth_note
signal quarter_note

# Called when the node enters the scene tree for the first time.
func _ready():
	#at 120 bpm quarter notes pulse every 1/2 second
	quarter_note_period = bpm / (60) 
	#at 120 bpm sixteenth notes pulse every 1/8 second
	sixteenth_note_period = quarter_note_period / 4
	
	prev_sixteenth_timestamp = Time.get_unix_time_from_system()
	prev_quarter_timestamp = prev_sixteenth_timestamp
	current_timestamp = prev_sixteenth_timestamp

	sixteenth_note.connect($Music._on_sixteenth_note)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	current_timestamp += delta
	
	if(current_timestamp - prev_quarter_timestamp > quarter_note_period):
		quarter_note.emit()
		prev_quarter_timestamp += quarter_note_period
		
	if (current_timestamp - prev_sixteenth_timestamp > sixteenth_note_period):
		sixteenth_note.emit()
		prev_sixteenth_timestamp += sixteenth_note_period
