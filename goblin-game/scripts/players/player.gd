extends CharacterBody2D

signal player_death

const MAX_SPEED: float = 400.0
const ACCELERATION: float = 2000.0
const FRICTION: float = 2200.0
const JUMP_VELOCITY: float = -800.0
const COYOTE_TIME_LENGTH: float = 0.1
const JUMP_BUFFER_MIN: float = 0.2

const IFRAMES: float = 1.0
const BLINK_COUNT: int = 6
const BLINK_INTERVAL: float = 0.06
const BLINK_DIM_ALPHA: float = 0.4

const HITSTOP_DURATION: float = 0.08
const HITSTOP_SCALE: float = 0.02

const ENEMY_BOUNCE_FORCE_X: float = 600.0
const ENEMY_BOUNCE_FORCE_Y: float = -400.0

@onready var camera: Camera2D = $"../PlayerCamera"
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var last_safe_coords: Vector2 = global_position
@onready var room_start_coordinates: Vector2 = global_position

var can_move: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var buffered_jump: bool = false
var jump_boost: float = 1.0

var is_iframes: bool = false
var hitstop_active: bool = false

var hazard_tilemap: TileMapLayer

const ANIMATION = {
	"IDLE": "idle",
	"JUMP": "jump",
	"RUNNING": "running",
	"DEATH": "death"
}

func _ready() -> void:	
	UIManager._update_hearts()

func _physics_process(delta: float) -> void:
	var gravity = get_gravity()
	var current_gravity = gravity if velocity.y < 0 else gravity * 1.5

	if is_on_floor():
		if $JumpRay.is_colliding():
			_set_jump_boost(1)
		coyote_timer = 0
		jump_buffer_timer = 0
		
		if $JumpRay.is_colliding() and not _is_on_or_above_node('VenusFlyTrap'):
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
			player_sprite.flip_h = direction == -1
			$FlashArea2D/FlashCollisionShape2D.position.x = 120 * direction
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
			_reduce_hp(1)
			
			if PlayerState._get_player_hp() != 0:
				_reset_to_safe_pos()
			
			break
			
func _is_on_or_above_node(node_name: String) -> bool:
	var middle_collider = $JumpRay.get_collider()
	var left_collider = $JumpRayLeft.get_collider()
	var right_collider = $JumpRayRight.get_collider()
	
	return (
		$JumpRay.is_colliding() and middle_collider and node_name in middle_collider.get_parent().name
		or $JumpRayLeft.is_colliding() and left_collider and node_name in left_collider.get_parent().name
		or $JumpRayRight.is_colliding() and right_collider and node_name in right_collider.get_parent().name
	)

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
		animation = ANIMATION.JUMP
		
	if player_sprite.animation != animation:
		player_sprite.stop()
		player_sprite.animation = animation
		player_sprite.play()

func _bounce_away_from_enemy(enemy: Node2D) -> void:
	var dir := (global_position - enemy.global_position).normalized()
	
	velocity.x = dir.x * ENEMY_BOUNCE_FORCE_X
	velocity.y = ENEMY_BOUNCE_FORCE_Y
	
func _reduce_hp(reduce_amount: int) -> void:
	if is_iframes or PlayerState._get_player_hp() <= 0:
		return

	AudioManager._play_sound_effect('hit')
	PlayerState._reduce_player_hp(reduce_amount)
	_hitstop()
	UIManager._update_hearts()
	
	if PlayerState._get_player_hp() == 0:
		camera.apply_shake(12.0)
		_die()
		return
	else:
		camera.apply_shake(8.0)

	_start_iframes()
		
func _start_iframes() -> void:
	is_iframes = true
	await _blink_sprite()
	player_sprite.modulate.a = BLINK_DIM_ALPHA
	await get_tree().create_timer(IFRAMES).timeout
	
	is_iframes = false
	player_sprite.modulate.a = 1.0

func _blink_sprite() -> void:
	for i in BLINK_COUNT:
		player_sprite.modulate.a = BLINK_DIM_ALPHA
		await get_tree().create_timer(BLINK_INTERVAL).timeout
		
		player_sprite.modulate.a = 1.0
		await get_tree().create_timer(BLINK_INTERVAL).timeout
		
func _hitstop(duration: float = HITSTOP_DURATION, scale: float = HITSTOP_SCALE) -> void:
	if not hitstop_active:
		hitstop_active = true
		Engine.time_scale = scale
		await get_tree().create_timer(duration, true, false, true).timeout
		Engine.time_scale = 1.0
		hitstop_active = false

func _die() -> void:
	AudioManager._play_sound_effect('death')
	await _play_death_animation()
	await UIManager._fade(1)
	MenuManager._show_death_menu()

func _play_death_animation() -> void:
	can_move = false
	player_sprite.stop()
	await get_tree().create_timer(1).timeout
	player_sprite.animation = ANIMATION.DEATH
	velocity.y *= 5
	player_sprite.play()
	await player_sprite.animation_finished
