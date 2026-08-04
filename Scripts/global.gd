extends Node

var save_path = "user://data.save"
var levels_completed: Dictionary = {}
var levels_master: Dictionary = {
	"level_1": false,
	"level_2": false,
	"level_3": false,
	"level_4": false,
}
var transition_layer: CanvasLayer
var transition_material: Material
var transition_duration: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transition_layer = get_node("/root/TransitionLayer")
	transition_material = transition_layer.get_node("ColorRect").material
	transition_layer.visible = false
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

func transition_to_scene(scene_path):
	print("transitioning to " + scene_path)
	transition_layer.visible = true
	var transition_tween = create_tween()
	transition_material.set_shader_parameter("progress", 0.0)
	transition_tween.tween_property(transition_material, "shader_parameter/progress", 1.0, transition_duration / 2).set_trans(Tween.TRANS_LINEAR)
	transition_tween.tween_callback(get_tree().change_scene_to_file.bind(scene_path))
	transition_tween.tween_callback(print.bind("changing scene"))
	transition_tween.tween_property(transition_material, "shader_parameter/progress", 0.0, transition_duration / 2).set_trans(Tween.TRANS_LINEAR)
	transition_tween.tween_callback(print.bind("transition finished"))
	transition_tween.tween_callback(transition_layer.set.bind("visible", false))
