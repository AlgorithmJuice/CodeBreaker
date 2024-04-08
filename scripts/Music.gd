extends Node

var activate_game = false
var activate_menu = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_game_start():
	activate_game = true
	
func _on_menu_start():
	activate_menu = true
	
func _on_sixteenth_note():
	pass
	if(activate_game == true):
		$MenuMusic.volume_db = -80
		$GameMusic.volume_db = -6
		activate_game = false
		
	if(activate_menu == true):
		$MenuMusic.volume_db = -6
		$GameMusic.volume_db = -80
		activate_menu = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(!$MenuMusic.playing):
		$MenuMusic.play()
	
	if(!$GameMusic.playing):
		$GameMusic.play()
	
	
	#if(activate_game):
		#if($MenuMusic.volume_db > -80):
			#$MenuMusic.volume_db -= 1
		#else:
			#$MenuMusic.volume_db = -80
		#
		#if($GameMusic.volume_db < -12):
			#$GameMusic.volume_db += 8
		#else:
			#$GameMusic.volume_db = -12
		#
		#if($MenuMusic.volume_db <= -80 && $GameMusic.volume_db >= -12):
			#activate_game = false
	#
	#if(activate_menu):
		#if($GameMusic.volume_db > -80):
			#$GameMusic.volume_db -= 1
		#else:
			#$GameMusic.volume_db = -80
		#
		#if($MenuMusic.volume_db < -12):
			#$MenuMusic.volume_db += 8
		#else:
			#$MenuMusic.volume_db = -12
		#
		#if($GameMusic.volume_db <= -80 && $MenuMusic.volume_db >= -12):
			#activate_game = false
