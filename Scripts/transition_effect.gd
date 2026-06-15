extends ColorRect

@export var duration: float
@export var control_node: Node
@export var origin_position: Vector2
@export var transition_material: Material

signal transition_finished


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = origin_position
	transition_material.set_shader_parameter("progress", 0.0)
	var tween = create_tween()
	tween.tween_property(transition_material,"shader_parameter/progress",1.0,duration)
	tween.tween_callback(transition_finished.emit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
