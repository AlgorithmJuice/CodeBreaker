extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	BgsCabCredits.credits_changed.connect(_on_credits_changed)


func _on_credits_changed(credits:int) -> void:
	text = "%d / %d" % [credits, ProjectSettings.get(BgsCabConsts.Settings.Credits.minimum_credits)]
