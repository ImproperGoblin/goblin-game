extends Camera2D

const SHAKE_FADE: float = 20.0
const SHAKE_SMOOTHING: float = 0.4

var shake_strength: float = 0.0

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
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
