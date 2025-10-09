extends CharacterBody3D

@export var speed: float = 1.0
var direction := 1
var can_change_direction: bool = true

func _ready():
	# Make sure collision detection is enabled
	collision_layer = 1
	collision_mask = 1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity = transform.basis.z * speed * direction
	$AnimationPlayer.play("walk")
	
	move_and_slide()
	
	# Check for wall collisions and change direction
	if detect_front_collision() and can_change_direction:
		change_direction()

func detect_front_collision() -> bool:
	# Get all collisions from the last move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		
		# Check if this is a front-facing collision
		var collision_normal = collision.get_normal()
		var forward_dir = -transform.basis.z * direction  # Actual movement direction
		
		# If the collision is roughly in front of us, treat it as a wall
		if collision_normal.dot(forward_dir) < -0.5:
			return true
	
	return false

func change_direction():
	direction *= -1
	rotate_y(PI)
	
	# Move away from the wall slightly to prevent sticking
	var move_away = transform.basis.z * 0.2
	global_translate(move_away)
	
	can_change_direction = false
	await get_tree().create_timer(0.5).timeout  # Reduced cooldown
	can_change_direction = true
