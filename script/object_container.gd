extends Node2D

const SHOCKWAVE = preload("res://scene/shockwave.tscn")
const CROSSHAIR = preload("res://scene/crosshair.tscn")
const AIR = preload("res://scene/air.tscn")

func _ready() -> void:
	SignalManager.on_blade_platform.connect(spawn_shockwave)
	SignalManager.on_throw_blade.connect(spawn_crosshair)
	SignalManager.on_jump_on_air.connect(spawn_air)

func spawn_shockwave(pos: Vector2) -> void:
	var sw = SHOCKWAVE.instantiate()
	sw.global_position = pos
	call_deferred("add_child", sw)

func spawn_crosshair(pos: Vector2, has_blade: bool) -> void:
	var ch = CROSSHAIR.instantiate()
	add_child(ch)

	ch.global_position = pos
	if has_blade:
		ch.set_crosshair(Crosshair.NORMAL)
	else:
		ch.set_crosshair(Crosshair.RED)

func spawn_air(pos: Vector2) -> void:
	var air = AIR.instantiate()
	air.global_position = pos
	call_deferred("add_child", air)
