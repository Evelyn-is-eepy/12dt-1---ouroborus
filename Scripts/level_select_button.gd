extends Button

var level_reference: String
var level_select_control: Control

signal level_selected(referenced_level)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("level_selected",level_select_control.level_selected)
	pass # Replace with function body.

func _on_pressed() -> void:
	level_selected.emit(level_reference)
