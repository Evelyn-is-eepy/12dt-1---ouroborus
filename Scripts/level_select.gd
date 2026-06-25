extends Control

@export var button_container: GridContainer
@export var button_scene: PackedScene

var level_scene_path: String ="res://Scenes/Levels/"
var level_references: Array = ["level_1","level_2","level_3"]
var button_style: StyleBox = load("res://Assets/menu_button_style.tres")
# File path of the main menu scene
@export var exit_scene: String = "res://Scenes/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var button_number: int = 0
	for level in level_references:
		button_number += 1
		var new_level_button = button_scene.instantiate()
		new_level_button.text = str(button_number)
		new_level_button.level_reference = level
		new_level_button.level_select_control = self
		new_level_button.add_theme_stylebox_override('normal',button_style)
		button_container.add_child(new_level_button)

func level_selected(reference):
	print(reference)
	get_tree().change_scene_to_file(level_scene_path + reference + '.tscn')


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(exit_scene)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file(exit_scene)
