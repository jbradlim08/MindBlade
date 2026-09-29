extends BaseEnemy

class_name HeadKnife

enum HKState {
	IDLE,
	PATROL,
	CHARGE,
	ATTACK,
	FALL,
	HURT,
	DIE
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var wall_detector: RayCast2D = $WallDetector
@onready var back_detector: RayCast2D = $BackDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var attack_domain: Area2D = $AttackDomain
@onready var patrol_timer: Timer = $PatrolTimer
@onready var hurt_timer: Timer = $HurtTimer

var prev_state: HKState
var cur_state: HKState
var dir: float
var speed: float = 70.0
var charge_speed: float = 120.0
var can_charge: bool = false
var can_attack: bool = false
var can_hurt: bool = true

func _ready() -> void:
	enemy_die.connect(set_state.bind(HKState.DIE))
	hp = DataManager.get_headknife_hp()
	set_state(HKState.IDLE)
	super()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	check_state()
	check_detectors()
	
	move_and_slide()

func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

func update_facing() -> void:
	if not is_on_floor():
		return
	if dir > 0.0:
		self.transform.x.x = 1.0
	
	elif dir < 0.0:
		self.transform.x.x = -1.0

func check_detectors() -> void:
	if cur_state == HKState.PATROL or cur_state == HKState.CHARGE:
		if (
			wall_detector.is_colliding() and \
			ground_detector.is_colliding() and \
			not back_detector.is_colliding()
		   ) or \
		   (
			not wall_detector.is_colliding() and \
			not ground_detector.is_colliding() and \
			not back_detector.is_colliding()
		   ):
			dir = -dir
		else:
			dir = dir
		set_state(HKState.PATROL)
	else: return

func check_state() -> void:
	if cur_state == HKState.HURT:
		return
	if is_on_floor():
		if dir == 0.0 and cur_state != HKState.IDLE:
			set_state(HKState.IDLE)
		elif dir != 0.0 and cur_state != HKState.PATROL:
			set_state(HKState.PATROL)
	else:
		if velocity.y > 0.0 and cur_state != HKState.FALL:
			set_state(HKState.FALL)
	
	if can_attack and cur_state != HKState.FALL:
		set_state(HKState.ATTACK)

func set_state(new_state: HKState) -> void:
	prev_state = cur_state
	cur_state = new_state
	print("HK: ", HKState.keys()[cur_state])
	match new_state:
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
	velocity.x = 0
	
	anim.play("idle")
	patrol_timer.start()

func patrol() -> void:
	velocity.x = dir * speed
	update_facing()

	anim.play("patrol")
	if prev_state == HKState.PATROL:
		return
	patrol_timer.start()

func charge() -> void:
	pass

func attack() -> void:
	dir = -to_player_dir()
	update_facing()
	set_physics_process(false)

	anim.play("attack")
	await anim.animation_finished
	
	set_physics_process(true)

func fall() -> void:
	anim.play("fall")

func hurt() -> void:
	# to avoid physics set to false when attacking
	set_physics_process(true)
	Utils.toggle_col_layer_mask(self, 4, false)
	can_hurt = false
	
	velocity.x = to_player_dir() * 150
	velocity.y = -50
	
	anim.play("hurt")
	await anim.animation_finished
	
	velocity.x = 0
	hurt_timer.start()

func die() -> void:
	set_physics_process(false)
	anim.play("die")
	velocity.x = 0.0
	health_bar.hide()
	Utils.toggle_collision_shape(hurtbox_col, false)
	Utils.toggle_collision_shape(body_col, false)

# Auxiliary
func to_player_dir() -> float:
	return sign(global_position.x - player_ref.global_position.x)

func take_damage(amount: int) -> void:
	if can_hurt:
		set_state(HKState.HURT)
		super(amount)

func _on_patrol_timer_timeout() -> void:
	if cur_state == HKState.IDLE:
		dir = 1.0 if randi_range(0, 1) == 0 else -1.0
		set_state(HKState.PATROL)
	elif cur_state == HKState.PATROL:
		set_state(HKState.IDLE)


func _on_attack_domain_body_entered(body: Node2D) -> void:
	can_attack = true


func _on_attack_domain_body_exited(body: Node2D) -> void:
	can_attack = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurt"):
		area.get_parent().take_damage(DataManager.get_headknife_dmg())


func _on_hurt_timer_timeout() -> void:
	can_hurt = true
	Utils.toggle_col_layer_mask(self, 4, true)
	set_state(HKState.IDLE)
