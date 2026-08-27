extends Control

const MIN_LENGTH_CRITICAL = 3
const CRITICAL_COLOR = Color(0.89, 0.507, 0.603, 1.0)
const NORMAL_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const MAX_SHAKE_MOD = 2.0
const START_POSITION = Vector2(0, -96)

@export var label: Label
@export var container: PanelContainer
var critical_length: bool = false
var initial_position: Vector2 = Vector2(-20, -10)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = START_POSITION
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Shake effect for when remaining length is low
	if critical_length:
		container.position = initial_position
		var random_rotation = randf_range(0, 2 * PI)
		var random_modulus = randf_range(0, MAX_SHAKE_MOD)
		container.position += Vector2(0, random_modulus).rotated(random_rotation)
	pass


# Change the value displayed as remaining length
func change_values(new_length: int, new_max_length: int):
	# Find the remaining length and display it on the label
	var remaining_length = new_max_length - new_length
	label.text = str(remaining_length)
	# If remaining length is too low, make the label turn red and shake.
	if remaining_length <= MIN_LENGTH_CRITICAL:
		label.modulate = CRITICAL_COLOR
		critical_length = true
	# Otherwise, return it to normal.
	else:
		container.position = initial_position
		label.modulate = NORMAL_COLOR
		critical_length = false
