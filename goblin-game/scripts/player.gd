extends CharacterBody2D

const MAX_SPEED: float = 400.0
const ACCELERATION: float = 1200.0
const FRICTION: float = 1400.0
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

@onready var hazard_tilemap: TileMapLayer = $"../LushHazardTileMap"
@onready var camera: Camera2D = $Camera2D
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_menu: Control = $"../../HUD/DeathMenu"


@onready var last_safe_coords: Vector2 = global_position
@onready var room_start_coordinates: Vector2 = global_position

var can_move: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var buffered_jump: bool = false
var jump_boost: float = 1.0

var is_iframes: bool = false
var hitstop_active: bool = false

var heart_1_state: int = -1
var heart_2_state: int = -1
var heart_3_state: int = -1

const ANIMATION = {
	"IDLE": "idle",
	"JUMP": "jump",
	"RUNNING": "running",
	"STATIC_FULL": "static_full",
	"STATIC_HALF": "static_half",
	"STATIC_EMPTY": "static_empty",
	"FULL_TO_HALF": "full_to_half",
	"HALF_TO_EMPTY": "half_to_empty",
	"FULL_TO_EMPTY": "full_to_empty"
}

func _ready() -> void:	
	_update_hearts()

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
		animation = ANIMATION.JUMP
		
	if $AnimatedSprite2D.animation != animation:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.animation = animation
		$AnimatedSprite2D.play()

func _update_hearts() -> void:
	heart_1_state = _set_heart($"../../HUD/HeartContainer1", heart_1_state, clampi(GameState.player_hp, 0, 2))
	heart_2_state = _set_heart($"../../HUD/HeartContainer2", heart_2_state, clampi(GameState.player_hp - 2, 0, 2))
	heart_3_state = _set_heart($"../../HUD/HeartContainer3", heart_3_state, clampi(GameState.player_hp - 4, 0, 2))

func _set_heart(heart: AnimatedSprite2D, old_state: int, new_state: int) -> int:
	if(!heart):
		return 1
		
	if old_state == new_state:
		return old_state
	
	match new_state:
		2:
			heart.play(ANIMATION.STATIC_FULL)
		1:
			if old_state == 2:
				heart.play(ANIMATION.FULL_TO_HALF)
			else:
				heart.play(ANIMATION.STATIC_HALF)
		0:
			if old_state == 2:
				heart.play(ANIMATION.FULL_TO_EMPTY)
			elif old_state == 1:
				heart.play(ANIMATION.HALF_TO_EMPTY)
			else:
				heart.play(ANIMATION.STATIC_EMPTY)
	
	return new_state

func _bounce_away_from_enemy(enemy: Node2D) -> void:
	var dir := (global_position - enemy.global_position).normalized()
	
	velocity.x = dir.x * ENEMY_BOUNCE_FORCE_X
	velocity.y = ENEMY_BOUNCE_FORCE_Y
	
func _reduce_hp(reduce_amount: int) -> void:
	if is_iframes or GameState.player_hp <= 0:
		return
	
	_hitstop()
	GameState.player_hp = max(GameState.player_hp - reduce_amount, 0)
	_update_hearts()
	
	if GameState.player_hp == 0:
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
	if death_menu != null:
		death_menu._activate()
