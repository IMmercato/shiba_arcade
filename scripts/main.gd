extends Node

@onready var pause_menu = $"Menu/Pause Menu"

func _ready():
	pause_menu.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()

func toggle_pause_menu():
	if get_tree().paused:
		# If already paused, close the menu
		pause_menu.close_menu()
	else:
		# If not paused, open the menu
		pause_menu.open_menu()
