extends CharacterBody3D

# --- Player settings ---
const SPEED := 2.5
const JUMP_VELOCITY := 5

func _ready():
	# Add to player group
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor(): 
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor(): 
		velocity.y = JUMP_VELOCITY 
		$player/AnimationPlayer.play("Human Armature|Jump")
		_play_mario_sound("jump")
	
	var input_dir := Input.get_vector("left", "right", "front", "back") 
	var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized() 
	
	if direction: 
		velocity.x = direction.x * SPEED 
		velocity.z = direction.z * SPEED 
		$player/AnimationPlayer.play("Human Armature|Walk")
	else: 
		velocity.x = move_toward(velocity.x, 0, SPEED) 
		velocity.z = move_toward(velocity.z, 0, SPEED) 
	
	move_and_slide()

func _play_mario_sound(sound_name: String):
	# Check if we have Mario sounds and audio player
	if has_meta("mario_sounds") and has_node("MarioAudio"):
		var mario_sounds = get_meta("mario_sounds")
		var audio_player = get_node("MarioAudio")
		
		if mario_sounds.has(sound_name) and audio_player:
			audio_player.stream = mario_sounds[sound_name]
			audio_player.play()
