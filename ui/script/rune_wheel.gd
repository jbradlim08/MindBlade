extends Control

func _ready() -> void:
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("rune"):
		global_position = get_global_mouse_position()
		show()
	if event.is_action_released("rune"):
		hide()
