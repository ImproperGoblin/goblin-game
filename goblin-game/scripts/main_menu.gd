extends Control

func _ready() -> void:
	UIManager._hide_gameplay_ui()

func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")

func _on_button_option_pressed() -> void:
	pass # Replace with function body.

func _on_button_quit_pressed() -> void:
	get_tree().quit()
