extends CharacterBody2D

const MAX_SPEED: float = 400.0
const ACCELERATION: float = 1200.0
const FRICTION: float = 1400.0
const JUMP_VELOCITY: float = -800.0
const COYOTE_TIME_LENGTH: float = 0.1
const JUMP_BUFFER_MIN: float = 0.2

const ENEMY_BOUNCE_FORCE_X: float = 800.0
const ENEMY_BOUNCE_FORCE_Y: float = -600.0

const MAX_HP: int = 6

@onready var hazard_tilemap: TileMapLayer = $"../LushHazardTileMap"
@onready var camera: Camera2D = $Camera2D

@onready var last_safe_coords: Vector2 = global_position
@onready var room_start_coordinates: Vector2 = global_position

var can_move: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var buffered_jump: bool = false
var jump_boost: float = 1.0

var current_hp = MAX_HP

const ANIMATION = {
	"IDLE": "idle",
	"JUMP": "jump",
	"RUNNING": "running",
	"STATIC_FULL": "static_full",
	"STATIC_HALF": "static_half",
	"HALF": "lose_to_half",
	"EMPTY": "lose_to_empty"
}

func _ready() -> void:	
	$HUD/HeartContainer1.animation = ANIMATION.STATIC_FULL
	$HUD/HeartContainer2.animation = ANIMATION.STATIC_FULL
	$HUD/HeartContainer3.animation = ANIMATION.STATIC_FULL

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
			$AnimatedSprite2D.flip_h = direction == -1
			_set_animation(ANIMATION.RUNNING)
			velocity.x = move_toward(velocity.x, direction * MAX_SPEED * jump_boost, ACCELERATION * delta * jump_boost)
		else:
			_set_animation(ANIMATION.IDLE)
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

		move_and_slide()
		_process_spike_reset()
		
func _jump() -> void:
	velocity.y = JUMP_VELOCITY
	_set_animation(ANIMATION.JUMP)
	
func _process_spike_reset() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider == hazard_tilemap:
			_reset_to_safe_pos()
			_reduce_hp(1)
			break

func _set_jump_boost(multiplier: float):
	jump_boost = multiplier;

func _reset_to_room_start() -> void:
	global_position = room_start_coordinates

func _reset_to_safe_pos() -> void:
	global_position = last_safe_coords

func _set_safe_pos() -> void:
	last_safe_coords = global_position
	
func _set_animation(animation: String) -> void:
	if !is_on_floor():
		print("jump")
		animation = ANIMATION.JUMP
		
	if $AnimatedSprite2D.animation != animation:
		if animation == ANIMATION.JUMP:
			print("animated")
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.animation = animation
		$AnimatedSprite2D.play()


func _bounce_away_from_enemy(enemy: Node2D) -> void:
	var dir := (global_position - enemy.global_position).normalized()
	
	velocity.x = dir.x * ENEMY_BOUNCE_FORCE_X
	velocity.y = ENEMY_BOUNCE_FORCE_Y
	
func _reduce_hp(reduce_amount: int) -> int:
	current_hp -= reduce_amount if current_hp >= 1 else 0
	
	camera.apply_shake(8.0)
	
	if current_hp == 0:
		_die()
	
	return current_hp
	
func _die() -> void:
	get_tree().reload_current_scene()
