extends Control

var menu_music = "test_theme02"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set music
	Global.change_music(menu_music)
	pass # Replace with function body.

func _process(_delta: float) -> void:
	# Check if the player has pressed X to reset their save data
	if Input.is_action_just_pressed("reset save"):
		Global.reset_save()

func _on_button_pressed() -> void:
	# Transitions to the level select screen.
	Global.transition_to_scene("res://Scenes/level_select.tscn")


func _on_button_2_pressed() -> void:
	# Save and quit :>
	Global.save_data()
	get_tree().quit()


func _on_button_3_pressed() -> void:
	# Transitions to the credits screen.
	Global.transition_to_scene("res://Scenes/credits.tscn")
	pass # Replace with function body.
