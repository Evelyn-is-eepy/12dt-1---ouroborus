extends Control

@export var path: Path2D
@export var path_follower: PathFollow2D
@export var body_line: Line2D

var section_time = 5.0
var stopping_points = [0.1, 0.3, 0.5, 0.694, 0.92, 1.0]
var stop_time = 2.8
var credits_music = "credits theme"

# File path of the main menu scene
@export var exit_scene: String = "res://Scenes/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Change music
	Global.change_music(credits_music)
	# Build snake body from the Path2D's curve
	var sampled_points = path.curve.get_baked_points()
	body_line.points = sampled_points
	# Tween the camera around the snake
	path_follower.progress_ratio = 0
	var head_tween = create_tween()
	head_tween.set_trans(Tween.TRANS_CUBIC)
	head_tween.set_ease(Tween.EASE_IN_OUT)
	head_tween.tween_interval(stop_time)
	for point in stopping_points:
		head_tween.tween_property(path_follower, "progress_ratio", point, section_time)
		head_tween.tween_interval(stop_time)
	head_tween.tween_callback(Global.transition_to_scene.bind(exit_scene))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		Global.transition_to_scene(exit_scene)
	pass


func _on_button_pressed() -> void:
	Global.transition_to_scene(exit_scene)

# Animate the snake's body on a looping 1-second timer
func _on_timer_timeout() -> void:
	body_line.width += 1.0
	body_line.width = wrapf(body_line.width, 14.0, 16.0)
	pass # Replace with function body.
