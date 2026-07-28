extends Node2D

@export var shockwave: PackedScene
const CROSSHAIR = preload("res://scene/crosshair.tscn")

func _ready() -> void:
	SignalManager.on_blade_platform.connect(spawn_shockwave)
	SignalManager.on_right_click.connect(spawn_crosshair)

func spawn_shockwave(pos: Vector2) -> void:
	print('shocked')
	var sw = shockwave.instantiate()
	sw.global_position = pos
	call_deferred("add_child", sw)

func spawn_crosshair(pos: Vector2, has_blade: bool) -> void:
	var ch = CROSSHAIR.instantiate()
	add_child(ch)

	ch.global_position = pos
	if has_blade:
		ch.set_crosshair(Crosshair.CrosshairState.NORMAL)
	else:
		ch.set_crosshair(Crosshair.CrosshairState.RED)
