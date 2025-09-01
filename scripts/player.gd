extends CharacterBody3D

# --- Player settings ---
const SPEED := 2.5
const JUMP_VELOCITY := 3

func _physics_process(delta: float) -> void: # Add the gravity.
	if not is_on_floor(): 
		$Camera3D.rotation.x = deg_to_rad(0) 
		$player/AnimationPlayer.play("Human Armature|Jump") 
		velocity += get_gravity() * delta 
	else: 
		$Camera3D.rotation.x = deg_to_rad(-25) # Handle jump. 
		
	if Input.is_action_just_pressed("jump") and is_on_floor(): 
		velocity.y = JUMP_VELOCITY 
	# Get the input direction and handle the movement/deceleration. 
	# As good practice, you should replace UI actions with custom gameplay actions. 
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
