extends Control

# File path of the main menu scene
@export var exit_scene: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file(exit_scene)
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(exit_scene)
