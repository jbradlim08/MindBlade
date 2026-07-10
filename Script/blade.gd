extends Node2D

class_name Blade

enum BladeState {
	ORBIT,
	FLY,
	PLATFORM,
	RETURN
}

const SPEED: int = 1000
const ROT_SPEED: int = 80
const SHOCKWAVE: PackedScene = preload("res://Scene/shockwave.tscn")

@export var orbit_offset: Vector2

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $HitBox
@onready var platformbox: StaticBody2D = $PlatformBox
@onready var platformbox_shape: CollisionShape2D = $PlatformBox/CollisionShape2D
@onready var platform_timer: Timer = $PlatformTimer
@onready var container: Node2D = $Container
@onready var anim: AnimationPlayer = $AnimationPlayer

var player: Player
var cur_state = BladeState.ORBIT
var target: Vector2
var dir: Vector2
var is_hit_wall: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_orbit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT and event.pressed:
			change_state(BladeState.RETURN)

func _process(delta: float) -> void:
	match cur_state:
		BladeState.ORBIT:
			orbit()
		BladeState.FLY:
			fly(delta)
		BladeState.PLATFORM:
			platform()
		BladeState.RETURN:
			returning(delta)

func change_state(new_state: BladeState) -> void:
	if cur_state == new_state:
		return
	
	cur_state = new_state
	
	# one time assignment
	match cur_state:
		BladeState.ORBIT:
			Utils.toggle_area2d(hitbox, false)
			Utils.toggle_collision_shape(platformbox_shape, false)
			set_rot(self, 0.0)
			anim.play("idle")
			print('Orbitting')
		BladeState.FLY:
			Utils.toggle_area2d(hitbox, true)
			Utils.toggle_collision_shape(platformbox_shape, false)
			anim.play("RESET")
			print('Flying')
		BladeState.PLATFORM:
			Utils.toggle_area2d(hitbox, true)
			Utils.toggle_collision_shape(platformbox_shape, true)
			if not is_hit_wall:
				set_rot(self, deg_to_rad(255.0))
				set_rot(platformbox, 0.0)
			platform_timer.start()
			anim.play("RESET")
			SignalManager.on_blade_platform.emit(global_position)
			print('Platform')
		BladeState.RETURN:
			Utils.toggle_area2d(hitbox, false)
			Utils.toggle_collision_shape(platformbox_shape, false)
			platform_timer.stop()
			anim.play("RESET")
			print('Returning')

func init_throw(target) -> void:
	change_state(BladeState.FLY)
	self.target = target
	dir = global_position.direction_to(target)

func init_orbit() -> void:
	cur_state = BladeState.ORBIT
	Utils.toggle_area2d(hitbox, false)
	Utils.toggle_collision_shape(platformbox_shape, false)
	set_rot(self, 0.0)
	anim.play("idle")
	print('Orbitting')

func orbit() -> void:
	global_position = get_parent().global_position + orbit_offset

func fly(delta) -> void:
	if cur_state == BladeState.FLY:
		global_position += SPEED * dir * delta
		rotation += ROT_SPEED * delta
		
	if global_position.distance_to(target) < 5:
		is_hit_wall = false
		change_state(BladeState.PLATFORM)
	
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
		change_state(BladeState.ORBIT)

func set_rot(obj, val: float) -> void:
	obj.global_rotation = val

# Signal
# hit the wall
func _on_hitbox_body_entered(body: Node2D) -> void:
	if cur_state != BladeState.FLY:
		return

	is_hit_wall = true
	change_state(BladeState.PLATFORM)

# for recalling the blade one by one
func _on_clickbox_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("middle-mouse"):
			if cur_state == BladeState.PLATFORM:
				change_state(BladeState.RETURN)


func _on_platform_timer_timeout() -> void:
	change_state(BladeState.RETURN)
