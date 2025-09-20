extends CharacterBody3D

@export var move_speed: float = 2.0
var move_direction: Vector3 = Vector3.RIGHT
var is_moving: bool = true

func _physics_process(delta):
	if is_moving:
		# Apply movement force
		var movement = move_direction * move_speed * delta
		position += movement

func change_direction():
	move_direction *= -1  # Reverse direction

func move_down():
	position.y -= 0.5  # Move down

func _on_visible_on_screen_notifier_3d_screen_exited():
	# When crab moves off screen, change direction and move down
	change_direction()
	move_down()
