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
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var attack_domain: Area2D = $AttackDomain
@onready var patrol_timer: Timer = $PatrolTimer
@onready var hurt_timer: Timer = $HurtTimer
@onready var charge_timer: Timer = $ChargeTimer

@export var patrol_time: float

var prev_state: HKState
var cur_state: HKState
var dir: float
var speed: float = 70.0
var charge_speed: float = 120.0

var can_charge: bool = true
var can_attack: bool = false
var can_hurt: bool = true

var max_dist_y_to_player: float = 60.0

func _ready() -> void:
	enemy_die.connect(set_state.bind(HKState.DIE))
	hp = DataManager.get_headknife_hp()
	patrol_timer.wait_time = patrol_time
	set_state(HKState.IDLE)
	super()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	check_state()
	
	update_player_detector()
	
	move_and_slide()
	call_deferred("check_detectors") # should be the last
	super(delta)

func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

func update_facing() -> void:
	if not is_on_floor():
		return
	if dir > 0.0:
		self.transform.x.x = 1.0
		health_bar.scale.x = 1.0
	elif dir < 0.0:
		self.transform.x.x = -1.0
		health_bar.scale.x = -1.0 # counter

func update_player_detector() -> void:
	player_detector.rotation = global_position.angle_to_point(player_ref.global_position) \
							   - deg_to_rad(90.0)
	player_detector.global_position = global_position

func check_view_degree() -> bool:
	var horizon_dir: Vector2 = Vector2.RIGHT * -to_player_dir()
	var to_player: Vector2 = global_position.direction_to(player_ref.global_position)
	var angle: float = abs(horizon_dir.angle_to(to_player))
	return angle <= deg_to_rad(30.0)
	# minimum height for field of view and player detection to 'true'
	# h = sin(18) * 200px(player detector length) = 60
	# slightly lower than 2 tiles

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
			if cur_state == HKState.CHARGE:
				can_charge = false
				print('hit wall while charge')
				set_state(HKState.IDLE)
				charge_timer.start()
				return
			set_state(HKState.PATROL)
		else:
			dir = dir
	else: return

func check_player_detector() -> bool:
	if not player_detector.is_colliding():
		return false
	else:
		var collider = player_detector.get_collider()
		return collider.is_in_group("player_body")

func check_can_charge() -> bool:
	if player_ref.is_on_floor() and \
	   global_position.y - player_ref.global_position.y <= max_dist_y_to_player and \
	   global_position.y - player_ref.global_position.y >= 0 and \
	   check_player_detector() and \
	   can_charge and \
	   not can_attack:
		return true
	else:
		return false

func check_state() -> void:
	if cur_state == HKState.HURT:
		return
	if is_on_floor():
		if velocity.x == 0.0 and cur_state != HKState.IDLE:
			set_state(HKState.IDLE)
		elif velocity.x != 0.0 and cur_state != HKState.PATROL and cur_state != HKState.CHARGE:
			set_state(HKState.PATROL)
	else:
		if velocity.y > 0.0 and cur_state != HKState.FALL:
			set_state(HKState.FALL)
	
	if can_attack and cur_state != HKState.FALL:
		set_state(HKState.ATTACK)
	
	if check_can_charge() and cur_state != HKState.CHARGE:
		set_state(HKState.CHARGE)
	
	# in the middle of charge
	if cur_state == HKState.CHARGE and check_can_charge():
		# change dir
		if dir != -to_player_dir() and check_view_degree():
			set_state(HKState.CHARGE)
		# if stopped by its fellow
		if velocity.x == 0:
			set_state(HKState.CHARGE)

func set_state(new_state: HKState) -> void:
	prev_state = cur_state
	cur_state = new_state
	#print("HK: ", HKState.keys()[cur_state])
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
	Utils.toggle_col_layer_mask(self, 4, false)
	
	dir = 0.0
	velocity.x = 0
	
	anim.play("idle")
	patrol_timer.start()

func patrol() -> void:
	Utils.toggle_col_layer_mask(self, 4, false)
	update_facing()
	velocity.x = dir * speed

	anim.play("patrol")
	if prev_state == HKState.PATROL:
		return
	patrol_timer.start()

func charge() -> void:
	Utils.toggle_col_layer_mask(self, 4, true)
	dir = -to_player_dir()
	update_facing()
	velocity.x = dir * charge_speed
	
	anim.play("charge")

func attack() -> void:
	Utils.toggle_col_layer_mask(self, 4, false)
	set_physics_process(false)
	
	dir = -to_player_dir()
	update_facing()

	anim.play("attack")
	await anim.animation_finished
	
	set_physics_process(true)

func fall() -> void:
	anim.play("fall")

func hurt() -> void:
	Utils.toggle_col_layer_mask(self, 4, false)
	# to avoid physics set to false when attacking
	set_physics_process(true)
	dir = -to_player_dir()
	update_facing()
	can_hurt = false
	
	velocity.x = to_player_dir() * 150
	velocity.y = -50
	
	anim.play("hurt")
	await anim.animation_finished
	
	velocity.x = 0
	hurt_timer.start()

func die() -> void:
	Utils.toggle_col_layer_mask(self, 4, false)
	set_physics_process(false)
	velocity.x = 0.0
	health_bar.hide()
	
	anim.play("die")
	await anim.animation_finished
	SignalManager.on_hk_die.emit(global_position, dir)

# Auxiliary
func to_player_dir() -> float:
	return sign(global_position.x - player_ref.global_position.x)

func blink() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "self_modulate", Color(7, 7, 7), 0.0)
	tween.tween_property(sprite, "self_modulate", Color(1, 1, 1), 0.2)

func take_damage(amount: int) -> void:
	if can_hurt:
		set_state(HKState.HURT)
		super(amount)
	else:
		print('hit the shield')
		blink()
		health_bar.anim.play("blocked")

func _on_attack_domain_body_entered(body: Node2D) -> void:
	can_attack = true


func _on_attack_domain_body_exited(body: Node2D) -> void:
	can_attack = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurt"):
		area.get_parent().take_damage(DataManager.get_headknife_dmg(),
						  			  global_position, true)

func _on_shield_area_entered(area: Area2D) -> void:
	if area.is_in_group("blade_hit"):
		resolve_shield_hit.call_deferred(area)

func resolve_shield_hit(area: Area2D) -> void:
	if (cur_state != HKState.HURT or cur_state != HKState.DIE) and \
		not hurtbox.overlaps_area(area):
		print('hit the shield')
		blink()
		health_bar.anim.play("blocked")

func _on_patrol_timer_timeout() -> void:
	if cur_state == HKState.IDLE:
		dir = 1.0 if randi_range(0, 1) == 0 else -1.0
		set_state(HKState.PATROL)
	elif cur_state == HKState.PATROL:
		set_state(HKState.IDLE)

func _on_hurt_timer_timeout() -> void:
	can_hurt = true
	Utils.toggle_col_layer_mask(self, 4, true)
	set_state(HKState.IDLE)

func _on_charge_timer_timeout() -> void:
	can_charge = true
