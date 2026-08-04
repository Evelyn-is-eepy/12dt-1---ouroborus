extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset save"):
		Global.reset_save()

func _on_button_pressed() -> void:
	Global.transition_to_scene("res://Scenes/level_select.tscn")


func _on_button_2_pressed() -> void:
	Global.save_data()
	get_tree().quit()


func _on_button_3_pressed() -> void:
	Global.transition_to_scene("res://Scenes/credits.tscn")
	pass # Replace with function body.
