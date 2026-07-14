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
const SPEED: int = 500
const ROT_SPEED: int = 100

@export var orbit_offset: Vector2

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $HitBox
@onready var clickbox: CollisionShape2D = $ClickBox/CollisionShape2D
@onready var platformbox: StaticBody2D = $PlatformBox
@onready var platformbox_shape: CollisionShape2D = $PlatformBox/CollisionShape2D
@onready var platform_timer: Timer = $PlatformTimer
@onready var anim: AnimationPlayer = $AnimationPlayer

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
	Utils.toggle_area2d(hitbox, false)
	Utils.toggle_collision_shape(platformbox_shape, false)
	Utils.toggle_collision_shape(clickbox, false)
	set_rot(self, 0.0)
	anim.play("idle")

func init_fly() -> void:
	Utils.toggle_area2d(hitbox, true)
	Utils.toggle_collision_shape(platformbox_shape, false)
	Utils.toggle_collision_shape(clickbox, false)
	anim.play("RESET")

func init_platform() -> void:
	Utils.toggle_area2d(hitbox, false)
	Utils.toggle_collision_shape(platformbox_shape, true)
	Utils.toggle_collision_shape(clickbox, true)
	if not is_hit_wall:
		set_rot(self, deg_to_rad(255.0))
		set_rot(platformbox, 0.0)
	platform_timer.start()
	SignalManager.on_blade_platform.emit(global_position)
	anim.play("RESET")

func init_return() -> void:
	Utils.toggle_area2d(hitbox, true)
	Utils.toggle_collision_shape(platformbox_shape, false)
	Utils.toggle_collision_shape(clickbox, false)
	platform_timer.stop()
	anim.play("RESET")

## FUNCTION STATE: FRAME PER SECOND EXECUTION ##
func orbit() -> void:
	global_position = get_parent().global_position + orbit_offset

func fly(delta) -> void:
	if cur_state == BladeState.FLY:
		global_position += SPEED * dir * delta
		rotation += ROT_SPEED * delta
		
	if global_position.distance_to(target) < 5:
		is_hit_wall = false
		set_state(BladeState.PLATFORM)
	
func platform() -> void:
	pass
	
func returning(delta) -> void:
	# set return value
	self.target = get_parent().global_position + orbit_offset
	dir = global_position.direction_to(target)
	
	if cur_state ==  BladeState.RETURN:
		global_position += SPEED * dir * delta
		rotation += ROT_SPEED * delta
		
	if global_position.distance_to(target) < 5:
		set_state(BladeState.ORBIT)

## FUNCTION AUXILIARY ##
func set_target(pos) -> void:
	set_state(BladeState.FLY)
	target = pos
	dir = global_position.direction_to(target)

func set_rot(obj, val: float) -> void:
	obj.global_rotation = val

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
