extends CharacterBody3D

@export var speed: float = 1.0
var direction := 1
var can_change_direction: bool = true

@onready var front_ray = $FrontRayCast3D

func _ready():
	# Add a RayCast3D as a child node to detect obstacles in front
	if not has_node("FrontRayCast3D"):
		var ray = RayCast3D.new()
		ray.name = "FrontRayCast3D"
		ray.enabled = true
		ray.target_position = Vector3(0, 0, -1)  # Point forward in local space
		ray.collision_mask = collision_mask
		add_child(ray)
		front_ray = ray

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Move in Z direction based on current direction
	velocity = transform.basis.z * speed * direction
	$AnimationPlayer.play("walk")
	
	move_and_slide()
	
	# Check for collisions using raycast
	if front_ray.is_colliding() and can_change_direction:
		change_direction()

func change_direction():
	direction *= -1
	rotate_y(PI)
	
	can_change_direction = false
	await get_tree().create_timer(0.5).timeout
	can_change_direction = true
