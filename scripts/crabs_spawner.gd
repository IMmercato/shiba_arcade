extends Node3D

@export var crab_scene = preload("res://scenes/aliens.tscn")
@export var rows: int = 5
@export var columns: int = 10
@export var spacing: float = 1.5
@export var move_interval: float = 0.5  # Time between movements

var crabs = []
var move_direction = 1  # 1 for right, -1 for left

func _ready():
	# Create and configure the timer
	var timer = Timer.new()
	timer.wait_time = move_interval
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()
	
	spawn_crabs()
	print("Spawner ready with timer!")

func spawn_crabs():
	if not crab_scene:
		print("ERROR: Crab scene not loaded!")
		return
	
	for row in range(rows):
		for col in range(columns):
			var spawn_pos = Vector3(
				col * spacing - (columns * spacing) / 2,
				-row * spacing,
				0
			)
			var crab = crab_scene.instantiate()
			crab.position = spawn_pos
			add_child(crab)
			crabs.append(crab)
	print("Spawned ", rows * columns, " crabs!")

func _on_timer_timeout():
	move_formation()

func move_formation():
	var should_move_down = false
	
	# Check if any crab is at the edge
	for crab in crabs:
		if is_instance_valid(crab):
			# Check right edge
			if crab.global_position.x > 8 and move_direction > 0:
				should_move_down = true
				break
			# Check left edge
			if crab.global_position.x < -8 and move_direction < 0:
				should_move_down = true
				break
	
	if should_move_down:
		move_direction *= -1  # Change direction
		move_all_crabs_down()
		print("Formation moving down!")
	else:
		move_all_crabs_horizontal()
		print("Formation moving horizontal")

func move_all_crabs_horizontal():
	for crab in crabs:
		if is_instance_valid(crab):
			crab.position.x += move_direction * 0.5  # Move sideways

func move_all_crabs_down():
	for crab in crabs:
		if is_instance_valid(crab):
			crab.position.y -= 0.5  # Move down
