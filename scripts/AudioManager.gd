extends Node

# Dictionary to store all sounds
var sounds: Dictionary = {
	"mario_jump": preload("res://audio/Mario Jump - QuickSounds.com.mp3")
	# Add other sounds for different scenes here
}

func play_sound(sound_name: String, position: Vector3 = Vector3.ZERO):
	if sound_name in sounds:
		var sound = sounds[sound_name]
		_play_3d_sound(sound, position)
	else:
		print("Sound not found: ", sound_name)

func play_scene_sound(scene_group: String, sound_name: String, position: Vector3 = Vector3.ZERO):
	# Check if any node in the current scene has the specified group
	var scene_nodes = get_tree().get_nodes_in_group(scene_group)
	if scene_nodes.size() > 0:
		# Scene has the group, play the Mario sound
		var full_sound_name = scene_group + "_" + sound_name
		play_sound(full_sound_name, position)

func _play_3d_sound(sound: AudioStream, position: Vector3):
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = sound
	audio_player.position = position
	audio_player.max_distance = 10.0
	audio_player.unit_size = 2.0
	
	# Add to scene and play
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()
	
	# Clean up after sound finishes
	await audio_player.finished
	audio_player.queue_free()
