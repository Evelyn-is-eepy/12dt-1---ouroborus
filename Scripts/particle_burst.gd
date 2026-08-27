extends GPUParticles2D
var paths = ['res://Assets/crystal_particle.png', 'res://Assets/apple_particle.png', 'res://Assets/switch_particle.png']
var type_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set to the right image
	texture = load(paths[type_index])
	emitting = true
	await finished
	queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
