extends Control

@export var transition_effect_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_button_pressed() -> void:
	var transition_effect = transition_effect_scene.instantiate()
	transition_effect.control_node = self
	transition_effect.origin_position = Vector2(-216,-122)
	add_child(transition_effect)
	await transition_effect.transition_finished
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
	pass # Replace with function body.
