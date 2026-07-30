extends Node2D

class_name Blade

## STATE ##
enum BladeState {
	ORBIT,
	FLY,
	PLATFORM,
	RETURN
}

## PROPERTY ##
const SPEED: int = 550
const ROT_SPEED: int = 500

@export var orbit_offset: Vector2

@onready var sprite: Sprite2D = $Sprite2D
@onready var wallhitbox: Area2D = $WallHitBox
@onready var clickbox: CollisionShape2D = $ClickBox/CollisionShape2D
@onready var platformbox: StaticBody2D = $PlatformBox
@onready var platformbox_shape: CollisionShape2D = $PlatformBox/CollisionShape2D
@onready var platform_timer: Timer = $PlatformTimer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var right_wall_detector: RayCast2D = $RightWallDetector
@onready var left_wall_detector: RayCast2D = $LeftWallDetector

var cur_state = BladeState.ORBIT
var target: Vector2
var dir: Vector2
var is_hit_wall: bool = false

## FUNCTION ##
func _ready() -> void:
	init_orbit()

func _unhandled_input(event: InputEvent) -> void:
	# recall all blades
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT and event.pressed and (cur_state == BladeState.FLY or cur_state == BladeState.PLATFORM):
			set_state(BladeState.RETURN)

func _physics_process(delta: float) -> void:
	check_side()
	match cur_state:
		BladeState.ORBIT:
			orbit()
		BladeState.FLY:
			fly(delta)
		BladeState.PLATFORM:
			platform()
		BladeState.RETURN:
			returning(delta)

func set_state(new_state: BladeState) -> void:
	if cur_state == new_state:
		return
	
	cur_state = new_state
	print(BladeState.keys()[cur_state])
	# one-time assignment
	match cur_state:
		BladeState.ORBIT:
			init_orbit()
		BladeState.FLY:
			init_fly()
		BladeState.PLATFORM:
			init_platform()
		BladeState.RETURN:
			init_return()

## FUNCTION STATE: ONE-TIME EXECUTION ##
func init_orbit() -> void:
	Utils.toggle_area2d(wallhitbox, false)
	Utils.toggle_collision_shape(platformbox_shape, false)
	Utils.toggle_collision_shape(clickbox, false)
	is_hit_wall = false
	set_rot(sprite, 0.0)
	enable_detector(false)
	anim.play("RESET")
	hide()

func init_fly() -> void:
	Utils.toggle_area2d(wallhitbox, true)
	Utils.toggle_collision_shape(platformbox_shape, false)
	Utils.toggle_collision_shape(clickbox, false)
	enable_detector(true)
	anim.play("throw")
	show()

func init_platform() -> void:
	Utils.toggle_area2d(wallhitbox, false)
	Utils.toggle_collision_shape(platformbox_shape, true)
	Utils.toggle_collision_shape(clickbox, true)
	enable_detector(false)
	platform_timer.start()
	
	# signal is to spawn shockwave
	SignalManager.on_blade_platform.emit(global_position)
	
	# hit top and bottom wall
	if is_hit_wall == true:
		set_rot(sprite, deg_to_rad(randf_range(45.0, 125.0)))
		Utils.toggle_collision_shape(platformbox_shape, false)
	else:
		set_rot(sprite, 0.0)
		
	anim.play("RESET")
	show()

func init_return() -> void:
	Utils.toggle_area2d(wallhitbox, true)
	Utils.toggle_collision_shape(platformbox_shape, false)
	Utils.toggle_collision_shape(clickbox, false)
	platform_timer.stop()
	enable_detector(false)
	anim.play("throw")
	show()

## FUNCTION STATE: FRAME PER SECOND EXECUTION ##
func orbit() -> void:
	global_position = get_parent().global_position + orbit_offset

func fly(delta) -> void:
	if cur_state == BladeState.FLY:
		global_position += SPEED * dir * delta
		
	if global_position.distance_to(target) < 5:
		is_hit_wall = false
		set_state(BladeState.PLATFORM)
	
func platform() -> void:
	pass
	
func returning(delta) -> void:
	# set return value
	var pos: Vector2 = get_parent().global_position + orbit_offset
	set_target(pos, BladeState.RETURN)
	
	if cur_state ==  BladeState.RETURN:
		global_position += SPEED * dir * delta
		
	if global_position.distance_to(target) < 5:
		set_state(BladeState.ORBIT)

## FUNCTION AUXILIARY ##
func set_target(pos, state: BladeState) -> void:
	set_state(state)
	target = pos
	dir = global_position.direction_to(target)

func set_rot(obj, val: float) -> void:
	obj.global_rotation = val
	
func check_side() -> void:
	if (right_wall_detector.is_colliding() or left_wall_detector.is_colliding()) and is_hit_wall == false:
		set_state(BladeState.PLATFORM)

func enable_detector(val: bool) -> void:
	right_wall_detector.enabled = val
	left_wall_detector.enabled = val

## SIGNAL ##
# if blade hit object
func _on_hitbox_body_entered(body: Node2D) -> void:
	if cur_state != BladeState.FLY:
		return
	
	if body.is_in_group("enemy"):
		print("hit enemy")
		return
	is_hit_wall = true
	set_state(BladeState.PLATFORM)

# for recalling the blade one by one
func _on_clickbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("middle-mouse"):
			if cur_state == BladeState.PLATFORM:
				set_state(BladeState.RETURN)

# platform timer
func _on_platform_timer_timeout() -> void:
	set_state(BladeState.RETURN)
