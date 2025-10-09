extends CharacterBody3D

# --- Player settings ---
const SPEED := 2.5
const SPRINT_SPEED := 5.0
const JUMP_VELOCITY := 5.0
const SENSITIVITY := 0.005

# Camera Shake Settings
const SHAKE_INTENSITY := 0.1
const SHAKE_FREQUENCY := 10.0
const SHAKE_SMOOTHING := 5.0

@onready var camera = $Camera3D
var current_sensitivity := SENSITIVITY
var is_sprinting := false
var shake_timer := 0.0
var shake_strength := 0.0
var shake_fade := 5.0
var original_shake_position := Vector3.ZERO

func _ready():
	# Mouse Control
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Add to player group
	add_to_group("player")
	# Store Original CameraPosition
	original_shake_position = camera.position

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
	
	# Sprinting Mechanic
	var was_sprinting = is_sprinting
	is_sprinting = Input.is_action_pressed("sprint") and is_on_floor() and direction != Vector3.ZERO
	var current_speed = SPRINT_SPEED if is_sprinting else SPEED
	
	if direction: 
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		if is_sprinting:
			$player/AnimationPlayer.play("Human Armature|Run")
		else:
			$player/AnimationPlayer.play("Human Armature|Walk")
	else: 
		velocity.x = 0.0
		velocity.z = 0.0
		is_sprinting = false
	
	move_and_slide()
	
	_handle_camera_shake(delta)

func _handle_camera_shake(delta: float):
	if is_sprinting and is_on_floor() and velocity.length() > 0.1:
		shake_strength = lerp(shake_strength, SHAKE_INTENSITY, delta * 8.0)
	else:
		shake_strength = lerp(shake_strength, 0.0, delta * shake_fade)
	
	if shake_strength > 0.01:
		shake_timer += delta * SHAKE_FREQUENCY
		
		var shake_offset = Vector3(
			sin(shake_timer * 1.3) * shake_strength,
			cos(shake_timer * 1.7) * shake_strength * 0.8,
			sin(shake_timer * 2.1) * shake_strength * 0.3
		)
		
		camera.position = original_shake_position + shake_offset
		
	else:
		camera.position = original_shake_position
		shake_timer = 0.0

func _play_mario_sound(sound_name: String):
	# Check if we have Mario sounds and audio player
	if has_meta("mario_sounds") and has_node("MarioAudio"):
		var mario_sounds = get_meta("mario_sounds")
		var audio_player = get_node("MarioAudio")
		
		if mario_sounds.has(sound_name) and audio_player:
			audio_player.stream = mario_sounds[sound_name]
			audio_player.play()
