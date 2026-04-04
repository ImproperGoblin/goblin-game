extends CharacterBody2D

@onready var hazard_tilemap: TileMapLayer = $"../LushHazardTileMap"

const MAX_SPEED = 400.0
const ACCELERATION = 1200.0
const FRICTION = 1400.0
const JUMP_VELOCITY = -800.0
const COYOTE_TIME_LENGTH = 0.1
const JUMP_BUFFER_MIN = 0.2

var last_safe_coords = global_position
var can_move = true
var coyote_timer = 0
var jump_buffer_timer = 0
var buffered_jump = false
var jump_boost = 1

func _physics_process(delta: float) -> void:
	var gravity = get_gravity()
	var current_gravity = gravity if velocity.y < 0 else gravity * 1.5
	
	if is_on_floor():
		if $JumpRay.is_colliding():
			_set_jump_boost(1)
		coyote_timer = 0
		jump_buffer_timer = 0
		
		if $JumpRay.is_colliding():
			last_safe_coords = global_position
		
		if buffered_jump:
			_jump()
			buffered_jump = false
	else:
		coyote_timer += delta
		jump_buffer_timer += delta
		velocity += current_gravity * delta

	if can_move:
		if Input.is_action_just_pressed("jump"):
			if (is_on_floor() or coyote_timer <= COYOTE_TIME_LENGTH):
				_jump()
				
			if $JumpRay.is_colliding() and !is_on_floor() and jump_buffer_timer > JUMP_BUFFER_MIN:
				buffered_jump = true
				
		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= 0.5

		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = move_toward(velocity.x, direction * MAX_SPEED * jump_boost, ACCELERATION * delta * jump_boost)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

		move_and_slide()
		_process_spike_reset()
		
func _jump() -> void:
	velocity.y = JUMP_VELOCITY
	
func _process_spike_reset() -> void:
	
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider == hazard_tilemap:
			global_position = last_safe_coords
			break
			
func _set_jump_boost(multiplier: float):
	jump_boost = multiplier;
