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
@onready var fellow_detector: RayCast2D = $FellowDetector
@onready var fellow_detector_2: RayCast2D = $FellowDetector2
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

#var can_charge: bool = true
var can_attack: bool = false
var can_hurt: bool = true
var is_blocked: bool = false # to cancel hurt if is_blocked is true
var is_hurt: bool = false # for shield to take effect right after hurt(0.2s)

var max_dist_y_to_player: float = 40.0
var obj_pos_hurt: Vector2 = Vector2.ZERO # the object position who hurt HK

func _ready() -> void:
	# stop enemy inheriting each other's velocity
	platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_DO_NOTHING
	# connect signal "enemy_die" from base_enemy to set_state()
	enemy_die.connect(set_state.bind(HKState.DIE))
	hp = GameData.get_headknife_hp()
	patrol_timer.wait_time = patrol_time
	set_state(HKState.IDLE)
	super()
	# in super, will set the hp to the UI

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	check_state()

	update_player_detector()
	update_fellow_detector()
	move_and_slide()
	# push_apart() is to make some space between HK so they don't overlap
	push_apart()
	# check_detectors() should be the last to avoid unupdated data from raycast
	call_deferred("check_detectors") 
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
	# top level enabled, points to player
	player_detector.rotation = global_position.angle_to_point(player_ref.global_position) \
							   - deg_to_rad(90.0)
	player_detector.global_position = global_position

func update_fellow_detector() -> void:
	# top level enabled, points to player
	fellow_detector.rotation = global_position.angle_to_point(player_ref.global_position) \
							   - deg_to_rad(90.0)
	fellow_detector.global_position = global_position

func check_detectors() -> void:
	if cur_state == HKState.PATROL or cur_state == HKState.CHARGE:
		# when should HK turn
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
				# HK stop when hit the wall while charging
				#can_charge = false
				set_state(HKState.IDLE)
				#charge_timer.start()
				return
			set_state(HKState.PATROL)
		# when should HK not turn
		else:
			dir = dir
	else: return

func check_player_detector() -> bool:
	# to check whether the detector collide with player or not
	if not player_detector.is_colliding():
		return false
	else:
		var collider = player_detector.get_collider()
		return collider.is_in_group("player_body")

func check_fellow_detector() -> bool:
	# to check whether the detector collide with other HK or not
	return not (fellow_detector.is_colliding())


func check_can_charge() -> bool:
	# don't start a charge while stacked on a fellow
	# if player isn't on the ground, then no CHARGE
	var floor_group
	if player_ref.ground_detector.is_colliding():
		floor_group = player_ref.ground_detector.get_collider()
	else: 
		return false
	
	# player should be on ground and contact with "world" group
	# bare minimum y distance with player is 40 and should be under player
	# player detector should hit player & fellow detector shouldn't hit others HK
	# can charge and cannot attack
	if player_ref.is_on_floor() and \
	   floor_group.is_in_group("world") and \
	   global_position.y - player_ref.global_position.y <= max_dist_y_to_player and \
	   global_position.y - player_ref.global_position.y >= 0 and \
	   check_player_detector() and \
	   check_fellow_detector()  and \
	   #can_charge and \
	   not can_attack:
		return true
	else:
		return false

func check_state() -> void:
	# when HK is hurt, it cannot transition to any state
	if cur_state == HKState.HURT:
		return
	
	if is_on_floor():
		if velocity.x == 0.0 and cur_state != HKState.IDLE and cur_state != HKState.CHARGE:
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
	
	# in the middle of charge, check
	if cur_state == HKState.CHARGE:
		# check if the player is on the opposeite direction and can charge
		if dir != -to_obj_pos_dir(player_ref.global_position) and \
		   check_can_charge():
			set_state(HKState.CHARGE)
		# if stopped by its fellow
		if velocity.x == 0.0:
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
	# if previous state is PATROL, don't start the timer
	if prev_state == HKState.PATROL:
		return
	patrol_timer.start()

func charge() -> void:
	Utils.toggle_col_layer_mask(self, 4, false)
	
	# directino to player
	dir = -to_obj_pos_dir(player_ref.global_position)
	update_facing()
	velocity.x = dir * charge_speed
	push_apart() # at least do it once when charge
	
	anim.play("charge")

func attack() -> void:
	Utils.toggle_col_layer_mask(self, 4, false)
	set_physics_process(false)
	
	dir = -to_obj_pos_dir(player_ref.global_position)
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
	dir = -to_obj_pos_dir(player_ref.global_position)
	update_facing()
	is_hurt = true
	can_hurt = false
	
	# jump to the direction from the attack in x axis
	velocity.x = to_obj_pos_dir(obj_pos_hurt) * 150
	velocity.y = -50
	
	# signal: to spawn slash effect from object_container
	SignalManager.on_enemy_hurt.emit(global_position)
	SoundManager.play_clip(sound, SoundManager.HEADKNIFE_HURT_SOUND, 2.0, 1.0)
	anim.play("hurt")
	await anim.animation_finished
	is_hurt = false # HK can block(blink) after this
	
	# stop at zero velocity
	velocity.x = 0
	hurt_timer.start() # approx 0.4s, until the next hurt

func die() -> void:
	Utils.toggle_col_layer_mask(self, 4, false)
	set_physics_process(false)
	velocity.x = 0.0
	health_bar.hide()
	
	anim.play("die")
	await anim.animation_finished
	# signal: to spawn its blade from object container, persist the whole time
	SignalManager.on_hk_die.emit(global_position, dir)

#region Auxiliary
func to_obj_pos_dir(pos: Vector2) -> float:
	return sign(global_position.x - pos.x)

func blink() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "self_modulate", Color(7, 7, 7), 0.0)
	tween.tween_property(sprite, "self_modulate", Color(1, 1, 1), 0.2)
	tween.tween_callback(func(): is_blocked = false) # runs after 0.2s


func push_apart() -> void:
	if cur_state != HKState.CHARGE:
		return
	for e in get_tree().get_nodes_in_group(Constants.ENEMY_BODY_GROUP):
		if e == self:
			continue
		if e.cur_state in [HKState.ATTACK, HKState.HURT, HKState.IDLE]:
			continue
		if e.global_position.distance_to(global_position) >= 20.0: # 20 is a push distance
			continue

		var dir := signf(global_position.x - e.global_position.x)
		if dir == 0.0:
			# exactly overlapping: higher instance id goes right, the other goes left
			# why id? because it is always different
			dir = 1.0 if get_instance_id() > e.get_instance_id() else -1.0
		global_position.x += dir * 0.8 # push speed

func play_attack_sound() -> void:
	# call it in AnimationPlayer
	SoundManager.play_clip(sound, SoundManager.KNIFE_SWING_SOUND, 0.0, 1.5)

func block() -> void:
	is_blocked = true
	SoundManager.play_clip(sound, SoundManager.TING_SOUND, 0.0, 1.0)
	blink() # is_blocked will be false here
	health_bar.anim.play("blocked")
#endregion

func take_damage(amount: int, pos: Vector2) -> void:
	# PARAM "pos": whoever hit the enemy, such as MindBlade or Player
	# if HK is still blocking, no take any damages
	if is_blocked:
		return
		
	obj_pos_hurt = pos
	if can_hurt:
		set_state(HKState.HURT)
		super(amount, pos)
	else:
		# this else statement happen when HK is invincible after get hit
		block()
		

func _on_attack_domain_body_entered(body: Node2D) -> void:
	can_attack = true


func _on_attack_domain_body_exited(body: Node2D) -> void:
	can_attack = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(Constants.PLAYER_HURT_GROUP):
		area.get_parent().take_damage(GameData.get_headknife_dmg(),
						  			  global_position, true)

func _on_shield_area_entered(area: Area2D) -> void:
	if area.is_in_group(Constants.BLADE_HIT_GROUP):
		resolve_shield_hit.call_deferred(area)

func resolve_shield_hit(area: Area2D) -> void:
	# HK block mindblade if the blade hit the helmet knife and not its body
	if cur_state != HKState.HURT and cur_state != HKState.DIE:
		block()
	if cur_state == HKState.HURT and not is_hurt:
		block()

func _on_patrol_timer_timeout() -> void:
	if cur_state == HKState.IDLE:
		dir = 1.0 if randi_range(0, 1) == 0 else -1.0
		set_state(HKState.PATROL)
	elif cur_state == HKState.PATROL:
		set_state(HKState.IDLE)

func _on_hurt_timer_timeout() -> void:
	can_hurt = true
	#Utils.toggle_col_layer_mask(self, 4, true)
	set_state(HKState.IDLE)

#func _on_charge_timer_timeout() -> void:
	#can_charge = true
