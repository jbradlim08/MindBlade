extends Node2D

class_name Crosshair

@onready var anim: AnimationPlayer = $AnimationPlayer

const NORMAL: String = "normal"
const RED: String = "red"

func set_crosshair(state: String) -> void:
	anim.play(state)
