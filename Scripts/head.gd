extends Node2D

const TILE_SIZE: int = 16
const move_duration = 0.1
const bonk_duration = 0.2
const move_directions_and_names = [{Vector2(1.0,0.0):"right"},{Vector2(-1.0,0.0):"left"},{Vector2(0.0,-1.0):"up"},{Vector2(0.0,1.0):"down"},]
const apple_length_bonus: int = 3

signal ate_tail

@export var facing_ray: RayCast2D
@export var movable_objects_ray: RayCast2D
@export var tail_hitbox: Area2D
@export var tail_pivot: Node2D
@export var body_line: Line2D
@export var body_collider: Area2D
@export var head_collider: Area2D
@export var confetti: GPUParticles2D
@export var blood: GPUParticles2D
@export var head_sprite: Sprite2D
@export var face_sprite: AnimatedSprite2D
@export var starting_direction: Vector2
@export var manager: Node2D
@export var personal_crown: ColorRect
@export var move_trans_type = Tween.TRANS_BOUNCE
@export var bonk_trans_type = Tween.TRANS_LINEAR
@export var bonk_max_amplitude: float
@export var starting_max_length: int

var face_state: String = 'normal'
var current_head_direction: Vector2
var last_moved_direction: Vector2 = starting_direction
var previous_move_directions: Array = [starting_direction]
var max_body_length: int
var moving: bool = false
var shaking: bool = false
var can_move: bool = true
var has_crown: bool = false
var position_before_bonk: Vector2
var shake_intensity: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	manager = get_node('/root/Node2D')
	connect('ate_tail',manager.player_wins)
	# Orient the head and face
	current_head_direction = starting_direction
	head_sprite.rotation = starting_direction.rotated(PI/2).angle() 
	face_sprite.play('normal_' + get_direction_name(current_head_direction))
	# Remove all points and add tail to line body
	body_line.clear_points()
	body_line.add_point(position - starting_direction * TILE_SIZE)
	# Add head/neck point
	body_line.add_point(position)
	# Move and rotate the tail so that it is behind the head
	tail_pivot.position = position - starting_direction * TILE_SIZE
	
	tail_pivot.rotation = starting_direction.rotated(PI/2).angle() 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# If the body is shaking from a bonk, add a randomised offset
	if shaking:
		position = position_before_bonk
		var random_rotation = randf_range(0,2*PI)
		position += Vector2.UP.rotated(random_rotation) * shake_intensity
	# Stick the last point on the body line to the head so that there is a visible neck.
	body_line.points[-1] = position
	# Take player inputs for move direction
	var move_direction: Vector2 = Vector2(0,0)
	if not moving and can_move:
		# These vars are to prevent super long lines
		# It needs to be 'action_just_pressed' to prevent icky accidental double moves
		var input_x_pos = int(Input.is_action_just_pressed("move_right"))
		var input_x_neg = int(Input.is_action_just_pressed("move_left"))
		var input_y_pos = int(Input.is_action_just_pressed("move_down"))
		var input_y_neg = int(Input.is_action_just_pressed("move_up"))
		# This math works essentially the same as an Input.get_axis() function
		move_direction.x = input_x_pos - input_x_neg
		move_direction.y = input_y_pos - input_y_neg
		# If both y and x have input, take only x
		if move_direction.x and move_direction.y:
			move_direction = Vector2(move_direction.x,0)
	# Handle movement
	if move_direction and can_move:
		# Point rays in direction of movement and force update
		var movement_obstructed:bool = false
		facing_ray.target_position = move_direction * TILE_SIZE
		facing_ray.force_raycast_update()
		movable_objects_ray.target_position = move_direction * TILE_SIZE
		movable_objects_ray.force_raycast_update()
		# Check for collisions and update movement_obstructed if needed
		if facing_ray.is_colliding():
			movement_obstructed = true
		if movable_objects_ray.is_colliding():
			var object_to_move = movable_objects_ray.get_collider().get_parent()
			if object_to_move.is_blocked_in_direction(move_direction):
				movement_obstructed = true
		# Find the length of the snake's body (number of body points other than head and tail)
		var body_length: int = len(body_line.points) - 2
		var body_too_long: bool = body_length >= max_body_length
		# Only move the player if their chosen direction is not blocked and they still have length to spare
		if not(movement_obstructed or body_too_long):
			# Initiate movement of snake head
			var tween = create_tween()
			moving = true
			tween.tween_property(self,'position',position + move_direction * TILE_SIZE,move_duration).set_trans(move_trans_type)
			tween.tween_callback(finish_move_and_check)
			# Change head & face sprite
			current_head_direction = move_direction
			head_sprite.rotation = move_direction.rotated(PI/2).angle()
			face_sprite.play(face_state + '_' + get_direction_name(current_head_direction))
			# Add point to line body.
			# This means that the previous endpoint will no longer be 'stuck' to the head,
			# and come to rest on this point, while the new becomes 'stuck' as the neck.
			body_line.add_point(position)
			# Update previous moves array
			previous_move_directions.insert(0,move_direction)
			# Move boxes
			if movable_objects_ray.is_colliding():
				var object_to_move = movable_objects_ray.get_collider().get_parent()
				object_to_move.move_self(move_direction)
			# Update body collision shape
			recreate_body_hitbox()
		# If there is something in the way (oooooooooo-oooooh)
		else:
			print('bonk!')
			# prevent movement until bonk is finished
			moving = true
			shaking = true
			# store the original position to prevent becoming misaligned
			position_before_bonk = position
			var bonk_tween = create_tween()
			# Set shake intensity to max and then tween it back down
			shake_intensity = bonk_max_amplitude
			bonk_tween.tween_property(self,'shake_intensity',0,bonk_duration)
			# this function works just as well here, no need to bloat things by adding another
			bonk_tween.tween_callback(finish_move_and_check)

# Finish move and check for hazards (called from tween callback)
func finish_move_and_check():
	moving = false
	shaking = false
	print("length: " + str(len(body_line.points) - 2) +" max: " + str(max_body_length))
	# Check if the head is overlapping any bodies
	if head_collider.get_overlapping_bodies():
		print("bodies detected!")
		for collider in head_collider.get_overlapping_bodies():
			# Is it a bottomless pit?
			if collider.is_in_group('terrain_and_hazards'):
				var cell = collider.local_to_map(collider.to_local(global_position))
				var cell_data = collider.get_cell_tile_data(cell)
				if cell_data:
					if cell_data.has_custom_data('falling_pit'):
						fall_into_hole()
	# Check for overlapping areas
	if head_collider.get_overlapping_areas():
		print("areas detected!")
		for area in head_collider.get_overlapping_areas():
			# Is it a consumable?
			if area.get_parent().is_in_group("Consumable"):
				print("om nom nom :')'")
				var consumable = area.get_parent()
				# Go through the possibilities
				if consumable.is_in_group('crown'):
					pass # Crown code to go here.
				elif consumable.is_in_group('apple'):
					max_body_length += apple_length_bonus
				# Once done, remove the consumable
				consumable.queue_free()

# Function to rebuild the line body's hitbox, removing the old hitbox
# places a tile-sized collider on each point except the first (tail) and last (head)
func recreate_body_hitbox():
	# Deleting old collision shapes
	var old_collsion_shapes = body_collider.get_children()
	for shape in old_collsion_shapes:
		shape.queue_free()
	# Get all points other than tail and head
	var body_points = body_line.points.duplicate()
	body_points.remove_at(0)
	body_points.remove_at(-1)
	# Instance a collision rect as a child of the body hitbox Area2D on each point
	for point in body_points:
		# Make a tile-sized collision rect
		var collision_square = CollisionShape2D.new()
		collision_square.shape = RectangleShape2D.new()
		collision_square.shape.size = Vector2(TILE_SIZE,TILE_SIZE)
		collision_square.position = point
		# Add it to the Area2D as child
		body_collider.add_child(collision_square)
	pass

# Function to take the current move direction and output a string such as 'down' accordingly
# This is for managing the face sprites
func get_direction_name(direction) -> String:
	for possible_direction in move_directions_and_names:
		var possible_vector = possible_direction.keys()[0]
		if direction == possible_vector:
			return possible_direction[possible_vector]
	# If the direction inputted doesn't match one of the 4 directions in the list:
	print("get_direction_name(): direction does not match given cardinals")
	# Just to be safe :P
	return "up"

# Function called when the player wins a level
# Signals to main, chnages the face sprite and disables movement
func win() -> void:
	print('you won!')
	ate_tail.emit()
	face_state = 'happy'
	face_sprite.play(face_state + '_' + get_direction_name(current_head_direction))
	confetti.emitting = true
	can_move = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	# For eating own tail or colliding with area objects
	print('area collision!')
	# If the object is the tail, you win.
	# There is an issue where you could win by running into a wall for your first move,
	# Which could make you hit your own tail through the 'bonk' shaking animation.
	if area.is_in_group('snake_tail') and not shaking:
		win() # This code is amusing.

func fall_into_hole():
	# 'Animation' for falling into a pit
	blood.emitting = true
	face_sprite.visible = false
	can_move = false
