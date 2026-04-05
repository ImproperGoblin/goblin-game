extends Control

func _ready() -> void:
	pass # Replace with function body.

func _activate() -> void:
	show()
	get_tree().paused = true

func _on_button_continue_pressed() -> void:
	get_tree().paused = false
	GameState.player_hp = GameState.MAX_PLAYER_HP
	get_tree().change_scene_to_file("res://scenes/levels/main.tscn")

func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _on_button_main_menu_pressed() -> void:
	get_tree().paused = false
	GameState._reset_game_state()
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
