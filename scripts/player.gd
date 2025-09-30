extends CharacterBody3D

# --- Player settings ---
const SPEED := 2.5
const JUMP_VELOCITY := 5
const SENSITIVITY := 0.005

@onready var camera = $Camera3D
var current_sensitivity := SENSITIVITY

func _ready():
	# Mouse Control
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Add to player group
	add_to_group("player")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Block camera rotation during jump
		if not is_on_floor():
			return

		# Slow down rotation while walking
		var input_dir := Input.get_vector("left", "right", "front", "back")
		if input_dir.length() > 0.1:
			current_sensitivity = SENSITIVITY * 0.5  # Reduced sensitivity while walking
		else:
			current_sensitivity = SENSITIVITY  # Normal sensitivity when idle

		# Apply rotation
		rotate_y(-event.relative.x * current_sensitivity)
		camera.rotate_x(-event.relative.y * current_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

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
		velocity.x = 0.0
		velocity.z = 0.0
	
	move_and_slide()

func _play_mario_sound(sound_name: String):
	# Check if we have Mario sounds and audio player
	if has_meta("mario_sounds") and has_node("MarioAudio"):
		var mario_sounds = get_meta("mario_sounds")
		var audio_player = get_node("MarioAudio")
		
		if mario_sounds.has(sound_name) and audio_player:
			audio_player.stream = mario_sounds[sound_name]
			audio_player.play()
