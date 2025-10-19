extends Node

@onready var dialog_label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dialog_lines := [
	"What is going on?",
	"*8-bit loud music*",
	"Is it my console, nah...",
	"What was that, a huge PacMan???",
	"Is this a dream?",
	"Gotta go and checkout.",
	"Oh no, super mario"
]

var current_line := 0

func _ready() -> void:
	_update_dialog()

func _input(event):
	if event.is_action_pressed("jump") or (event is InputEventMouseButton and event.pressed):
		_advance_dialog()

func _advance_dialog() -> void:
	# Play animation for this dialog line
	_play_animation_frame(current_line)
	
	current_line += 1
	if current_line < dialog_lines.size():
		_update_dialog()
		$AnimationPlayer.play("camera")
		if current_line == 2:
			$Console/AnimationPlayer.play("Animation")
	else:
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _update_dialog() -> void:
	dialog_label.text = dialog_lines[current_line]

func _play_animation_frame(frame_index: int) -> void:
	if animation_player.has_animation("camera"):
		var animation = animation_player.get_animation("camera")
		var max_tracks = animation.get_track_count()
		
		if max_tracks > 0:
			# Calculate time based on frame index (assuming 1 second per frame)
			var target_time = frame_index * 0.5
			var animation_length = animation.length
			
			# Ensure we don't exceed animation length
			target_time = min(target_time, animation_length)
			
			# Seek to specific time
			animation_player.seek(target_time, true)
