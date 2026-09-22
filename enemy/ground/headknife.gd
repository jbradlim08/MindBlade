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
@onready var charge_timer: Timer = $ChargeTimer

@export var gravity_scale: float = 0.5
@export var speed: float = 70.0
@export var charge_speed: float = 100.0
@export var max_dist_x_to_player: float = 180.0
@export var max_dist_y_to_player: float = 100.0

var cur_state: HKState
var dir: float = 0.0
var state_velocity_x: float = 0.0
var is_collide_wall: bool = false

var can_idle: bool = true
var can_patrol: bool = true
var can_charge: bool = true
var can_attack: bool = true
var can_fall: bool = true
var can_hurt: bool = true


func _ready() -> void:
	set_state(HKState.IDLE)
	enemy_die.connect(set_state.bind(HKState.DIE))
	hp = DataManager.get_headknife_hp()
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	if cur_state != HKState.DIE:
		apply_gravity(delta)
	
	handle_movement()
	handle_facing()
	handle_charge()
	
	#can_do_state()
	
	# check the state
	check_movement()
	check_side_wall()
	check_fall()

	move_and_slide()

func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

func check_movement() -> void:
	if not is_on_floor():
		return
	if can_idle and dir == 0.0:
		set_state(HKState.IDLE)

func check_fall() -> void:
	if not is_on_floor() and velocity.y >= 0:
		set_state(HKState.FALL)

func check_side_wall() -> void:
	if not is_on_floor():
		return
	if right_detector.is_colliding():
		if cur_state == HKState.CHARGE and can_idle:
			set_state(HKState.IDLE)
			can_charge = false
			charge_timer.start()
			return
		dir = -1.0
	elif left_detector.is_colliding():
		if cur_state == HKState.CHARGE and can_idle:
			set_state(HKState.IDLE)
			can_charge = false
			charge_timer.start()
			return
		dir = 1.0

func can_do_state() -> void:
	# idle
	if not is_on_floor():
		can_idle = false
	else: can_idle = true
	
	# patrol
	if cur_state == HKState.CHARGE or \
	   cur_state == HKState.ATTACK or \
	   cur_state == HKState.HURT or \
	   not is_on_floor():
		can_patrol = false
	else: 
		can_patrol = true
	
	# charge
	#if cur_state == HKState.ATTACK or \
	   #cur_state == HKState.HURT or \
	   #not is_on_floor():
		#can_charge = false
	#else: can_charge = true
	
	# fall
	if cur_state == HKState.ATTACK:
		can_fall = false
	else: can_fall = true
	
	# attack
	if cur_state == HKState.PATROL or \
	   cur_state == HKState.CHARGE or \
	   cur_state == HKState.FALL or \
	   cur_state == HKState.HURT or \
	   not is_on_floor():
		can_attack = false
	else: can_attack = true
	
	# hurt
	can_hurt = true


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
	var player_pos = player_ref.global_position
	var hk_pos = global_position
	var dist: Vector2 = Vector2(
						abs(player_pos.x - hk_pos.x),
						abs(player_pos.y - hk_pos.y))
	
	# enter charge domain
	if dist.x <= max_dist_x_to_player and dist.y <= max_dist_y_to_player:
		if can_charge:
			set_state(HKState.CHARGE)
			dir = sign(player_pos.x - hk_pos.x)

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

func patrol() -> void:
	state_velocity_x = speed
	anim_player.play("patrol")

func charge() -> void:
	state_velocity_x = charge_speed
	anim_player.play("charge")
	movement_timer.stop()

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
	movement_timer.start()
	set_state(HKState.IDLE)
	
func die() -> void:
	anim_player.play("die")
	set_physics_process(false)
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

#endregion


func _on_movement_timer_timeout() -> void:
	if cur_state == HKState.IDLE and can_patrol:
		set_state(HKState.PATROL)
		dir = 1.0 if randi_range(0, 1) == 0 else -1.0
	elif cur_state == HKState.PATROL and can_idle:
		set_state(HKState.IDLE)


func _on_charge_timer_timeout() -> void:
	can_charge = true
