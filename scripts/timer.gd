extends ProgressBar


var _init_time: float = 0
var flash_rate: float = 1.0
var next_flash_time: float = 1.0
var is_flash_color: bool = false
var themes: Dictionary = {
	"default": preload("res://themes/progress_bar.tres"),
	"flash": preload("res://themes/progress_bar_flash.tres")
}

var init_time: float:
	get: return _init_time
	set(new_time): _set_init_time(new_time)

var wait_time: float:
	get: return $CountdownTimer.wait_time
	set(wait_time): $CountdownTimer.wait_time = wait_time
	
var time_left: float:
	get: return $CountdownTimer.time_left
	set(remaining): _set_time_left(remaining)
	
func _ready():
	self.set_theme(themes["default"])

func _process(delta):
	self.value = (time_left / init_time) * max_value

	 # Check if the progress is in its last 1/3
	if self.value <= self.max_value / 3:
		var time_fraction = time_left / (init_time / 3)
		flash_rate = lerp(1.0, 4.0, 1.0 - time_fraction)

		next_flash_time -= delta
		if next_flash_time <= 0.0:
			next_flash_time = 1.0 / flash_rate
			is_flash_color = !is_flash_color
			
			self.theme = themes["flash"] if is_flash_color else themes["default"]
	else:
		if self.theme != themes["default"]:
			self.theme = themes["default"]

func _set_init_time(new_time):
	_init_time = new_time
	wait_time = new_time

func _set_time_left(remaining):
	stop()
	
	if remaining <= 0.0:
		$CountdownTimer.emit_signal("timeout")
		wait_time = _init_time
	else:
		wait_time = remaining
		
	start()
	
func start():
	$CountdownTimer.start()

func stop():
	$CountdownTimer.stop()
	
func reset():
	stop()
	wait_time = init_time
	start()
	
