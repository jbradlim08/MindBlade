extends Node2D

# vfx
const AIR = preload("res://vfx/scene/air.tscn")
const CROSSHAIR = preload("res://vfx/scene/crosshair.tscn")
const SHOCKWAVE = preload("res://vfx/scene/shockwave.tscn")
const SLASH = preload("res://vfx/scene/slash.tscn")
const TRAIL = preload("res://vfx/scene/trail.tscn")

# property
const HK_KNIFE = preload("res://miscallenous/scene/hk_knife.tscn")
const COLLECTIBLE = preload("res://item/collectible/collectible.tscn")

# error message
const ERROR_MESSAGE = preload("uid://l8416kw7p3ir")

# layer mask for crosshair
const WORLD_MASK := 1 << 9   # binary, layer 10
const ENEMY_MASK := 1 << 3   # layer 4

func _ready() -> void:
	SignalManager.on_blade_platform.connect(spawn_shockwave)
	SignalManager.on_throw_blade.connect(spawn_crosshair)
	SignalManager.on_jump_on_air.connect(spawn_air)
	#SignalManager.on_player_hit.connect(spawn_slash)
	SignalManager.on_player_hurt.connect(spawn_slash)
	SignalManager.on_enemy_hurt.connect(spawn_slash)
	SignalManager.on_hk_die.connect(spawn_hkknife)
	SignalManager.on_spawn_collectible.connect(spawn_collectible)
	
	# error message
	SignalManager.on_error_message.connect(spawn_error_message)

func spawn_shockwave(pos: Vector2) -> void:
	var sw = SHOCKWAVE.instantiate()
	sw.global_position = pos
	call_deferred("add_child", sw)

func has_object_at(pos: Vector2) -> bool:
	# true if a world or enemy body is at [param pos] (global coordinates).
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = WORLD_MASK | ENEMY_MASK # only for world and enemy
	query.collide_with_bodies = true
	query.collide_with_areas = false
	return not get_viewport().world_2d.direct_space_state.intersect_point(query, 1).is_empty()

func spawn_crosshair(pos: Vector2, has_blade: bool) -> void:
	print('spawn crosshair')
	var ch = CROSSHAIR.instantiate()
	ch.global_position = pos
	add_child(ch)
	
	if not has_blade:
		ch.set_crosshair(Crosshair.RED)
	elif has_object_at(pos):
		ch.set_crosshair(Crosshair.GREEN)
	else:
		ch.set_crosshair(Crosshair.NORMAL)

func spawn_air(pos: Vector2) -> void:
	var air = AIR.instantiate()
	air.global_position = pos
	call_deferred("add_child", air)

func spawn_slash(pos: Vector2) -> void:
	var slash = SLASH.instantiate()
	slash.global_position = pos
	call_deferred("add_child", slash)
	
func spawn_hkknife(pos: Vector2, dir: float) -> void:
	var knife = HK_KNIFE.instantiate()
	knife.global_position = pos
	knife.transform.x.x = dir
	call_deferred("add_child", knife)

func spawn_collectible(pos: Vector2, dir: float) -> void:
	# base case: if no dir, just pick random
	if dir == 0.0:
		dir = [-1.0, 1.0].pick_random() 
	var collectible = COLLECTIBLE.instantiate() as Collectible
	collectible.global_position = pos
	collectible.launch_velocity = Vector2(
		signf(dir) * randf_range(60.0, 140.0),   # sideways, away from the hit
		randf_range(-260.0, -160.0)              # upward, random
	)
	call_deferred("add_child", collectible)
	
func spawn_error_message(err_msg: String) -> void:
	print('error message pop')
	var canvas = CanvasLayer.new()
	var msg: ErrorMessage = ERROR_MESSAGE.instantiate()
	msg.message = err_msg
	canvas.add_child(msg)
	msg.tree_exited.connect(canvas.queue_free)
	call_deferred("add_child", canvas)
