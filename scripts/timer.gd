extends Label


# TODO: I am way too tired to this...

var _init_time: float = 0

var init_time: float:
	get: return _init_time
	set(new_time): _set_init_time(new_time)

var wait_time: float:
	get: return $CountdownTimer.wait_time
	set(wait_time): $CountdownTimer.wait_time = wait_time
	
var time_left: float:
	get: return $CountdownTimer.time_left
	set(remaining): _set_time_left(remaining)

func _process(_delta):
	self.text = _format()

func _format():
	return "%.2f" % time_left

func _set_init_time(new_time):
	_init_time = new_time
	wait_time = new_time

func _set_time_left(remaining):
	stop()
	
	if remaining <= 0.0:
		wait_time = init_time
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
	
