extends Node2D

const TILE_SIZE: int = 16

@export var wall_ray: RayCast2D
@export var movable_objects_ray: RayCast2D
@export var tail_ray: RayCast2D
@export var collision_area: Area2D
@export var trans_type = Tween.TRANS_CIRC
@export var duration = 0.6

var moving = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func is_blocked_in_direction(direction) -> bool:
	wall_ray.target_position = direction * TILE_SIZE
	movable_objects_ray.target_position = direction * TILE_SIZE
	tail_ray.target_position = direction * TILE_SIZE
	wall_ray.force_raycast_update()
	movable_objects_ray.force_raycast_update()
	tail_ray.force_raycast_update()
	if wall_ray.is_colliding():
		return true
	if tail_ray.is_colliding():
		if tail_ray.get_collider().is_in_group("snake_tail"):
			return true
	if movable_objects_ray.is_colliding():
		var object_to_move = movable_objects_ray.get_collider().get_parent()
		if object_to_move.is_blocked_in_direction(direction):
			return true
		else:
			return false
	else:
		return false
		
func move_self(direction):
	# Only called after it is confirmed safe to move
	moving = true
	var tween = create_tween()
	tween.tween_property(self,'position',position + direction * TILE_SIZE,0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(finish_move_and_check)
	movable_objects_ray.target_position = direction * TILE_SIZE
	# Blindly telling other boxes to move should be safe, as this only happens once it's verified that they're not blocked
	if movable_objects_ray.is_colliding():
		var object_to_move = movable_objects_ray.get_collider().get_parent()
		object_to_move.move_self(direction)
		
func finish_move_and_check():
	moving = false
	if collision_area.get_overlapping_bodies():
		var collider = collision_area.get_overlapping_bodies()[0]
		if collider.is_in_group('terrain_and_hazards'):
			var cell = collider.local_to_map(collider.to_local(global_position))
			var cell_data = collider.get_cell_tile_data(cell)
			if cell_data:
				if cell_data.has_custom_data('falling_pit'):
					fall_into_hole()

func fall_into_hole() -> void:
	collision_area.queue_free()
	var falling_tween = create_tween()
	falling_tween.set_parallel()
	falling_tween.tween_property(self, 'scale', Vector2(0,0), duration).set_trans(trans_type).set_ease(Tween.EASE_IN)
	falling_tween.tween_property(self,'position',position + Vector2(0,8.0), duration).set_trans(trans_type).set_ease(Tween.EASE_IN)
	falling_tween.tween_property(self,'rotation',PI/2,duration).set_trans(trans_type).set_ease(Tween.EASE_IN)
	falling_tween.set_parallel(false)
	falling_tween.tween_callback(queue_free)
