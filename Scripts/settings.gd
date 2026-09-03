extends Control

@export var music_slider: HScrollBar
@export var sounds_slider: HScrollBar
@export var distortion_slider: HScrollBar
@export var scanlines_slider: HScrollBar

enum { MASTER, SOUNDS, MUSIC }

var settings_music = "test_theme02"
var click_sound = "blip"
var exit_scene = "res://Scenes/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.change_music(settings_music)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		Global.transition_to_scene(exit_scene)

# Function to put the new setings into action.
func apply_preferences():
	# Audio volumes
	AudioServer.set_bus_volume_linear(MUSIC, music_slider.value)
	AudioServer.set_bus_volume_linear(SOUNDS, sounds_slider.value)
	# Shader parameters
	Global.change_shader_params(distortion_slider.value, scanlines_slider.value)


func _on_exit_button_pressed() -> void:
	Global.transition_to_scene(exit_scene)


func _on_button_mouse_entered() -> void:
	Global.play_sound_effect(click_sound)
