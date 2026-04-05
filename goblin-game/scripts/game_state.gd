extends Node

const __MAX_PLAYER_HP: int = 6

var __key_acquired: bool = false
var __player_hp: int = __MAX_PLAYER_HP

func _ready() -> void:
	pass # Replace with function body.

func _get_max_hp() -> int:
	return __MAX_PLAYER_HP

func _get_player_hp() -> int:
	return __player_hp

func _reduce_player_hp(hp_to_reduce: int = 1) -> int:
	__player_hp = max(__player_hp - hp_to_reduce, 0)
	return __player_hp

func _get_key_status() -> bool:
	return __key_acquired

func _set_key_status() -> void:
	__key_acquired = !__key_acquired

func _reset_game_state():
	__player_hp = __MAX_PLAYER_HP
