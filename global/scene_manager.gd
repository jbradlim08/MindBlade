extends Node

const LEVEL = preload("res://scene/game/level.tscn")
const MAIN_MENU = preload("res://scene/game/main_menu.tscn")

func load_main_scene() -> void:
	get_tree().change_scene_to_packed(MAIN_MENU)

func load_level_scene() -> void:
	get_tree().change_scene_to_packed(LEVEL)

func quit_game() -> void:
	get_tree().quit()
