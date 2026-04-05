extends CharacterBody2D

@onready var hazard_tilemap: TileMapLayer = $"../LushHazardTileMap"

const MAX_SPEED: float = 400.0
const ACCELERATION: float = 1200.0
const FRICTION: float = 1400.0
const JUMP_VELOCITY: float = -800.0
const COYOTE_TIME_LENGTH: float = 0.1
const JUMP_BUFFER_MIN: float = 0.2

var last_safe_coords: Vector2 = Vector2(0.0, 0.0)
var room_start_coordinates: Vector2 = Vector2(0.0, 0.0)
var can_move: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var buffered_jump: bool = false
var jump_boost: float = 1.0

func _ready() -> void:	
	last_safe_coords = global_position
	room_start_coordinates = global_position

	for ft in get_tree().get_nodes_in_group("flytrap"):
		ft.flytrap_damage_player.connect(_on_flytrap_damage)

func _physics_process(delta: float) -> void:
	var gravity = get_gravity()
	var current_gravity = gravity if velocity.y < 0 else gravity * 1.5

	if is_on_floor():
		if $JumpRay.is_colliding():
			_set_jump_boost(1)
		coyote_timer = 0
		jump_buffer_timer = 0
		
		if $JumpRay.is_colliding() and 'VenusFlyTrap' not in $JumpRay.get_collider().get_parent().name:
			_set_safe_pos()
		
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
			_reset_to_safe_pos()
			break

func _set_jump_boost(multiplier: float):
	jump_boost = multiplier;

func _reset_to_room_start() -> void:
	global_position = room_start_coordinates

func _reset_to_safe_pos() -> void:
	global_position = last_safe_coords

func _set_safe_pos() -> void:
	last_safe_coords = global_position
	
func _on_flytrap_damage(player) -> void:
	if player == self:
		_reset_to_safe_pos()
