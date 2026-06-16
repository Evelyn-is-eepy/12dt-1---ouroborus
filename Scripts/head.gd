extends Node2D

const TILE_SIZE: int = 16
const move_duration: float = 0.1

signal ate_tail

@export var facing_ray: RayCast2D
@export var movable_objects_ray: RayCast2D
@export var tail_hitbox: Area2D
@export var body_tilemap: TileMapLayer
@export var body_line: Line2D
@export var confetti: GPUParticles2D
@export var blood: GPUParticles2D
@export var head_sprite: AnimatedSprite2D
@export var face_sprite: AnimatedSprite2D
@export var starting_direction = Vector2.UP
@export var manager: Node2D
@export var personal_crown: ColorRect

var face_state: String = 'normal'
var current_head_direction: String
var last_moved_direction: Vector2 = starting_direction
var previous_move_directions: Array = [starting_direction]
var body_length: int = 0
var max_body_length: int = 300

var moving: bool = false
var can_move: bool = true
var has_crown: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	manager = get_node('/root/Node2D')
	connect('ate_tail',manager.player_wins)
	
	# Add the tail segment behind the head and orient the head sprite
	var new_head_direction: String
	match starting_direction:
		Vector2(1,0):
			new_head_direction = 'right'
		Vector2(-1,0):
			new_head_direction = 'left'
		Vector2(0,1):
			new_head_direction = 'down'
		Vector2(0,-1):
			new_head_direction = 'up'
	current_head_direction = new_head_direction
	head_sprite.play(new_head_direction)
	
	face_sprite.play('normal_'+new_head_direction)
	
	var tail_cell = body_tilemap.local_to_map(position - starting_direction * TILE_SIZE)
	var tail_tile_id
	match starting_direction:
		Vector2(0,-1):
			tail_tile_id = Vector2i(3,1)
		Vector2(0,1):
			tail_tile_id = Vector2i(3,0)
		Vector2(-1,0):
			tail_tile_id = Vector2i(2,0)
		Vector2(1,0):
			tail_tile_id = Vector2i(2,1)
	body_tilemap.set_cell(tail_cell,0,tail_tile_id,0)
	
	# Remove all points and add tail to line body
	body_line.clear_points()
	body_line.add_point(position - starting_direction * TILE_SIZE)
	# Add head/neck point
	body_line.add_point(position)
	
	tail_hitbox.position = position - starting_direction * TILE_SIZE
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# Stick the last point on the body line to the head so that there is a visible neck.
	body_line.points[-1] = position
	
	var move_direction: Vector2 = Vector2(0,0)
	if not moving and can_move:
		move_direction.x = (int(Input.is_action_just_pressed("move_right")) - int(Input.is_action_just_pressed("move_left")))
		move_direction.y = (int(Input.is_action_just_pressed("move_down")) - int(Input.is_action_just_pressed("move_up")))
		if move_direction.x and move_direction.y:
			move_direction = Vector2(move_direction.x,0)
	# Handle movement
	if move_direction and can_move:
		# Find direction of last body segment from array
		last_moved_direction = previous_move_directions[0]
		
		# Point rays in direction of movement
		var movement_obstructed:bool = false
		facing_ray.target_position = move_direction * TILE_SIZE
		facing_ray.force_raycast_update()
		movable_objects_ray.target_position = move_direction * TILE_SIZE
		movable_objects_ray.force_raycast_update()
		
		if facing_ray.is_colliding():
			movement_obstructed = true
		if movable_objects_ray.is_colliding():
			var object_to_move = movable_objects_ray.get_collider().get_parent()
			if object_to_move.is_blocked_in_direction(move_direction):
				movement_obstructed = true
		
		# Only move the player if their chosen direction is not blocked and they still have length to spare
		if not movement_obstructed and body_length < max_body_length:
			# initiate movement of snake head
			var tween = create_tween()
			moving = true
			tween.tween_property(self,'position',position + move_direction * TILE_SIZE,move_duration).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_callback(finish_move_and_check)
			
			# Change head sprite & face sprite
			var new_head_direction: String
			match move_direction:
				Vector2(1,0):
					new_head_direction = 'right'
				Vector2(-1,0):
					new_head_direction = 'left'
				Vector2(0,1):
					new_head_direction = 'down'
				Vector2(0,-1):
					new_head_direction = 'up'
			current_head_direction = new_head_direction
			head_sprite.play(new_head_direction)
			
			face_sprite.play(face_state+'_'+new_head_direction)
		
			# Update snake body
			var previous_position = position
			var previous_cell = body_tilemap.local_to_map(previous_position)
			var new_tile_id: Vector2i
			
			# Figure out what the second to last segment should be based on the last two move directions
			match [last_moved_direction, move_direction]:
				# Cases where segment becomes straight (4 cases)
				[Vector2.RIGHT,Vector2.RIGHT]: # >>
					new_tile_id = Vector2i(0,2) 
				[Vector2.UP,Vector2.UP]: # ^^
					new_tile_id = Vector2i(1,2)
				[Vector2.DOWN,Vector2.DOWN]: # vv
					new_tile_id = Vector2i(1,2)
				[Vector2.LEFT,Vector2.LEFT]: # <<
					new_tile_id = Vector2i(0,2)
				# Cases where segment becomes corner (8 cases)
				[Vector2.UP,Vector2.RIGHT]: # ^>
					new_tile_id = Vector2i(0,0) 
				[Vector2.LEFT,Vector2.DOWN]: # <v
					new_tile_id = Vector2i(0,0)
				[Vector2.RIGHT,Vector2.DOWN]: # >v
					new_tile_id = Vector2i(1,0)
				[Vector2.UP,Vector2.LEFT]: # ^<
					new_tile_id = Vector2i(1,0)
				[Vector2.DOWN,Vector2.RIGHT]: # v>
					new_tile_id = Vector2i(0,1) 
				[Vector2.LEFT,Vector2.UP]: # <^
					new_tile_id = Vector2i(0,1)
				[Vector2.RIGHT,Vector2.UP]: # >^
					new_tile_id = Vector2i(1,1)
				[Vector2.DOWN,Vector2.LEFT]: # v<
					new_tile_id = Vector2i(1,1)
				
			# Using this information, place the new body segment on the tilemap
			body_tilemap.set_cell(previous_cell,0,new_tile_id,0)
			
			# Add point to line body.
			# This means that the previous endpoint will no longer be 'stuck' to the head,
			# and come to rest on this point, while the new becomes 'stuck' as the neck.
			body_line.add_point(position)
			
			# Update previous moves array
			previous_move_directions.insert(0,move_direction)
			body_length += 1
			
			# Move boxes
			if movable_objects_ray.is_colliding():
				var object_to_move = movable_objects_ray.get_collider().get_parent()
				object_to_move.move_self(move_direction)
		
		
		# If there is something in the way (oooooooooo-oooooh)
		else:
			print('bonk!')
			# Bonk animation not implemented... yet.

# Finish move and check for hazards (called from tween callback)
func finish_move_and_check():
	moving = false
	if $Area2D.get_overlapping_bodies():
		var collider = $Area2D.get_overlapping_bodies()[0]
		if collider.is_in_group('terrain_and_hazards'):
			var cell = collider.local_to_map(collider.to_local(global_position))
			var cell_data = collider.get_cell_tile_data(cell)
			if cell_data:
				if cell_data.has_custom_data('falling_pit'):
					fall_into_hole()

func win() -> void:
	print('you won!')
	ate_tail.emit()
	face_state = 'happy'
	face_sprite.play(face_state+'_'+current_head_direction)
	confetti.emitting = true
	can_move = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	# For eating own tail or colliding with area objects
	print('area collision!')
	
	var crown = area.get_parent()
	if area.is_in_group('snake_tail'):
		win()
	
	elif crown.is_in_group('crown'):
		print('crown picked up!')
		crown.queue_free()
		personal_crown.visible = true
		has_crown = true

func fall_into_hole():
	# 'Animation' for falling into a pit
	blood.emitting = true
	face_sprite.visible = false
	can_move = false
