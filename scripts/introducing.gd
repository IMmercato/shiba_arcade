extends Node

@onready var dialog_label: Label = $Label
@onready var animation_label: AnimationPlayer = $AnimationPlayer

var dialog_lines := [
	"Good Evening!",
	"TV: ALIEN invade Earth...",
	"Reporter: Is that a giant Pacman??? Run!!!",
	"You: What is going on here?",
	"Gotta go and checkout.",
	"Let him cook",
    "Oh no, super mario"
]

var current_line := 0
var waiting_for_click := true
var ready_to_update := false

func _ready() -> void:
	animation_label.connect("animation_finished", Callable(self, "_on_animation_finished"))
	_update_dialog()

func _input(event):
	if not waiting_for_click:
		return

	if event.is_action_pressed("jump") or (event is InputEventMouseButton and event.pressed):
		waiting_for_click = false
		animation_label.play("label")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "label":
		current_line += 1
		if current_line < dialog_lines.size():
			_update_dialog()
			waiting_for_click = true
		else:
			get_tree().change_scene_to_file("res://scenes/main.tscn")

func _update_dialog() -> void:
	dialog_label.text = dialog_lines[current_line]
