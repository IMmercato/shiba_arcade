extends Control

func _ready():
	# Set process mode to always process (works even when game is paused)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Start hidden
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func open_menu():
	get_tree().paused = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Show mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_menu():
	get_tree().paused = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Hide mouse (return to game's normal mouse mode)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Only process ESC when the menu is visible
	if visible and event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()

# Close Pause Menu and continue Game
func _on_close_pressed():
	close_menu()

func _on_continue_pressed():
	close_menu()
	
# Safe changer and reloader
func safe_scene_operation(operation: String, mouse_mode: int = Input.MOUSE_MODE_CAPTURED):
	get_tree().paused = false
	Input.set_mouse_mode(mouse_mode)
	call_deferred(operation)

# Restart Game
func _on_restart_pressed():
	safe_scene_operation("_reload_current_scene", Input.MOUSE_MODE_CAPTURED)
func _reload_current_scene():
	get_tree().reload_current_scene()

# Main menu function  
func _on_main_menu_pressed():
	safe_scene_operation("_change_to_main_menu", Input.MOUSE_MODE_VISIBLE)
func _change_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
