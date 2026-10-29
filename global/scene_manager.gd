extends Node

const MAIN = preload("res://miscallenous/scene/game/main.tscn")
const BASE = preload("res://miscallenous/scene/game/base.tscn")
const LEVEL = preload("res://miscallenous/scene/game/level.tscn")
const TUTORIAL = preload("res://miscallenous/scene/game/tutorial.tscn")

func load_main_scene() -> void:
	get_tree().change_scene_to_packed(MAIN)

func load_base_scene() -> void:
	get_tree().change_scene_to_packed(BASE)

func load_level_scene() -> void:
	get_tree().change_scene_to_packed(LEVEL)

func load_tutorial_scene() -> void:
	get_tree().change_scene_to_packed(TUTORIAL)

func quit_game() -> void:
	get_tree().quit()
