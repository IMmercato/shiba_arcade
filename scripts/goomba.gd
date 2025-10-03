extends CharacterBody3D

@export var speed: float = 1.0
var direction := 1  # 1 = forward, -1 = backward

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Move in Z direction based on current direction
	velocity = transform.basis.z * speed * direction
	move_and_slide()

	# Check collisions

# func _play_goomba_react():
	if has_node("GoombaAudio"):
		var audio = get_node("GoombaAudio")
		audio.play()
	# Optional: queue_free() or animation trigger
