extends Button

@export var id: int = 0
var active: bool = false
var flash: bool = false
var themes: Dictionary = {
	"normal": preload("res://themes/play_button_normal.tres"),
	"flash": preload("res://themes/play_button_flash.tres")
}

func _process(_delta):
	_on_input()

func _on_timer_timeout():
	if active:
		self.set_theme(themes["flash"])
		return
	
	flash = !flash
	
	if flash:
		self.set_theme(themes["flash"])
	else:
		self.set_theme(themes["normal"])

func _on_input():
	if Input.is_action_just_pressed("bgs_start_p%d" % id):
		print("test")
		active = !active
		
		
		if active:
			self.set_theme(themes["normal"])
			self.text = "Player %d Ready" % id
		else:
			self.text = "Player %d Start" % id
