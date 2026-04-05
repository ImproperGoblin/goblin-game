extends Node

const MAX_PLAYER_HP: int = 6

var player_hp: int = MAX_PLAYER_HP

func _ready() -> void:
	pass # Replace with function body.

func _get_player_hp() -> int:
	return player_hp

func _reduce_player_hp(hp_to_reduce: int = 1) -> int:
	player_hp = max(player_hp - hp_to_reduce, 0)
	return player_hp

func _reset_game_state():
	player_hp = MAX_PLAYER_HP
