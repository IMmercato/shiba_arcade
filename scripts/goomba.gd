extends CharacterBody3D

@export var speed: float = 1.0
var direction: int = 1
var can_change_direction: bool = true

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0.0

	# Forward movement (along Z axis)
	velocity.x = 0.0
	velocity.z = speed * direction

	$AnimationPlayer.play("walk")

	move_and_slide()

	# Wall check
	if detect_front_collision() and can_change_direction:
		change_direction()


func detect_front_collision() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()

		# Forward is +Z * direction (matches velocity)
		var forward = Vector3(0, 0, 1) * direction

		# If wall is in front (normal opposite to forward)
		if normal.dot(forward) < -0.5:
			return true
	return false


func change_direction():
	direction *= -1
	rotate_y(PI)  # flip visually

	velocity.z = speed * direction

	can_change_direction = false
	await get_tree().create_timer(0.2).timeout
	can_change_direction = true
