extends Area3D

@export var attraction_strength: float = 15.0
@export var pole_position: Vector3 = Vector3.ZERO

var player: CharacterBody3D = null
var pulling: bool = false
var player_reached_pole: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	pole_position = global_transform.origin

func _physics_process(delta):
	if pulling and player and not player_reached_pole:
		var dir = (pole_position - player.global_transform.origin).normalized()
		# Apply attraction force
		player.velocity = player.velocity.lerp(dir * attraction_strength, 0.1)
		
		# Optional: snap player to pole when close enough
		if player.global_transform.origin.distance_to(pole_position) < 0.5:
			pulling = false
			player_reached_pole = true
			_on_player_reached_pole()

func _on_body_entered(body):
	if body.is_in_group("player") and not player_reached_pole:
		player = body
		pulling = true
		print("Player entered finish area")

func _on_body_exited(body):
	if body == player and not player_reached_pole:
		pulling = false
		player = null

func _on_player_reached_pole():
	print("Player reached the flag pole!")
	
	# Stop player movement
	player.velocity = Vector3.ZERO
	player.set_physics_process(false)
	player.set_process_input(false)
	
	# Play victory audio and flag animation
	play_victory_sequence()

func play_victory_sequence():
	# Play victory audio
	play_victory_audio()
	
	# Play flag pole animation
	if has_node("Flag"):
		var anim_player = get_node("Flag")
		anim_player.play("wave")  # Flag pole animation
		# Connect to animation finished signal
		if not anim_player.animation_finished.is_connected(_on_animation_finished):
			anim_player.animation_finished.connect(_on_animation_finished)
	else:
		print("No AnimationPlayer found on flag pole")
		# If no animation, show win canvas immediately
		show_win_canvas()

func play_victory_audio():
	# Play victory sound
	var audio_player = $AudioStreamPlayer3D
	add_child(audio_player)
	audio_player.play()
	# Remove the audio player after it finishes playing
	audio_player.finished.connect(audio_player.queue_free)

func _on_animation_finished(anim_name):
	if anim_name == "flag_finish":
		show_win_canvas()

func show_win_canvas():
	# Notify the super_mario script to show win canvas
	get_tree().call_group("level_manager", "on_level_completed")
	
	# Re-enable player movement after a short delay
	await get_tree().create_timer(1.0).timeout
	if player:
		player.set_physics_process(true)
		player.set_process_input(true)
		print("Player movement re-enabled")
