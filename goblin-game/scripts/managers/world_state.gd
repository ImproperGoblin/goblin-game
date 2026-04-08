extends Node

var _flags: Dictionary = {}

func set_flag(id: String, value) -> void:
	_flags[id] = value

func get_flag(id: String, default_value = null):
	return _flags.get(id, default_value)

func has_flag(id: String) -> bool:
	return _flags.has(id)

func is_true(id: String) -> bool:
	return _flags.get(id, false) == true

func erase_flag(id: String) -> void:
	_flags.erase(id)

func clear() -> void:
	_flags.clear()
