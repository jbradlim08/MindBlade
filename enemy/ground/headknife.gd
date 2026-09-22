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
@onready var movement_timer: Timer = $MovementTimer

@export var gravity_scale: float = 0.5
@export var speed: float = 70.0
@export var charge_speed: float = 100.0
@export var max_dist_x_to_player: float = 220.0
@export var max_dist_y_to_player: float = 50.0

var cur_state: HKState
var dir: float = 0.0
var state_velocity_x: float = 0.0
var is_collide_wall: bool = false

# can do state
var can_patrol: bool = true
var can_attack: bool = true
var can_hurt: bool = true

var player_in_domain: bool = false


func _ready() -> void:
	enemy_die.connect(set_state.bind(HKState.DIE))
	hp = DataManager.get_headknife_hp()
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	apply_gravity(delta)
	
	handle_movement()
	handle_facing()
	handle_charge()
	handle_attack()
	
	# check the state
	check_side_wall()
	check_movement()
	check_fall()

	move_and_slide()

func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

func check_movement() -> void:
	if not is_on_floor() or can_charge():
		return
	if dir == 0.0:
		set_state(HKState.IDLE)
	else:
		set_state(HKState.PATROL)

func check_fall() -> void:
	if not is_on_floor() and velocity.y >= 0:
		set_state(HKState.FALL)

func check_side_wall() -> void:
	if not is_on_floor():
		return
	if right_detector.is_colliding():
		if cur_state == HKState.CHARGE:
			print('idle from side_wall check')
			set_state(HKState.IDLE)
			return
		if cur_state == HKState.PATROL:
			dir = -1.0
	elif left_detector.is_colliding():
		if cur_state == HKState.CHARGE:
			print('idle from side_wall check')
			set_state(HKState.IDLE)
			return
		if cur_state == HKState.PATROL:
			dir = 1.0


func can_charge() -> bool:
	var charge: bool = false
	if not player_in_domain or \
	   (player_ref.is_on_floor() and \
	   global_position.y - player_ref.global_position.y > max_dist_y_to_player) or \
	   not is_on_floor() or \
	   left_detector.is_colliding() or \
	   right_detector.is_colliding():
		charge = false
	else:
		charge = true
	
	return charge

func handle_movement() -> void:
	velocity.x = dir * state_velocity_x

func handle_facing() -> void:
	if not is_on_floor():
		return
	if dir > 0.0:
		sprite.flip_h = false
		hitbox_col.position.x = 17.5
	elif dir < 0.0:
		sprite.flip_h = true
		hitbox_col.position.x = -17.5

func handle_charge() -> void:
	if can_charge():
		set_state(HKState.CHARGE)
		if player_ref.global_position.x > global_position.x:
			dir = 1.0
		else:
			dir = -1.0

func handle_attack() -> void:
	pass

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

func _on_charge_domain_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_body"):
		player_in_domain = true

func _on_charge_domain_body_exited(body: Node2D) -> void:
	player_in_domain = false

func _on_movement_timer_timeout() -> void:
	if cur_state == HKState.IDLE:
		set_state(HKState.PATROL)
		dir = 1.0 if randi_range(0, 1) == 0 else -1.0
	elif cur_state == HKState.PATROL:
		set_state(HKState.IDLE)
