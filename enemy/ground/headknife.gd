extends BaseEnemy

class_name HeadKnife

enum HKState{
	IDLE,
	PATROL,
	CHARGE,
	FALL,
	ATTACK,
	HURT,
	DIE
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var right_detector: RayCast2D = $RightDetector
@onready var left_detector: RayCast2D = $LeftDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var movement_timer: Timer = $MovementTimer

@export var gravity_scale: float = 0.5
@export var speed: float = 70.0
@export var charge_speed: float = 120.0
@export var max_dist_x_to_player: float = 220.0
@export var max_dist_y_to_player: float = 60.0

var cur_state: HKState
var dir: float = 0.0
var to_player_dir: float = 0.0 # for charge purpose
var state_velocity_x: float = 0.0

# can do state
var can_patrol: bool = true
var can_go_down: bool = true
var can_attack: bool = true
var can_hurt: bool = true


func _ready() -> void:
	enemy_die.connect(set_state.bind(HKState.DIE))
	hp = DataManager.get_headknife_hp()
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	apply_gravity(delta)
	check_all_detector()
	update_to_player_dir()
	update_player_detector()
	
	# check the state
	check_state_movement()
	check_state_fall()
	
	# the physics
	handle_movement()
	handle_facing()
	handle_charge()
	handle_attack()
	
	move_and_slide()

func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

func check_state_movement() -> void:
	if not is_on_floor():
		return
	if dir == 0.0:
		set_state(HKState.IDLE)
	else:
		if not can_charge():
			set_state(HKState.PATROL)

func check_state_fall() -> void:
	if not is_on_floor() and velocity.y >= 0:
		set_state(HKState.FALL)


func check_all_detector() -> void:
	if not is_on_floor() or can_charge():
		return
		
	if right_detector.is_colliding() or \
	   left_detector.is_colliding():
			dir = -dir
			
	if not ground_detector.is_colliding():
		dir = -dir

func handle_movement() -> void:
	velocity.x = dir * state_velocity_x

func handle_facing() -> void:
	if not is_on_floor():
		return
	if dir > 0.0:
		sprite.flip_h = false
		hitbox_col.position.x = 17.5
		ground_detector.position.x = 25
	elif dir < 0.0:
		sprite.flip_h = true
		hitbox_col.position.x = -17.5
		ground_detector.position.x = -25

func handle_charge() -> void:
	if can_charge():
		set_state(HKState.CHARGE)
		if player_ref.global_position.x > global_position.x:
			dir = 1.0
		else:
			dir = -1.0

func handle_attack() -> void:
	pass

func update_to_player_dir() -> void:
	if global_position.x <= player_ref.global_position.x:
		to_player_dir = 1.0
	else:
		to_player_dir = -1.0

func update_player_detector() -> void:
	player_detector.rotation = global_position.angle_to_point(player_ref.global_position) \
							   - deg_to_rad(90.0)

func field_of_view() -> bool:
	var horizon_dir: Vector2 = Vector2.RIGHT * to_player_dir
	var to_player: Vector2 = global_position.direction_to(player_ref.global_position)
	var angle: float = abs(horizon_dir.angle_to(to_player))
	return angle <= deg_to_rad(18.0)
	# minimum height for field of view and player detection to 'true'
	# h = sin(18) * 200px(player detector length) = 60
	# slightly lower than 2 tiles

func player_detected() -> bool:
	if not player_detector.is_colliding():
		return false
	else:
		var collider = player_detector.get_collider()
		return collider.is_in_group("player")

func can_charge() -> bool:
	var charge: bool
	if not is_on_floor() or \
	   not field_of_view() or \
	   not player_detected():
		charge = false
	else:
		charge = true
	
	if global_position.y > player_ref.global_position.y:
		if global_position.y - player_ref.global_position.y <= max_dist_y_to_player and \
		   player_ref.is_on_floor():
			print(global_position.y, ", ", player_ref.global_position.y)
			charge = true
		
	return charge

#region State
func set_state(new_state: HKState) -> void:
	if cur_state == new_state:
		return
		
	cur_state = new_state
	print("HK: ", HKState.keys()[cur_state])
	
	match cur_state:
		HKState.IDLE:
			idle()
		HKState.PATROL:
			patrol()
		HKState.CHARGE:
			charge()
		HKState.ATTACK:
			attack()
		HKState.FALL:
			fall()
		HKState.HURT:
			hurt()
		HKState.DIE:
			die()

func idle() -> void:
	dir = 0.0
	state_velocity_x = 0.0
	anim_player.play("idle")
	movement_timer.start()
	left_detector.enabled = false
	right_detector.enabled = false

func patrol() -> void:
	state_velocity_x = speed
	anim_player.play("patrol")
	movement_timer.start()
	left_detector.enabled = true
	right_detector.enabled = true

func charge() -> void:
	state_velocity_x = charge_speed
	anim_player.play("charge")
	movement_timer.stop()
	left_detector.enabled = true
	right_detector.enabled = true

func attack() -> void:
	anim_player.play("attack")
	
func jump() -> void:
	anim_player.play("jump")
	
func fall() -> void:
	anim_player.play("fall")
	
func hurt() -> void:
	set_physics_process(false)
	anim_player.play("hurt")
	await anim_player.animation_finished
	state_velocity_x = 0.0
	set_physics_process(true)
	set_state(HKState.IDLE)
	
func die() -> void:
	set_physics_process(false)
	anim_player.play("die")
	state_velocity_x = 0.0
	health_bar.hide()
	Utils.toggle_collision_shape(hurtbox_col, false)
	Utils.toggle_collision_shape(body_col, false)

#endregion

#region HealthPoint
func take_damage(amount: int, player_pos: Vector2) -> void:
	set_state(HKState.HURT)
	super(amount, player_pos)

#endregion

#region Signal
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurt"):
		area.get_parent().take_damage(DataManager.get_dmg_default(), global_position)


# interchange between IDLE and PATROL
func _on_movement_timer_timeout() -> void:
	print('take turn')
	if cur_state == HKState.IDLE:
		set_state(HKState.PATROL)
		dir = 1.0 if randi_range(0, 1) == 0 else -1.0
	elif cur_state == HKState.PATROL:
		set_state(HKState.IDLE)
