extends Node

@onready var dialog_label: Label = $Label

var dialog_lines := [
	"Good Evening!",
	"TV: ALIEN invade Earth...",
	"Reporter: Is that a gaint Pacman??? Run!!!",
	"You: What is going on here?",
	"Gotta go and checkout.",
	"You was the world second in classics games, and now is time to show that u are the N. 1#",
	"Let him cook",
	"Oh no, super mario"
]

var current_line := 0

func _ready() -> void:
	_update_dialog()

func _input(event):
	if event.is_action_pressed("jump") or (event is InputEventMouseButton and event.pressed):
		_advance_dialog()

func _advance_dialog() -> void:
	current_line += 1
	if current_line < dialog_lines.size():
		_update_dialog()
	else:
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _update_dialog() -> void:
	dialog_label.text = dialog_lines[current_line]
