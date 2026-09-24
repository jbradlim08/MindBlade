extends CharacterBody2D

class_name Player

enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	DASH,
	ATTACK,
	JUMP_ATTACK,
	THROW,
	HURT,
	DIE
}

@export var speed: float = 180.0
@export var dash_speed: float = 500.0
@export var jump_velocity: float = -280.0
@export var fall_velocity: float = 300.0
@export var gravity_scale: float = 0.5
@export var max_jumps = 2
@export var attack_cycle: int = 2
@export var danger_tilemap: TileMapLayer

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var blades = $Blades.get_children()
@onready var hitbox_col: CollisionShape2D = $Hitbox/HitboxCollision
@onready var hurtbox_col: CollisionShape2D = $Hurtbox/HurtboxCollision
@onready var wall_ground_detector: RayCast2D = $WallGroundDetector
@onready var wall_air_detector: RayCast2D = $WallAirDetector
@onready var wall_air_detector_2: RayCast2D = $WallAirDetector2

var cur_state: PlayerState = PlayerState.IDLE
var dir: float = 0.0
var jump_count = 0
var jump_cut_multiplier: float = 0.4
var is_attacking: bool = false
var attack_phase: int = 1 # slash type
var is_jump_attack: bool = false
var can_jump_attack: bool = true
var can_hurt: bool = true
var can_dash: bool = true
var dash_final_dir: Vector2
var enemy_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	SignalManager.on_player_die.connect(die)

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			#set_state(PlayerState.THROW)

func _physics_process(delta: float) -> void:
	if cur_state != PlayerState.DASH:
		apply_gravity(delta)
	
	#handle all input to movement, jump, and other states
	handle_input()
	handle_throw() # not affected by can_get_input variable
	
	move_and_slide()
	
	# all that need to be reset (jump, dash, etc)
	reset() 
	
#region Gravity
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta
#endregion

#region Handle State Input
func get_dir_input() -> void:
	dir = Input.get_axis("left", "right")

func check_movement() -> void:
	if not is_on_floor():
		return
	if dir != 0:
		set_state(PlayerState.RUN)
	else:
		set_state(PlayerState.IDLE)

func check_fall() -> void:
	if not is_on_floor():
		if velocity.y >= 0:
			is_jump_attack = false
			set_state(PlayerState.FALL)
			# this is to prevent throw state condition being paused

func handle_movement() -> void:
	if dir != 0:
		velocity.x = dir * speed
	else:
		# gradually slow down
		velocity.x = move_toward(velocity.x, 0, speed)

func handle_jump() -> void:
	# Start jump
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps and not is_jump_attack:
		set_state(PlayerState.JUMP)
		velocity.y = jump_velocity
		if is_on_floor():
			jump_count += 1
		# when jump on air
		else:
			jump_count += max_jumps
			SignalManager.on_jump_on_air.emit(global_position)
	# Release early = shorter jump
	if Input.is_action_just_released("jump") and velocity.y < 0.0 and not is_jump_attack:
		if GameManager.can_get_input:
			velocity.y *= jump_cut_multiplier

func handle_fall() -> void:
	if Input.is_action_just_pressed("down") and not is_on_floor() and cur_state != PlayerState.JUMP_ATTACK:
		velocity.y = fall_velocity

func handle_dash() -> void:
	if Input.is_action_just_pressed("dash") and \
	   can_dash:
		var dash_dir_x: float = 0.0
		var dash_dir_y: float = 0.0
		var move: String = "horizontal" # horizontal or vertical
		
		# if on ground
		if sprite.flip_h: dash_dir_x = -1.0
		else: dash_dir_x = 1.0

		# if on air
		if not is_on_floor():
			if velocity.y <= 0:
				dash_dir_x = dir
				dash_dir_y = -1.0
			if dash_dir_x != 0.0:
				dash_dir_y = 0.0
		else:
			dash_dir_y = 0
				
		var final_dir: Vector2 = Vector2(dash_dir_x, dash_dir_y).normalized()
		
		if final_dir.y == 0.0: move = "horizontal"
		else: move = "vertical"
		
		if move == "horizontal":
			if is_on_floor() and wall_ground_detector.is_colliding():
				return
			elif not is_on_floor() and \
				 (wall_air_detector.is_colliding() or wall_air_detector_2.is_colliding()):
				return
	
		dash_final_dir = final_dir
		set_state(PlayerState.DASH)
			

func handle_attack() -> void:
	if Input.is_action_just_pressed("left-click"):
		if is_on_floor() and not is_attacking and cur_state != PlayerState.JUMP:
			set_state(PlayerState.ATTACK)
		else:
			if can_jump_attack:
				set_state(PlayerState.JUMP_ATTACK)
	
	if Input.is_action_just_released("left-click") and not is_on_floor() and cur_state != PlayerState.FALL:
		if GameManager.can_get_input:
			velocity.y *= jump_cut_multiplier

func handle_throw() -> void:
	if Input.is_action_just_pressed("right-click") and not is_attacking:
		set_state(PlayerState.THROW)

func handle_facing() -> void:
	# not allowed player to flip sprite when jump attack
	if cur_state == PlayerState.JUMP_ATTACK:
		sprite.flip_h = sprite.flip_h
		return
	# flip sprite and hitbox
	if dir > 0:
		sprite.flip_h = false
		hitbox_col.position.x = 28
		wall_ground_detector.target_position.x = 130
		wall_air_detector.target_position.x = 130
		wall_air_detector_2.target_position.x = 130
	elif dir < 0:
		sprite.flip_h = true
		hitbox_col.position.x = -28
		wall_ground_detector.target_position.x = -130
		wall_air_detector.target_position.x = -130
		wall_air_detector_2.target_position.x = -130

func handle_input() -> void:
	if GameManager.can_get_input == false:
		return
	get_dir_input()
	check_movement()
	check_fall()
	
	handle_movement()
	handle_jump()
	handle_fall()
	handle_dash()
	handle_attack()
	#handle_throw() temporary
	handle_facing()

func reset() -> void:
	if is_on_floor():
		jump_count = 0
		can_jump_attack = true
		can_dash = true

#endregion

#region State: One-Time Execution
# only run once after new state
func set_state(new_state: PlayerState) -> void:
	#if is_attacking:
		#return
	if cur_state == new_state:
		return

	cur_state = new_state
	print("Player: ", PlayerState.keys()[cur_state])
	match cur_state:
		PlayerState.IDLE:
			idle()
		PlayerState.RUN:
			run()
		PlayerState.JUMP:
			jump()
		PlayerState.FALL:
			fall()
		PlayerState.DASH:
			dash()
		PlayerState.ATTACK:
			attack()
		PlayerState.JUMP_ATTACK:
			jump_attack()
		PlayerState.THROW:
			throw()
		PlayerState.HURT:
			hurt()

# one-time assignment
func idle() -> void:
	anim.play("idle")

func run() -> void:
	anim.play("run")

func jump() -> void:
	anim.play("jump")
	
func fall() -> void:
	anim.play("fall")

func dash() -> void:
	GameManager.can_get_input = false
	
	velocity = dash_final_dir * dash_speed
	print(velocity)
	
	# animation
	match dash_final_dir:
		Vector2(1.0, 0.0):
			anim.play("dash_right")
		Vector2(-1.0, 0.0):
			anim.play("dash_left")
		Vector2(0.0, -1.0):
			if not sprite.flip_h:
				anim.play("dash_up_right")
			else:
				anim.play("dash_up_left")
	
	await anim.animation_finished
	velocity = Vector2.ZERO
	GameManager.can_get_input = true

func attack() -> void:
	GameManager.can_get_input = false
	set_physics_process(false)
	
	is_attacking = true
	attack_phase = (attack_phase + 1) % attack_cycle
	anim.play("attack_0%s" % str(attack_phase + 1))
	await anim.animation_finished
	is_attacking = false
	
	set_physics_process(true)
	GameManager.can_get_input = true

func jump_attack() -> void:
	is_jump_attack = true
	can_jump_attack = false
	velocity.y = jump_velocity * 0.9
	anim.play("jump_attack")

func throw() -> void:
	# spawn crosshair
	SignalManager.on_throw_blade.emit(get_global_mouse_position(), has_orbitting_blade())

func hurt() -> void:
	GameManager.can_get_input = false
	set_physics_process(true)
	#var dir = sign(global_position.x - enemy_pos.x) # only return the sign
	#if dir == 0.0:
		#dir = 1.0 # normalized
	var dir: float = 0.0
	if sprite.flip_h:
		dir = 1.0
	else:
		dir = -1.0
	velocity.x = dir * 200.0
	velocity.y = -100.0
	anim.play("hurt")
	await anim.animation_finished
	can_hurt = true
	Utils.toggle_collision_shape(hurtbox_col, true)
	
	GameManager.can_get_input = true

func die() -> void:
	print('player die')
#endregion

#region Auxiliary Function
func has_orbitting_blade() -> bool:
	for blade in blades:
		if blade.cur_state == Blade.BladeState.ORBIT:
			return true
	return false
#endregion

#region Damage
func crit_damage() -> int:
	var crit_chance = DataManager.player_crit_chance
	if randf() < crit_chance:
		# freeze the game for a while
		SignalManager.on_player_crit.emit()
		return DataManager.get_player_crit_multiplier()
	return 1

func final_damage() -> int:
	return DataManager.get_player_dmg() * crit_damage()
	
func take_damage(dmg: int) -> void:
	if can_hurt:
		can_hurt = false
		set_state(PlayerState.HURT)
		Utils.toggle_collision_shape(hurtbox_col, false)
		DataManager.decr_player_hp(dmg)
		# to apply camera shake
		SignalManager.on_player_hurt.emit()

#endregion

#region Who I Hit
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurt"):
		area.get_parent().take_damage(final_damage())
		SignalManager.on_player_hit.emit(area.global_position)
#endregion

#region When Danger Hit Me
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("danger") and can_hurt:
		check_danger(check_danger_collision_pos())
		# apply camera shake
		#SignalManager.on_player_hurt.emit()

func check_danger_collision_pos() -> Vector2:
	var danger_collision_pos: Vector2 = Vector2.ZERO
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		danger_collision_pos = collision.get_position()
		break
	
	return danger_collision_pos

func check_danger(danger_collision_pos: Vector2) -> void:
	# local pos of the danger_tilemap in collision pos
	var local_pos = danger_tilemap.to_local(danger_collision_pos)
	# use that local_pos to find where the map coordinate
	var coords = danger_tilemap.local_to_map(local_pos)
	var tile_data: TileData = danger_tilemap.get_cell_tile_data(coords)

	if tile_data:
		var type = tile_data.get_custom_data("type")
		var dmg
		match type:
			"spike":
				dmg = DataManager.get_spike_dmg()
			"lava":
				pass
	
		take_damage(dmg)
	else:
		take_damage(DataManager.get_dmg_default())
		
#endregion
