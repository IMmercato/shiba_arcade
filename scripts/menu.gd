extends Node3D

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_leave_pressed() -> void:
	get_tree().quit()
