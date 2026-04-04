extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -1000.0
var can_move = true	

func _physics_process(delta: float) -> void:
	
	var gravity = get_gravity()
	var current_gravity = gravity if velocity.y < 0 else gravity * 1.5
	
	# Add the gravity.
	if not is_on_floor():
		velocity += current_gravity * delta

	if can_move:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		if Input.is_action_just_released("ui_accept") and velocity.y < 0:
			velocity.y *= 0.5 

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
