extends Node

const LEVEL = preload("res://scene/game/level.tscn")
const MAIN_MENU = preload("res://scene/game/main_menu.tscn")

var checkpoint_pos: Vector2

func get_checkpoint_pos() -> Vector2: return checkpoint_pos
func set_checkpoint_pos(val: Vector2)-> void: checkpoint_pos = val

func load_main_scene() -> void:
	get_tree().change_scene_to_packed(MAIN_MENU)

func load_level_scene() -> void:
	get_tree().change_scene_to_packed(LEVEL)

func quit_game() -> void:
	get_tree().quit()
