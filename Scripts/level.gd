extends Node2D

const TILE_SIZE: int = 16

@export var spawn_directions = [Vector2.UP, Vector2.LEFT,Vector2.DOWN,Vector2.RIGHT]
@export var spawn_direction_id: int

@export var spawn_layer: TileMapLayer
@export var background_layer: TileMapLayer
@export var box_scene: PackedScene
@export var player_scene: PackedScene
@export var crown_scene: PackedScene
@export var camera: Camera2D

#bool to make sure the player isn't spawned multiple times
var player_already_spawned

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#iterating through object spawn layer and placing objects
	var spawn_map_bounds = spawn_layer.get_used_rect()
	for x in range(spawn_map_bounds.position.x,spawn_map_bounds.end.x):
		for y in range(spawn_map_bounds.position.y,spawn_map_bounds.end.y):
			if spawn_layer.get_cell_tile_data(Vector2i(x,y)):
				var cell_data = spawn_layer.get_cell_tile_data(Vector2i(x,y))
				if cell_data.get_custom_data_by_layer_id(0):
					var box = box_scene.instantiate()
					box.position = spawn_layer.map_to_local(Vector2i(x,y))
					add_child(box)
				elif cell_data.get_custom_data_by_layer_id(1) and not player_already_spawned:
					var player = player_scene.instantiate()
					player.position = spawn_layer.map_to_local(Vector2i(x,y))
					add_child(player)
					player_already_spawned = true
				elif cell_data.get_custom_data_by_layer_id(4):
					var crown = crown_scene.instantiate()
					crown.position = spawn_layer.map_to_local(Vector2i(x,y))
					add_child(crown)
	#center camera
	var background_bounds = background_layer.get_used_rect()
	var new_camera_x = lerp(background_bounds.position.x,background_bounds.end.x,0.5) * TILE_SIZE
	var new_camera_y = lerp(background_bounds.position.y,background_bounds.end.y,0.5) * TILE_SIZE
	camera.position = Vector2(new_camera_x,new_camera_y)
				
			
	$ObjectSpawnsLayer.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

func player_wins() -> void:
	print('wohoo!')
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")
