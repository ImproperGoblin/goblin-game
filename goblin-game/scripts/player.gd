extends CharacterBody2D

@onready var hazard_tilemap: TileMapLayer = $"../LushHazardTileMap"

const MAX_SPEED = 400.0
const ACCELERATION = 1200.0
const FRICTION = 1400.0
const JUMP_VELOCITY = -800.0
const COYOTE_TIME_LENGTH = 0.1

var last_safe_coords = global_position
var can_move = true
var coyote_timer = 0

func _physics_process(delta: float) -> void:
	var gravity = get_gravity()
	var current_gravity = gravity if velocity.y < 0 else gravity * 1.5
	
	# Add the gravity.
	if not is_on_floor():
		coyote_timer += delta
		velocity += current_gravity * delta
		
	if is_on_floor():
		coyote_timer = 0
		last_safe_coords = global_position

	if can_move:
		if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer <= COYOTE_TIME_LENGTH):
			_jump()

		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= 0.5

		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

		move_and_slide()
		_process_spike_reset()
		
		print(coyote_timer)

func _jump() -> void:
	velocity.y = JUMP_VELOCITY
	
func _process_spike_reset() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider == hazard_tilemap:
			global_position = last_safe_coords
			break
