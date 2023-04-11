extends HBoxContainer

signal percentage_changed

var currentPercentage = 1.0

func _ready():
	$SubtractButton.connect("pressed", self, "on_button_pressed",[-.1])
	$AddButton.connect("pressed", self, "on_button_pressed",[.1])

func on_button_pressed(change):
	currentPercentage = clamp(currentPercentage + change, 0, 1)
	emit_signal("percentage_changed", currentPercentage)
