extends Node

@export var AudioBus1: AudioBusLayout

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _init_sfx(player_id):
	if(player_id == 1):
		$TypeSfx.bus = "Left"
	elif(player_id == 2):
		$TypeSfx.bus = "Right"

func _on_matrix_selection_change():
	$TypeSfx.play()

