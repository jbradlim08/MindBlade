extends Node2D

class_name Crosshair

@onready var anim: AnimationPlayer = $AnimationPlayer

enum CrosshairState {
	NORMAL,
	RED
}

func set_crosshair(state: CrosshairState) -> void:
	anim.play(stringify(state))

func stringify(state) -> String:
	match state:
		CrosshairState.NORMAL:
			return "normal"
		CrosshairState.RED:
			return "red"
		_:
			return "normal"
