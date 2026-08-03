extends Node2D

@export var blocker_area: Area2D
@export var blocker_shape: CollisionShape2D
@export var weight_checker: RayCast2D
@export var sprite: AnimatedSprite2D

var nodes_that_block = ["BodyHitbox", "HeadCollider", "BoxHitbox"]
var anim_names = ["close", "open"]
var is_active: bool
var weighed_down: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	activate_or_deactivate()

func activate_or_deactivate():
	# When a button is pushed down, all walls switch state from open to closed or vice versa.
	if is_active:
		is_active = false
		blocker_shape.set_deferred("disabled", not is_active)
		sprite.play(anim_names[1])
	else:
		# Check that the snake or boxes are not blocking the way
		weight_checker.force_raycast_update()
		var colliding_area: Node2D = weight_checker.get_collider()
		if colliding_area:
			print("    checking: " + str(colliding_area))
			if colliding_area.name in nodes_that_block:
				print("     obstruction detected!")
				weighed_down = true
		if not weighed_down:
			is_active = true
			blocker_shape.set_deferred("disabled", not is_active)
			sprite.play(anim_names[0])
	
	print("    roger sir, kachunking now: " + str(weighed_down)) # Debug
