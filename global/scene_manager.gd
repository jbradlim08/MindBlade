extends Node

const BASE = preload("res://game_scene/base.tscn")
const LEVEL = preload("res://game_scene/level.tscn")
const MAIN = preload("res://game_scene/main.tscn")
const TUTORIAL = preload("res://game_scene/tutorial.tscn")

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
