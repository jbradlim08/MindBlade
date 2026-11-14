extends Control

enum SceneType{
	BASE,
	LEVEL
}

@export var type: SceneType

func _on_button_pressed() -> void:
	if type == SceneType.BASE:
		print('go to level')
		SceneManager.load_level_scene()
	elif type == SceneType.LEVEL:
		print('go to base')
		SceneManager.load_base_scene()
