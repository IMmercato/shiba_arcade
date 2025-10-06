extends CharacterBody3D

@export var speed: float = 5.0

func _ready():
	collision_layer = 3
	collision_mask = 2

func _physics_process(delta):
	velocity = transform.basis.z * speed
	move_and_slide()
