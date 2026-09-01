extends Control

@export var button_container: GridContainer
@export var button_scene: PackedScene

var level_scene_path: String ="res://Scenes/Levels/"
var level_references: Array = ["level_1", "level_2", "level_3", "level_4", "level_5", "level_6", "level_7", "level_8"]
var button_style: StyleBox = load("res://Assets/menu_button_style.tres")
# File path of the main menu scene
@export var exit_scene: String = "res://Scenes/main_menu.tscn"
var button_hover_sound = "blip"


# Called when the node enters the scene tree for the first time.
# Creates all of the level selection buttons in the container.
func _ready() -> void:
	var free_button = true # So that you can access the next level you haven't played.
	var button_number: int = 0
	for level in level_references:
		button_number += 1
		var new_level_button = button_scene.instantiate()
		new_level_button.text = str(button_number)
		new_level_button.level_reference = level
		new_level_button.level_select_control = self
		new_level_button.add_theme_stylebox_override('normal',button_style)
		new_level_button.connect("mouse_entered", _on_button_mouse_entered)
		# Check if the level is acessible; if not, deactivate it.
		if not Global.levels_completed[level]:
			if free_button:
				free_button = false
			else:
				new_level_button.disabled = true
		button_container.add_child(new_level_button)


# Called from the level_select_button's level_selected signal
func level_selected(reference):
	# Transitions to the specific level
	print(reference) # Debug
	Global.transition_to_scene(level_scene_path + reference + '.tscn')


# On Exit button being pressed.
func _on_button_pressed() -> void:
	Global.transition_to_scene(exit_scene)

func _process(_delta: float) -> void:
	# Alternative method for exiting the level (esc key)
	if Input.is_action_just_pressed("exit"):
		Global.transition_to_scene(exit_scene)

# All buttons in this scene are linked to this function to make them clicky :3
func _on_button_mouse_entered() -> void:
	Global.play_sound_effect(button_hover_sound)
