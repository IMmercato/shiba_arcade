extends CharacterBody3D

@export var speed : float = 5.0

func _ready() -> void:
	var anim_player = $pacman/AnimationPlayer
	var anim = anim_player.get_animation("Armature|ArmatureAction")
	
	if anim:
		anim.loop = true
	anim_player.play("Armature|ArmatureAction")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0.0
		
	velocity = transform.basis.z * speed
	move_and_slide()
