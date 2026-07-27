extends Node

var save_path = "user://data.save"
var levels_completed: Dictionary = {}
var levels_master: Dictionary = {
	"level_1": false,
	"level_2": false,
	"level_3": false,
	"level_4": false,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_data()
	pass # Replace with function body.

func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(levels_completed)
	file.close()

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		levels_completed = file.get_var()
		file.close()
	else:
		print("save file not found")
		levels_completed = levels_master
		save_data()

func reset_save():
	levels_completed = levels_master
	save_data()
