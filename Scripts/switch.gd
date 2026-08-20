extends Node2D

@export var sprite: AnimatedSprite2D
@export var hitbox: Area2D

signal switch_pressed

var animations = ['pressed', 'unpressed']

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func pressed_down():
	sprite.animation = animations[0]
	switch_pressed.emit()
	hitbox.set_deferred('monitorable', false)
