extends Node2D

const TILE_SIZE: int = 16

@export var spawn_directions = [Vector2.UP, Vector2.LEFT,Vector2.DOWN,Vector2.RIGHT]
@export var spawn_direction_id: int
@export var spawn_max_length: int
@export var spawn_layer: TileMapLayer
@export var background_layer: TileMapLayer
@export var box_scene: PackedScene
@export var player_scene: PackedScene
@export var crown_scene: PackedScene
@export var apple_scene: PackedScene
@export var camera: Camera2D
# File path of the main menu scene
@export var exit_scene: String = "res://Scenes/level_select.tscn"

var player_already_spawned: bool = false
var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Finds bounds of level to search within for entity spawn markers
	var spawn_map_bounds = spawn_layer.get_used_rect()
	for x in range(spawn_map_bounds.position.x,spawn_map_bounds.end.x):
		for y in range(spawn_map_bounds.position.y,spawn_map_bounds.end.y):
			# Checks if a tile has custom data to indicate a spawn marker
			if spawn_layer.get_cell_tile_data(Vector2i(x,y)):
				var cell_data = spawn_layer.get_cell_tile_data(Vector2i(x,y))
				# Adds boxes
				if cell_data.get_custom_data_by_layer_id(0):
					var box = box_scene.instantiate()
					box.position = spawn_layer.map_to_local(Vector2i(x,y))
					add_child(box)
				# Adds player (only if no player has been spawned yet)
				elif cell_data.get_custom_data_by_layer_id(1) and not player_already_spawned:
					var player_to_add = player_scene.instantiate()
					player_to_add.position = spawn_layer.map_to_local(Vector2i(x,y))
					add_child(player_to_add)
					player_already_spawned = true
				# Adds the crown
				elif cell_data.get_custom_data_by_layer_id(4):
					var crown = crown_scene.instantiate()
					crown.position = spawn_layer.map_to_local(Vector2i(x,y))
					add_child(crown)
				# Adds apples
				elif cell_data.get_custom_data_by_layer_id(5):
					var apple = apple_scene.instantiate()
					apple.position = spawn_layer.map_to_local(Vector2i(x,y))
					add_child(apple)
	# Gets the snake
	player = get_tree().get_first_node_in_group("is_player_character")
	print(str(player))
	# Applies level settings to the snake
	player.starting_direction = spawn_directions[spawn_direction_id]
	player.max_body_length = spawn_max_length
	# Center camera
	var background_bounds = background_layer.get_used_rect()
	var new_camera_x = lerp(background_bounds.position.x,background_bounds.end.x,0.5) * TILE_SIZE
	var new_camera_y = lerp(background_bounds.position.y,background_bounds.end.y,0.5) * TILE_SIZE
	camera.position = Vector2(new_camera_x,new_camera_y)
	# Hides the object spawn layer
	spawn_layer.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Checks if the player has pressed space to reset the level
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	# Checks if the player has pressed escape to exit the level
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file(exit_scene)

func player_wins() -> void:
	# Called when the player eats their own tail
	print('wohoo!')
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file(exit_scene)
