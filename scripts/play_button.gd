extends Button

@export var id: int = 0
var active: bool = false
var flash: bool = false
var themes: Dictionary = {
	"normal": preload("res://themes/play_button_normal.tres"),
	"flash": preload("res://themes/play_button_flash.tres")
}

signal on_active

func _ready():
	on_active.connect($Sfx._on_player_ready)

func _process(_delta):
	_on_input()

func _on_timer_timeout():
	if active:
		return
	
	flash = !flash
	
	if flash:
		self.set_theme(themes["flash"])
	else:
		self.set_theme(themes["normal"])

func _on_input():
	if Input.is_action_just_pressed("bgs_start_p%d" % id):
		active = !active
		
		
		if active:
			on_active.emit()
			self.set_theme(themes["flash"])
			self.text = "Player %d Ready" % id
		else:
			self.set_theme(themes["normal"])
			self.text = "Player %d Start" % id
