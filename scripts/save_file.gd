extends Node

var SAVE_FILE = "user://save_game.dat"

func save(levelIndex):
	var file = File.new()
	file.open(SAVE_FILE, File.WRITE)
	file.store_8(levelIndex)
	file.close()

func load():
	var file = File.new()
	file.open(SAVE_FILE, File.READ)
	var levelIndex = file.get_8()
	file.close()
	return levelIndex

func delete():
	var file = File.new()
	var dir = Directory.new()
	if (file.file_exists(SAVE_FILE)):
		print("Save file removed")
		dir.remove(SAVE_FILE)
	file.close()
