extends Node3D

# Goombas
@export var goomba = preload("res://scenes/goomba.tscn")

# BulletBill
@export var bulletbill = preload("res://scenes/bullet.tscn")

@export var spawn_count: int = 10
@export var spawn_range: Vector3 = Vector3(3, 0, 20)
@export var bills_spawn_range: Vector3 = Vector3(3, 2, -30)
@export var bullet_spawn_delay: float = 2.0  # Time between bullet bill spawns

# Reference to the player
var player: CharacterBody3D = null
var game_started: bool = false
var game_canvas: CanvasLayer = null
var alert_canvas: CanvasLayer = null
var game_played_before: bool = false  # Track if game has been played before
var spawning_enabled: bool = false  # Control enemy spawning
var current_spawn_timer: SceneTreeTimer = null
var enemies_spawned: bool = false  # Track if enemies have been spawned already
var total_bulletbills_spawned: int = 0
var level_completed: bool = false

func _ready():
	# Get the Area3D node and connect signals
	var area = $Area3D
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	# Load the game CanvasLayer
	game_canvas = $Game
	game_canvas.visible = false
	
	alert_canvas = $Alert
	alert_canvas.visible = false
	
	# Connect to the continue button signal
	if game_canvas.has_node("ContinueButton"):
		game_canvas.get_node("ContinueButton").pressed.connect(_on_continue_button_pressed)
		
	if alert_canvas.has_node("AlertButton"):
		alert_canvas.get_node("AlertButton").pressed.connect(_on_alert_button_pressed)
	
	randomize()

func _input(event):
	# Check for spacebar or mouse click to start the game
	if player and not game_started and game_canvas.visible and not game_played_before:
		if event.is_action_pressed("enter"):
			_start_game()

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		player = body
		print("Player entered Mario level")
		
		# Hide alert canvas when player returns to the area
		if alert_canvas and alert_canvas.visible:
			alert_canvas.visible = false
		
		# Only show UI and start game if enemies haven't been spawned yet
		if not enemies_spawned:
			if not game_played_before:
				_stop_player()
				
				# Show the game CanvasLayer
				if game_canvas:
					game_canvas.visible = true
					game_canvas.layer = 128
			else:
				# If game was played before but enemies not spawned, start spawning
				game_started = true
				_start_enemy_spawning()
		else:
			# If enemies already spawned, show restart message
			_show_restart_message()
		
		# Connect to player signals or add audio component
		_setup_player_audio()

func _on_body_exited(body: Node):
	if body.is_in_group("player"):
		print("Player left Mario level")
		_cleanup_player_audio()
		
		# Stop enemy spawning
		_stop_enemy_spawning()
		
		# Show out-of-bounds warning
		_show_out_of_bounds_warning()
		
		# Hide the game CanvasLayer if it's visible
		if game_canvas and game_canvas.visible:
			game_canvas.visible = false
		
		# Reset game_started but keep game_played_before and enemies_spawned
		game_started = false
		player = null

func _on_continue_button_pressed():
	_start_game()
	
func _on_alert_button_pressed():
	_start_game()

func _start_game():
	if not game_started and player:
		game_started = true
		game_played_before = true  # Mark that game has been played
		
		# Hide the CanvasLayer
		if game_canvas:
			game_canvas.visible = false
		
		# Resume player movement
		_resume_player()
		
		# Start spawning enemies (only if not already spawned)
		if not enemies_spawned:
			_start_enemy_spawning()

func _stop_player():
	if player:
		# Disable player input and physics
		player.set_process_input(false)
		player.set_physics_process(false)
		
		# Store the current state to restore later
		player.set_meta("was_processing_input", player.is_processing_input())
		player.set_meta("was_physics_processing", player.is_physics_processing())
		
		print("Player movement stopped")

func _resume_player():
	if player:
		# Restore player input and physics
		player.set_process_input(true)
		player.set_physics_process(true)
		
		print("Player movement resumed")

func _start_enemy_spawning():
	if enemies_spawned:
		print("Enemies already spawned, skipping...")
		return
		
	spawning_enabled = true
	enemies_spawned = true  # Mark that enemies have been spawned
	total_bulletbills_spawned = 0
	
	print("Starting enemy spawning...")
	
	# Start separate coroutines for goombas and bullet bills
	_start_goomba_spawning()
	_start_bullet_bill_spawning()
	
	print("Enemy spawning initiated")

func _start_goomba_spawning():
	# Spawn goombas with delay (currently instant loop)
	for i in range(spawn_count):
		if not spawning_enabled:
			break        
		goombas_spawner()

func _start_bullet_bill_spawning():
	spawn_bulletbills()

func spawn_bulletbills():
	await get_tree().create_timer(3.0).timeout  # initial delay before first bullet
	while spawning_enabled and total_bulletbills_spawned < spawn_count:
		bulletbill_spawner()
		total_bulletbills_spawned += 1
		await get_tree().create_timer(bullet_spawn_delay).timeout

func _stop_enemy_spawning():
	spawning_enabled = false
	print("Enemy spawning stopped")

func _show_restart_message():
	# You can implement a restart message here
	print("Game already in progress! Return to finish or restart the level.")
	
	# Optional: Show a UI message to the player
	if player and player.has_method("show_message"):
		player.show_message("Return to game area! Enemies already spawned.")

func _show_out_of_bounds_warning():
	# Show warning when player leaves the game area
	print("Warning: Player left the game area!")
	alert_canvas.visible = true
	
	# Optional: Show a UI warning to the player
	if player and player.has_method("show_message"):
		player.show_message("Out of bounds! Return to game area.")

func _setup_player_audio():
	if player:
		# Add an AudioStreamPlayer3D to the player if it doesn't have one
		if not player.has_node("MarioAudio"):
			var audio_player = AudioStreamPlayer3D.new()
			audio_player.name = "MarioAudio"
			player.add_child(audio_player)
			print("MarioAudio added to player")
		else:
			print("MarioAudio already exists on player")
		
		# Load Mario sounds
		var mario_sounds = {
			"jump": preload("res://audio/mario_jump.mp3")
		}
		
		# Store sounds in player for access
		player.set_meta("mario_sounds", mario_sounds)
		print("Mario sounds loaded")

func _cleanup_player_audio():
	if player and player.has_node("MarioAudio"):
		var audio_player = player.get_node("MarioAudio")
		if audio_player:
			audio_player.queue_free()
		if player.has_meta("mario_sounds"):
			player.remove_meta("mario_sounds")
		print("Mario audio cleaned up")

func goombas_spawner():
	if goomba == null or not spawning_enabled:
		print("No Goombas!!! or spawning disabled")
		return
	
	var goomba_instance = goomba.instantiate()
	
	var x = randf_range(-spawn_range.x, spawn_range.x)
	var z = randf_range(-spawn_range.z, spawn_range.z)
	var position = Vector3(x,0,z)
	
	goomba_instance.position = position
	add_child(goomba_instance)
	print("Spawned Goomba")

func bulletbill_spawner():
	if bulletbill == null or not spawning_enabled:
		print("No Bullets!!! or spawning disabled")
		return

	var bulletbill_instance = bulletbill.instantiate()
	var x = randf_range(-bills_spawn_range.x, bills_spawn_range.x)
	var z = bills_spawn_range.z
	var y = bills_spawn_range.y
	var position = Vector3(x, y, z)

	bulletbill_instance.position = position
	add_child(bulletbill_instance)
	print("Spawned Bullet Bill")

# Optional: Add a method to reset the level completely
func reset_level():
	enemies_spawned = false
	game_played_before = false
	game_started = false
	spawning_enabled = false
	total_bulletbills_spawned = 0
	
	# Remove all existing enemies
	for child in get_children():
		if child.is_in_group("enemies") or child.has_method("is_enemy"):
			child.queue_free()
	
	print("Level reset - enemies can be spawned again")
