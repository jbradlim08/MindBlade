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

@onready var sprite: Sprite2D = $Sprite2D
@onready var worldbox: Area2D = $WorldBox
@onready var hitbox: CollisionShape2D = $HitBox/CollisionShape2D
@onready var clickbox: CollisionShape2D = $ClickBox/CollisionShape2D
@onready var platformbox: StaticBody2D = $PlatformBox
@onready var platformbox_shape: CollisionShape2D = $PlatformBox/CollisionShape2D
@onready var platform_timer: Timer = $PlatformTimer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var right_wall_detector: RayCast2D = $RightWallDetector
@onready var left_wall_detector: RayCast2D = $LeftWallDetector
@onready var trail: Line2D = $Trail
@onready var sound: AudioStreamPlayer2D = $Sound

var cur_state = BladeState.ORBIT
var target: Vector2
var dir: Vector2
var is_hit_top_wall: bool = false
var is_hit_side_wall: bool = false

## FUNCTION ##
func _ready() -> void:
	init_orbit()

func _unhandled_input(event: InputEvent) -> void:
	# recall all blades when pressed SHIFT
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT and event.pressed and \
		   (cur_state == BladeState.FLY or cur_state == BladeState.PLATFORM):
			set_state(BladeState.RETURN)

func _physics_process(delta: float) -> void:
	check_side()
	# perform iterative calculation during state
	match cur_state:
		BladeState.ORBIT:
			orbit()
		BladeState.FLY:
			fly(delta)
		BladeState.PLATFORM:
			platform()
		BladeState.RETURN:
			returning(delta)
	check_side()

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

#region State: One-Time Execution 
func init_orbit() -> void:
	# in ORBIT state, everything is default and false value
	Utils.toggle_area2d(worldbox, false)
	Utils.toggle_collision_shape(platformbox_shape, false)
	Utils.toggle_collision_shape(clickbox, false)
	Utils.toggle_collision_shape(hitbox, false)
	SoundManager.play_clip(sound, SoundManager.SILENT, 1.0, 1.0)
	is_hit_top_wall = false
	is_hit_side_wall = false
	set_rot(sprite, 0.0)
	enable_detector(false)
	anim.play("RESET")
	hide()
	# set the trail process to false and reset its queue array to save storage
	trail.set_process(false)
	trail.reset_queue()

func init_fly() -> void:
	Utils.toggle_area2d(worldbox, true)
	Utils.toggle_collision_shape(platformbox_shape, false)
	Utils.toggle_collision_shape(clickbox, false)
	Utils.toggle_collision_shape(hitbox, true)
	SoundManager.play_clip(sound, SoundManager.BLADE_SPIN_SOUND, 1.0, 1.0)
	is_hit_top_wall = false
	is_hit_side_wall = false
	# activate detector to detect wall
	enable_detector(true)
	anim.play("throw")
	show()
	# showing the trail effect
	trail.set_process(true)

func init_platform() -> void:
	Utils.toggle_area2d(worldbox, false)
	Utils.toggle_collision_shape(platformbox_shape, true)
	Utils.toggle_collision_shape(clickbox, true)
	Utils.toggle_collision_shape(hitbox, false)
	SoundManager.play_clip(sound, SoundManager.SILENT, 1.0, 1.0)
	enable_detector(false)
	platform_timer.start()
	
	# to make sure it always landed on pivot point
	if not is_hit_side_wall and not is_hit_top_wall:
		global_position = target
		
	# if the blade hit top and bottom wall, randomize the rotation
	if is_hit_top_wall and not is_hit_side_wall:
		set_rot(sprite, deg_to_rad(randf_range(45.0, 125.0)))
		# platformbox is disabled so player couldn't stand on it
		Utils.toggle_collision_shape(platformbox_shape, false)
	else:
		set_rot(sprite, 0.0)
		
	anim.play("RESET")
	show()
	trail.set_process(true)
	# signal is to spawn shockwave
	SignalManager.on_blade_platform.emit(global_position)

func init_return() -> void:
	Utils.toggle_area2d(worldbox, true)
	Utils.toggle_collision_shape(platformbox_shape, false)
	Utils.toggle_collision_shape(clickbox, false)
	Utils.toggle_collision_shape(hitbox, true)
	SoundManager.play_clip(sound, SoundManager.BLADE_SPIN_SOUND, 1.0, 1.0)
	is_hit_top_wall = false
	is_hit_side_wall = false
	platform_timer.stop()
	enable_detector(false)
	anim.play("throw")
	show()
	trail.set_process(true)
#endregion

#region State: Loop Execution
func orbit() -> void:
	global_position = get_parent().global_position

func fly(delta) -> void:
	if cur_state == BladeState.FLY:
		global_position += SPEED * dir * delta
		
	if global_position.distance_to(target) < 5:
		is_hit_top_wall = false
		set_state(BladeState.PLATFORM)
	
func platform() -> void:
	pass
	
func returning(delta) -> void:
	# set return value
	var pos: Vector2 = get_parent().global_position
	set_target(pos)
	
	if cur_state ==  BladeState.RETURN:
		global_position += SPEED * dir * delta
		
	if global_position.distance_to(target) < 5:
		set_state(BladeState.ORBIT)
#endregion

#region Auxiliary
# initial function from player to set the target for the blade to fly
func set_target(pos) -> void:
	target = pos
	dir = global_position.direction_to(target)

func set_rot(obj, val: float) -> void:
	obj.global_rotation = val
	
func check_side() -> void:
	if (right_wall_detector.is_colliding() or left_wall_detector.is_colliding()) and \
	   is_hit_top_wall == false:
		is_hit_side_wall = true
		# if is_hit_side_wall is true, change state to PLATFORM immediately
		set_state(BladeState.PLATFORM)

func enable_detector(val: bool) -> void:
	right_wall_detector.enabled = val
	left_wall_detector.enabled = val
#endregion

#region Signal
# if blade hit object
func _on_worldbox_body_entered(_body: Node2D) -> void:
	if cur_state != BladeState.FLY:
		return

	is_hit_top_wall = true
	set_state(BladeState.PLATFORM)

func _on_hitbox_area_entered(area: Node2D) -> void:
	set_state(BladeState.RETURN)
	if area.is_in_group(Constants.ENEMY_HURT_GROUP):
		area.get_parent().take_damage(GameData.get_blade_dmg(), global_position)
		# signal: spawn slash effect from object_container
		SignalManager.on_player_hit.emit(area.global_position)

# for recalling the blade one by one
func _on_clickbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("middle-mouse"):
			if cur_state == BladeState.PLATFORM:
				set_state(BladeState.RETURN)

# platform timer
func _on_platform_timer_timeout() -> void:
	set_state(BladeState.RETURN)

#endregion
