extends Node2D

@export var sprite: AnimatedSprite2D
@export var hitbox: Area2D

signal switch_pressed

var animations = ['pressed', 'unpressed']
var click_sound = "button press"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Changes the sprite and emits a signal for the level to handle
func pressed_down():
	# Create a particle effect
	Global.create_particle_burst(Global.ParticleTypes.SWITCH, global_position)
	# Play the appropriate sound
	Global.play_sound_effect(click_sound)
	sprite.animation = animations[0]
	switch_pressed.emit()
	hitbox.queue_free() # Set_deferred wasn't working for some reason
