extends Node

enum ParticleTypes {CRYSTAL, APPLE, SWITCH}
var save_path = "user://data.save"
var levels_completed: Dictionary = {}
var levels_master: Dictionary = {
	"level_1": false,
	"level_2": false,
	"level_3": false,
	"level_4": false,
	"level_5": false,
	"level_6": false,
}
var transition_layer: CanvasLayer
var transition_material: Material
var transition_duration: float = 0.5
var trans_type = Tween.TRANS_LINEAR
var sound_paths: Dictionary = {
	"test_die": "res://Assets/Audio/die copy.ogg",
	"scoot1" : "res://Assets/Audio/scoot.wav",
	"scoot2" : "res://Assets/Audio/scoot2.wav",
	"scoot3" : "res://Assets/Audio/scoot3.wav",
	"bump" : "res://Assets/Audio/bump.wav",
	"win_jingle" : "res://Assets/Audio/Win Jingle.mp3",
	"reset_level": "res://Assets/Audio/reset.wav",
	"crystal": "res://Assets/Audio/eat_crystal.wav",
	"apple": "res://Assets/Audio/eat_apple.wav",
	"fall_into_pit": "res://Assets/Audio/fall_over.wav",
	"box_scoot": "res://Assets/Audio/box_move.wav",
	"transition": "res://Assets/Audio/transition.wav",
	"wall down": "res://Assets/Audio/shwomp.wav",
	"wall up": "res://Assets/Audio/kachunk.wav",
	"button press": "res://Assets/Audio/button_press.wav",
	"blip": "res://Assets/Audio/blipSelect.wav"
}
var music_paths: Dictionary = {
	"test_theme02": "res://Assets/Audio/Theme test 02.mp3",
	"test_theme01": "res://Assets/Audio/Theme test 01.ogg",
	"credits theme": "res://Assets/Audio/credits_theme.mp3"
}
var menu_music = "test_theme02"
var transition_sound = "transition"
var music_player: AudioStreamPlayer
var last_played_music: String
var file_extensions = ['ogg', 'mp3', 'wav']
var audio_buses = ["Master", "Sound Effects", "Music"]
var particle_burst_scene: PackedScene = load("res://Scenes/particle_burst.tscn")
var can_transition: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transition_layer = get_node("/root/TransitionLayer")
	music_player = get_node("/root/MusicPlayer")
	transition_material = transition_layer.get_node("ColorRect").material
	transition_layer.visible = false
	change_music(menu_music)
	load_data()
	pass # Replace with function body.


func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(levels_completed)
	file.close()


func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		levels_completed = file.get_var()
		file.close()
	else:
		print("save file not found")
		levels_completed = levels_master
		save_data()


func reset_save():
	levels_completed = levels_master
	save_data()


# Function to add screen transitions on changing scene.
func transition_to_scene(scene_path: String):
	# So that you can't trigger a scene transition when one is already occuring
	if can_transition: # You still have time (iykyk)
		# Unhides the transition effect layer, tweens its material until the screen is obscured,
		# Changes the scene, and then reverses the obscurement
		can_transition = false
		print("transitioning to " + scene_path) # Debug
		play_sound_effect(transition_sound)
		transition_layer.visible = true
		var transitioner = create_tween()
		transitioner.set_trans(trans_type)
		transition_material.set_shader_parameter("progress", 0.0)
		var trans_time = transition_duration / 2 # To shorten lines
		transitioner.tween_property(transition_material, "shader_parameter/progress", 1.0, trans_time)
		transitioner.tween_callback(get_tree().change_scene_to_file.bind(scene_path))
		transitioner.tween_callback(print.bind("changing scene")) # Debug
		transitioner.tween_property(transition_material, "shader_parameter/progress", 0.0, trans_time)
		transitioner.tween_callback(print.bind("transition finished")) # Debug
		transitioner.tween_callback(transition_layer.set.bind("visible", false))
		transitioner.tween_callback(set.bind("can_transition", true))


func play_sound_effect(sound_name: String):
	if sound_paths.has(sound_name):
		var player = AudioStreamPlayer.new()
		player.bus = audio_buses[1]
		var extension = sound_paths[sound_name].get_extension()
		# Load the file differently according to filetype (no universal audiostream type)
		if extension == file_extensions[0]:
			player.stream = AudioStreamOggVorbis.load_from_file(sound_paths[sound_name])
		elif extension == file_extensions[1]:
			player.stream = AudioStreamMP3.load_from_file(sound_paths[sound_name])
		elif extension == file_extensions[2]:
			player.stream = AudioStreamWAV.load_from_file(sound_paths[sound_name])
		else:
			print("cannot play sound: invalid file type")
			player.queue_free()
			return
		add_child(player)
		player.play()
		await player.finished
		player.queue_free()
	else:
		print("cannot play sound: no such sound '" + sound_name + "'")
		play_sound_effect("test_die") # Minos Prime is a good debugging tool :3


func change_music(new_track: String):
	# To avoid errors and/or restarting a track when switching between scenes with the same music
	if music_paths.has(new_track) and new_track != last_played_music:
		var extension = music_paths[new_track].get_extension()
		# Load the file differently according to filetype (no universal audiostream type)
		if extension == file_extensions[0]:
			music_player.stream = AudioStreamOggVorbis.load_from_file(music_paths[new_track])
		elif extension == file_extensions[1]:
			music_player.stream = AudioStreamMP3.load_from_file(music_paths[new_track])
		elif extension == file_extensions[2]:
			music_player.stream = AudioStreamWAV.load_from_file(music_paths[new_track])
		else:
			print("unsupported audio type!")
		music_player.play()
		last_played_music = new_track

# For registering inputs to mute audio
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mute"):
		# Sets Main bus volume to be suuuper low
		var main_bus_id = AudioServer.get_bus_index(audio_buses[0])
		AudioServer.set_bus_mute(main_bus_id, not AudioServer.is_bus_mute(main_bus_id))

func create_particle_burst(id: int, burst_position: Vector2):
	var particle_burst = particle_burst_scene.instantiate()
	particle_burst.position = burst_position
	particle_burst.type_index = id
	add_child(particle_burst)
