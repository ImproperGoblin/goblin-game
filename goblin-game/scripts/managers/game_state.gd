extends Node

var __flags: Dictionary = {}

func _set_flag(id: String, value) -> void:
	__flags[id] = value
	
func _get_flag(id: String, default_value = null):
	return __flags.get(id, default_value)

func _has_flag(id: String) -> bool:
	return __flags.has(id)
