extends Node3D

# Goombas
@export var goomba = preload("res://scenes/goomba.tscn")

# BulletBill
@export var bulletbill = preload("res://scenes/bullet.tscn")

@export var spawn_count: int = 10
@export var spawn_range: Vector3 = Vector3(3, 0, 20)
@export var bills_spawn_range: Vector3 = Vector3(3, 2, -30)

# Reference to the player
var player: CharacterBody3D = null
var game_started: bool = false
var game_canvas: CanvasLayer = null

func _ready():
	# Get the Area3D node and connect signals
	var area = $Area3D
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	# Load the game CanvasLayer
	game_canvas = $Game
	game_canvas.visible = false
	
	# Connect to the continue button signal
	if game_canvas.has_node("ContinueButton"):
		game_canvas.get_node("ContinueButton").pressed.connect(_on_continue_button_pressed)
	
	randomize()

func _input(event):
	# Check for spacebar or mouse click to start the game
	if player and not game_started and game_canvas.visible:
		if event.is_action_pressed("enter"):
			_start_game()

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		player = body
		print("Player entered Mario level")
		
		# Stop the player
		_stop_player()
		
		# Show the game CanvasLayer
		if game_canvas:
			game_canvas.visible = true
			# Make sure the canvas is on top
			game_canvas.layer = 128
		
		# Connect to player signals or add audio component
		_setup_player_audio()

func _on_body_exited(body: Node):
	if body.is_in_group("player"):
		print("Player left Mario level")
		_cleanup_player_audio()
		
		# Hide the game CanvasLayer
		if game_canvas:
			game_canvas.visible = false
		
		player = null
		game_started = false

func _on_continue_button_pressed():
	_start_game()

func _start_game():
	if not game_started and player:
		game_started = true
		
		# Hide the CanvasLayer
		if game_canvas:
			game_canvas.visible = false
		
		# Resume player movement
		_resume_player()
		
		# Start spawning enemies
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
	for i in range(spawn_count):
		await get_tree().create_timer(5)
		goombas_spawner()
		
		await get_tree().create_timer(5)
		bulletbill_spawner()

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
	if goomba == null:
		print("No Goombas!!!")
		return
	
	var goomba_instance = goomba.instantiate()
	
	var x = randf_range(-spawn_range.x, spawn_range.x)
	var z = randf_range(-spawn_range.z, spawn_range.z)
	var position = Vector3(x,0,z)
	
	goomba_instance.position = position
	add_child(goomba_instance)

func bulletbill_spawner():
	if bulletbill == null:
		print("No Bullets!!!")
		return

	var bulletbill_instance = bulletbill.instantiate()
	
	var x = randf_range(-bills_spawn_range.x, bills_spawn_range.x)
	var z = bills_spawn_range.z
	var y = randf_range(bills_spawn_range.y, bills_spawn_range.y)
	var position = Vector3(x,y,z)
	
	bulletbill_instance.position = position
	add_child(bulletbill_instance)
