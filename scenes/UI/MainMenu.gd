extends CanvasLayer

onready var playButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/PlayButton
onready var continueButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ContinueButton
onready var optionsButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/OptionsButton
onready var quitButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton

onready var savePath = $"/root/SaveFile".SAVE_FILE

func _ready():
	var saveFile = File.new()
	playButton.connect("pressed", self, "on_play_pressed")
	quitButton.connect("pressed", self, "on_quit_pressed")
	optionsButton.connect("pressed", self, "on_options_pressed")
	continueButton.connect("pressed", self, "on_continue_pressed")
	
	if (saveFile.file_exists(savePath)):
		continueButton.disabled = false
	saveFile.close()

func on_play_pressed():
	$"/root/SaveFile".save(0)
	$"/root/LevelManager".change_level(2)

func on_quit_pressed():
	get_tree().quit()

func on_options_pressed():
	$"/root/ScreenTransitionManager".transition_to_scene("res://scenes/UI/OptionsMenuStandalone.tscn")

func on_continue_pressed():
	var levelIndex = $"/root/SaveFile".load()
	$"/root/LevelManager".change_level(levelIndex)
