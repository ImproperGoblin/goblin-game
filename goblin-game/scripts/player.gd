extends CharacterBody2D

@onready var hazard_tilemap: TileMapLayer = $"../LushHazardTileMap"

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

var can_move = true
var last_safe_coords = global_position

func _physics_process(delta: float) -> void:
	
	var gravity = get_gravity()
	var current_gravity = gravity if velocity.y < 0 else gravity * 1.5
	
	# Add the gravity.
	if not is_on_floor():
		velocity += current_gravity * delta
	
	if is_on_floor():
		last_safe_coords = global_position

	if can_move:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= 0.5
			
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		
		for i in range(get_slide_collision_count()):
			var collision := get_slide_collision(i)
			var collider := collision.get_collider()
			
			if collider == hazard_tilemap:
				global_position = last_safe_coords
				break
