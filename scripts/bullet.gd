extends CharacterBody3D

@export var speed: float = 5.0

func _physics_process(delta):
	velocity = transform.basis.z * speed
	move_and_slide()
