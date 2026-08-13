extends Node

var save_path = "user://data.save"
var levels_completed: Dictionary = {}
var levels_master: Dictionary = {
	"level_1": false,
	"level_2": false,
	"level_3": false,
	"level_4": false,
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
	"crystal": "res://Assets/Audio/crystal_teleport.wav",
	"apple": "res://Assets/Audio/apple_eat.wav",
	"fall_into_pit": "res://Assets/Audio/pitfall.wav",
	"box_scoot": "res://Assets/Audio/box_scoot.wav",
}
var music_paths: Dictionary = {
	"test_theme02": "res://Assets/Audio/Theme test 02.mp3",
	"test_theme01": "res://Assets/Audio/Theme test 01.ogg"
}
var menu_music = "test_theme02"
var music_player: AudioStreamPlayer
var last_played_music: String
var file_extensions = ['ogg', 'mp3', 'wav']
var audio_buses = ["Master", "Sound Effects"]

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
func transition_to_scene(scene_path):
	# Unhides the transition effect layer, tweens its material until the screen is obscured,
	# Changes the scene, and then reverses the obscurement
	print("transitioning to " + scene_path) # Debug
	transition_layer.visible = true
	var transition_tween = create_tween()
	transition_material.set_shader_parameter("progress", 0.0)
	transition_tween.tween_property(transition_material, "shader_parameter/progress", 1.0, transition_duration / 2).set_trans(trans_type)
	transition_tween.tween_callback(get_tree().change_scene_to_file.bind(scene_path))
	transition_tween.tween_callback(print.bind("changing scene")) # Debug
	transition_tween.tween_property(transition_material, "shader_parameter/progress", 0.0, transition_duration / 2).set_trans(trans_type)
	transition_tween.tween_callback(print.bind("transition finished")) # Debug
	transition_tween.tween_callback(transition_layer.set.bind("visible", false))

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
		add_child(player)
		player.play()
		await player.finished
		player.queue_free()
	else:
		print("cannot play: no such sound '" + sound_name + "'")
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
