extends Node2D

@export var shockwave: PackedScene

func _ready() -> void:
	SignalManager.on_blade_platform.connect(spawn_shockwave)

func spawn_shockwave(pos: Vector2) -> void:
	print('shocked')
	var sw = shockwave.instantiate()
	sw.global_position = pos
	call_deferred("add_child", sw)
