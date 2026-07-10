extends Node2D

const SHOCKWAVE = preload("res://Scene/shockwave.tscn")

@onready var container: Node2D = $Container

func _ready() -> void:
	SignalManager.on_blade_platform.connect(init_shockwave)

func init_shockwave(pos: Vector2) -> void:
	print('shocked')
	var shockwave = SHOCKWAVE.instantiate()
	shockwave.global_position = pos
	container.call_deferred("add_child", shockwave)
