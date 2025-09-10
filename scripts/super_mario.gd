extends Node3D

# Reference to the player
var player: CharacterBody3D = null

func _ready():
	# Get the Area3D node and connect signals
	var area = $Area3D
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		player = body
		print("Player entered Mario level")
		# Connect to player signals or add audio component
		_setup_player_audio()

func _on_body_exited(body: Node):
	if body.is_in_group("player"):
		print("Player left Mario level")
		_cleanup_player_audio()
		player = null

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
		
		
