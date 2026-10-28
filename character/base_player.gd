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

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var blades = $Blades.get_children()
@onready var hitbox_col: CollisionShape2D = $Hitbox/HitboxCollision
@onready var hurtbox_col: CollisionShape2D = $Hurtbox/HurtboxCollision
@onready var wall_ground_detector: RayCast2D = $WallGroundDetector
@onready var wall_air_detector: RayCast2D = $WallAirDetector
@onready var wall_air_detector_2: RayCast2D = $WallAirDetector2
@onready var checkpoint_timer: Timer = $CheckpointTimer
@onready var teleport_timer: Timer = $TeleportTimer
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var state_sound: AudioStreamPlayer2D = $StateSound

@export var speed: float = 180.0
@export var dash_speed: float = 500.0
@export var jump_velocity: float = -280.0
@export var fall_velocity: float = 300.0
@export var gravity_scale: float = 0.5
@export var max_jumps = 2
@export var attack_cycle: int = 2
@export var danger_tilemap: TileMapLayer

var cur_state: PlayerState = PlayerState.IDLE
var dir: float = 0.0

# jump
var jump_count = 0
var jump_cut_multiplier: float = 0.4 # to slower the jump speed when button released

# attack
var is_attacking: bool = false
var attack_phase: int = 1 # slash type
var is_jump_attack: bool = false
var can_jump_attack: bool = true

# hurt
var can_hurt: bool = true

# dash
var can_dash: bool = true
var dash_final_dir: Vector2

# checkpoint
var can_put_checkpoint: bool = true
var can_teleport: bool = true

var can_get_input: bool = true
var enemy_pos: Vector2 = Vector2.ZERO

# for squash effect
var base_scale: Vector2
var was_on_floor: bool = true
var squash_tween: Tween

# override attack left-click event
var skip_input_steps := 0
var attack_requested: bool = false

func _ready() -> void:
	# signal: from player_ui, if it's progress is empty - then die
	SignalManager.on_player_die.connect(die)
	base_scale = sprite.scale # set the base_scale

func _input(event: InputEvent) -> void:
	if not can_get_input:
		return
	if event.is_action_pressed("left-click") \
			and get_viewport().gui_get_hovered_control() == null:
		attack_requested = true

func _unhandled_input(event: InputEvent) -> void:
	if not can_get_input:
		return
	# set checkpoint
	if event.is_action_pressed("set-checkpoint") and check_checkpoint():
		# set a new checkpoint position
		GameData.set_checkpoint_pos(global_position)
		# signal: spawn checkpoint sprite from level.gd
		SignalManager.on_player_put_checkpoint.emit(global_position)
		can_put_checkpoint = false
		checkpoint_timer.start()
		print("set checkpoint: " + str(global_position))
	# teleport to checkpoint
	if event.is_action_pressed("to_checkpoint") and can_teleport:
		# player cannot teleport for at least 3s
		can_teleport = false
		can_get_input = false
		teleport_timer.start()
		global_position = GameData.get_checkpoint_pos()
		entrance()
		can_get_input = true
		print("back to checkpoint")

func _physics_process(delta: float) -> void:
	# gravity shouldn't be applied when player dash
	if cur_state != PlayerState.DASH:
		apply_gravity(delta)
	
	#handle all input to movement, jump, and other states
	handle_input()
	handle_throw() # not affected by can_get_input variable
	move_and_slide()
	
	# if player land, squash a bit
	check_land()
	
	# all that need to be reset (jump, dash, etc)
	reset() 
	attack_requested = false
	
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

func check_land() -> void:
	if is_on_floor() and not was_on_floor and sprite.scale == base_scale:
		SoundManager.play_clip(sound, SoundManager.LAND_SOUND, 0.5, 0.7)
		squash()
	was_on_floor = is_on_floor()

func check_checkpoint() -> bool:
	# a condition on putting checkpoint
	if not (is_on_floor() and \
	   cur_state == PlayerState.IDLE and \
	   can_put_checkpoint):
		return false
	var floor_group := ground_detector.get_collider()
	return floor_group != null and floor_group.is_in_group(Constants.WORLD_GROUP)

func handle_movement() -> void:
	if dir != 0:
		velocity.x = dir * speed
	else:
		# gradually slow down
		velocity.x = move_toward(velocity.x, 0, speed)

func handle_jump() -> void:
	# Start jump
	if Input.is_action_just_pressed("jump") and \
	   jump_count < max_jumps and \
	   not is_jump_attack:
		set_state(PlayerState.JUMP)
		velocity.y = jump_velocity
		if is_on_floor():
			jump_count += 1
		# when jump on air
		else:
			jump_count += max_jumps
			# signal: spawn air effect on air from object_container
			SignalManager.on_jump_on_air.emit(global_position)
			SoundManager.play_clip(sound, SoundManager.AIRED_SOUND, 3.0, 1.0)
	# Release early = shorter jump
	if Input.is_action_just_released("jump") and velocity.y < 0.0 and not is_jump_attack:
		if can_get_input:
			velocity.y *= jump_cut_multiplier

func handle_fall() -> void:
	if Input.is_action_just_pressed("down") and \
	   not is_on_floor() and \
	   cur_state != PlayerState.JUMP_ATTACK:
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
				 (wall_air_detector.is_colliding() or wall_air_detector_2.is_colliding() or \
				 wall_ground_detector.is_colliding()):
				return
	
		dash_final_dir = final_dir
		set_state(PlayerState.DASH)
			

func handle_attack() -> void:
	if attack_requested:
		attack_requested = false
		if is_on_floor() and not is_attacking and cur_state != PlayerState.JUMP:
			set_state(PlayerState.ATTACK)
		else:
			if can_jump_attack:
				set_state(PlayerState.JUMP_ATTACK)
	
	if Input.is_action_just_released("left-click") and not is_on_floor() and cur_state != PlayerState.FALL:
		if can_get_input:
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


# --- Pause/resume click guard ---
# Problem: the click on "Continue" also counts as an attack.
# In _physics_process, Input.is_action_just_pressed() is true only for the
# physics step that follows the click (call it step P).
# The click arrives while the game is paused, so the player has not run step P yet.
# If the game unpauses before step P, the player sees the click as a new press and attacks.
#
# Fix: when the tree unpauses, ignore input for the first few physics steps.
# The first step the player runs is either P (skipped) or later (the click window
# has already passed), so the click can never trigger an attack.
# Two(2) steps is used as a safety margin.

# _notification is called whenever something happens
func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED:
		skip_input_steps = 2

func handle_input() -> void:
	if can_get_input == false:
		return
	if skip_input_steps > 0:
		skip_input_steps -= 1
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
		is_jump_attack = false
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
	SoundManager.play_clip(state_sound, SoundManager.SILENT, 0.0, 1.0)
	

func run() -> void:
	anim.play("run")
	SoundManager.play_clip(state_sound, SoundManager.FOOTSTEPS_SOUND, 2.0, 1.0)

func jump() -> void:
	anim.play("jump")
	SoundManager.play_clip(state_sound, SoundManager.SILENT, 0.0, 1.0)

func fall() -> void:
	anim.play("fall")
	SoundManager.play_clip(state_sound, SoundManager.SILENT, 0.0, 1.0)

func dash() -> void:
	SoundManager.play_clip(state_sound, SoundManager.DASH_SOUND, 1.0, 1.0)
	set_physics_process(true)
	can_get_input = false
	can_dash = false
	velocity = dash_final_dir * dash_speed
	
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
	velocity = Vector2.ZERO # go to IDLE state
	can_get_input = true

func attack() -> void:
	can_get_input = false
	set_physics_process(false)
	
	is_attacking = true
	attack_phase = (attack_phase + 1) % attack_cycle
	anim.play("attack_0%s" % str(attack_phase + 1))
	await anim.animation_finished
	is_attacking = false
	
	set_physics_process(true)
	can_get_input = true

func jump_attack() -> void:
	is_jump_attack = true
	can_jump_attack = false
	velocity.y = jump_velocity * 0.9
	anim.play("jump_attack")

func throw() -> void:
	# signal: spawn crosshair to increase readability from object_container
	SignalManager.on_throw_blade.emit(get_global_mouse_position(), has_orbitting_blade())

func hurt() -> void:
	can_get_input = false
	set_physics_process(true)
	Utils.toggle_collision_shape(hurtbox_col, false)
	
	var dir: float = sign(global_position.x - enemy_pos.x)
	if dir == 0.0: dir = 1.0 # normalized
	velocity.x = dir * 200.0
	velocity.y = -100.0
	
	anim.play("hurt")
	await anim.animation_finished
	
	can_hurt = true
	Utils.toggle_collision_shape(hurtbox_col, true)
	can_get_input = true

func die() -> void:
	print('player die')
#endregion

#region Auxiliary Function
func has_orbitting_blade() -> bool:
	# this function is for crosshair, it goes 'normal' if there exist a blade orbitting
	# and turn 'red' if there is none
	for blade in blades:
		if blade.cur_state == Blade.BladeState.ORBIT:
			return true
	return false

func entrance() -> void:
	# to zoom in player from 0.3 scale back to 1.0 scale for 0.5s
	sprite.scale = Vector2(0.3, 0.3)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "scale", base_scale, 0.5)
	await tween.finished

func transition() -> void:
	set_enemies_active(false) # enemies paused
	
	# create new canvas layer
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	# create new ColorRect
	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(fade_rect)

	# 1. fade to black
	var fade_out := create_tween()
	fade_out.tween_property(fade_rect, "color:a", 1.0, 0.2)
	await fade_out.finished

	# 2. blackout: teleport, then let the player fall and settle
	velocity = Vector2.ZERO
	global_position = GameData.get_checkpoint_pos()
	anim.speed_scale = 1.0 # resume the animations
	sprite.self_modulate = Color.WHITE # turn normal
	set_physics_process(true) # so player can fall and can throw blade (not restricted by input disability)
	await get_tree().create_timer(0.3).timeout # wait till everything is settled
	set_state(PlayerState.IDLE)

	# 3. fade in
	entrance() # zoom in player
	var fade_in := create_tween()
	fade_in.tween_property(fade_rect, "color:a", 0.0, 0.5)
	await fade_in.finished

	layer.queue_free()
	set_enemies_active(true) # enemies resume
	
func set_enemies_active(active: bool) -> void:
	var mode := Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	for enemy in get_tree().get_nodes_in_group(Constants.ENEMY_BODY_GROUP):
		enemy.process_mode = mode

func squash() -> void:
	if squash_tween:
		squash_tween.kill() # avoid two tweens fighting over scale

	sprite.scale = Vector2(base_scale.x * 1.1, base_scale.y * 0.9)

	squash_tween = create_tween()
	squash_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	squash_tween.tween_property(sprite, "scale", base_scale, 0.2)

func play_attack_sound() -> void:
	# call it in AnimationPlayer
	SoundManager.play_clip(state_sound, SoundManager.KNIFE_SWING_SOUND, 0.0, randf_range(1.0, 2.0))
#endregion

#region Damage
func crit_damage() -> int:
	var crit_chance = GameData.player_crit_chance
	if randf() < crit_chance:
		# signal: to freeze the game for a while in level scene
		SignalManager.on_player_crit.emit()
		return GameData.get_player_crit_multiplier() # if successfully return: 3
	return 1

func final_damage() -> int:
	return GameData.get_player_dmg() * crit_damage()
	
func take_damage(dmg: int, enemy_pos: Vector2, reaction: bool) -> void:
	# PARAM "enemy_pos": to set enemy pos to determine the direction of the knockback reaction
	# PARAM "reaction": to determine whether player is knockbacked or not
	if can_hurt:
		can_hurt = false
		self.enemy_pos = enemy_pos
		GameData.decr_player_hp(dmg)
	if reaction: 
		set_state(PlayerState.HURT)
	
	SignalManager.on_player_hurt.emit() # signal: to apply camera shake from level scene, camera take argument - so no input
	SignalManager.on_player_hurt.emit(global_position) # signal: to emit slash effect from object_container

#endregion

#region Who I Hit
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(Constants.ENEMY_HURT_GROUP):
		area.get_parent().take_damage(final_damage(), global_position)
#endregion

#region When Danger Hit Me
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group(Constants.DANGER_GROUP) and can_hurt:
		hit_danger()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(Constants.DANGER_GROUP) and can_hurt:
		hit_danger()

func hit_danger() -> void:
	# when player is hit, fade black -> enemy and all animation freezed ->
	# player go back to last checkpoint -> player IDLE -> fade in -> game resume
	take_damage(GameData.get_spike_dmg(), Vector2.ZERO, false)
	set_physics_process(false)
	# disable any input
	can_get_input = false
	sprite.self_modulate = Color(3.0, 0.0, 0.0) # turn player to red since we are not calling set_state(HURT) to apply its reaction
	anim.speed_scale = 0.0 # freeze the current animation
	
	# 0.2s timeout is to wait for a slash effect and then blackout
	await get_tree().create_timer(0.2).timeout
	await transition()
	
	can_hurt = true
	can_get_input = true # enable all input
	
#endregion

#region Timer
func _on_checkpoint_timer_timeout() -> void:
	# 3s
	can_put_checkpoint = true
#endregion

func _on_teleport_timer_timeout() -> void:
	# 3s
	can_teleport = true
