extends VehicleBody3D

@export var MAX_STEER := 0.9
@export var ENGINE_POWER := 300

var player_nearby := false
var driver: CharacterBody3D = null

func _ready() -> void:
	$CarCamera.current = false # Ensure car camera starts inactive

func _process(delta: float) -> void:
	if InputManager.driver == self:
		# Driving logic
		steering = move_toward(steering, InputManager.get_steering() * MAX_STEER, delta * 10)
		engine_force = InputManager.get_throttle() * ENGINE_POWER

		if Input.is_action_just_pressed("exit"):
			_exit_car()
	else:
		steering = 0
		engine_force = 0

		if player_nearby and Input.is_action_just_pressed("enter"):
			_enter_car()

func _on_car_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		print("Player nearby")

func _on_car_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		print("Player left")

func _enter_car() -> void:
	InputManager.driver = self
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p.global_position.distance_to(global_position) < 5.0:
			driver = p
			p.global_position = global_position + Vector3(0, 1, 0) # Move player inside car
			p.set_process(false)
			p.set_physics_process(false)
			p.visible = false
			p.set_collision_layer_value(1, false)
			p.set_collision_mask_value(1, false)

			if p.has_node("PlayerCamera"):
				p.get_node("PlayerCamera").current = false
			$CarCamera.current = true

			print("Entered car")
			break

func _exit_car() -> void:
	InputManager.driver = null
	if driver:
		driver.global_position = global_position + Vector3(2, 0, 0)
		driver.set_process(true)
		driver.set_physics_process(true)
		driver.visible = true
		driver.set_collision_layer_value(1, true)
		driver.set_collision_mask_value(1, true)

		if driver.has_node("PlayerCamera"):
			driver.get_node("PlayerCamera").current = true
		$CarCamera.current = false

		driver = null
		print("Exited car")
