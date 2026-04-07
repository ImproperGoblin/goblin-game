extends Camera2D

@export var target: Node2D 

const SHAKE_FADE: float = 20.0
const SHAKE_SMOOTHING: float = 0.4

var shake_strength: float = 0.0

var collision_shape_2d: CollisionShape2D

func _process(delta: float) -> void:
	if target:
		global_position = target.global_position
		
	if shake_strength > 0:
		var target_offset := Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		offset = offset.lerp(target_offset, SHAKE_SMOOTHING)
		shake_strength = move_toward(shake_strength, 0.0, SHAKE_FADE * delta)
	else:
		offset = offset.lerp(Vector2.ZERO, SHAKE_SMOOTHING)

func apply_shake(strength: float) -> void:
	shake_strength = max(shake_strength, strength)

func set_camera_limits() -> void:
	var shape : Shape2D = collision_shape_2d.shape
	var local_rect : Rect2 = shape.get_rect()
	
	var global_pos = collision_shape_2d.global_transform.origin + local_rect.position
	
	var camera_limit : Rect2i = Rect2i(Vector2i(global_pos), Vector2i(local_rect.size))
	
	limit_left = camera_limit.position.x
	limit_top = camera_limit.position.y
	limit_right = (camera_limit.position.x + camera_limit.size.x)
	limit_bottom = (camera_limit.position.y + camera_limit.size.y)
	
	pass
