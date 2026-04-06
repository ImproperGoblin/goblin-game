extends Control

func _on_button_continue_pressed() -> void:
	MenuManager._resume_game()

func _on_button_main_menu_pressed() -> void:
	GameState._reset_game_state()
	MenuManager._resume_game()
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")

func _on_button_quit_pressed() -> void:
	MenuManager._exit_game()
