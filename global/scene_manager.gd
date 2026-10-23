extends Node

const LEVEL = preload("res://miscallenous/scene/game/level.tscn")
const MAIN = preload("res://miscallenous/scene/game/main.tscn")

func load_main_scene() -> void:
	get_tree().change_scene_to_packed(MAIN)

func load_level_scene() -> void:
	get_tree().change_scene_to_packed(LEVEL)

func quit_game() -> void:
	get_tree().quit()
