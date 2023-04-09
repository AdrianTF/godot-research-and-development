extends Node

export(Array, PackedScene) var levelScenes
var currentLevelIndex = 0

func change_level(levelIndex):
	currentLevelIndex = levelIndex
	if (currentLevelIndex >= levelScenes.size()):
		$"/root/ScreenTransitionManager".transition_to_scene("res://scenes/UI/GameComplete.tscn")
	else:
		$"/root/ScreenTransitionManager".transition_to_scene(levelScenes[currentLevelIndex].resource_path)


func increment_level():
	change_level(currentLevelIndex + 1)
