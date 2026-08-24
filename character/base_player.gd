extends CharacterBody2D

class_name Player

enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	JUMP_ATTACK,
	THROW,
	HURT,
	DIE
}

@export var speed: float = 180.0
@export var jump_velocity: float = -280.0
@export var fall_velocity: float = 300.0
@export var gravity_scale: float = 0.5
@export var max_jumps = 2
@export var attack_cycle: int = 2

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var blades = $Blades.get_children()
@onready var hitbox: CollisionShape2D = $Hitbox/CollisionShape2D

var cur_state: PlayerState = PlayerState.IDLE
var dir: float = 0.0
var jump_count = 0
var jump_cut_multiplier: float = 0.4
var is_attacking: bool = false
var attack_phase: int = 1 # slash type
var is_jump_attack: bool = false
var can_jump_attack: bool = true

func _ready() -> void:
	add_to_group(Constants.PLAYER_GROUP)
	anim.animation_finished.connect(_on_animation_finished)

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			#set_state(PlayerState.THROW)

func _physics_process(delta: float) -> void:
	get_dir_input()
	apply_gravity(delta)
	handle_jump()
	handle_fall()
	handle_movement()
	update_facing()
	update_hitbox_dir()
	if is_attacking:
		return
	move_and_slide()
	
	# reset jump if satisfied
	reset_jump()
	
	# update state every process
	update_state()
	

func get_dir_input() -> void:
	dir = Input.get_axis("left", "right")


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta


func handle_jump() -> void:
	# Start jump
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps and not is_jump_attack:
		velocity.y = jump_velocity
		if is_on_floor():
			jump_count += 1
		# when jump on air
		else:
			jump_count += max_jumps
			SignalManager.on_jump_on_air.emit(global_position)
			
	# Release early = shorter jump
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

func reset_jump() -> void:
	if is_on_floor():
		jump_count = 0
		can_jump_attack = true

func handle_fall() -> void:
	if Input.is_action_just_pressed("down") and not is_on_floor():
		velocity.y = fall_velocity

func handle_movement() -> void:
	if dir != 0:
		velocity.x = dir * speed
	else:
		# gradually slow down
		velocity.x = move_toward(velocity.x, 0, speed)

func update_facing() -> void:
	if cur_state == PlayerState.JUMP_ATTACK:
		sprite.flip_h = sprite.flip_h
		return
	if dir > 0:
		sprite.flip_h = false
	elif dir < 0:
		sprite.flip_h = true

func update_hitbox_dir() -> void:
	if sprite.flip_h == false:
		hitbox.position.x = 28
	else:
		hitbox.position.x = -28

func update_state() -> void:
	if is_on_floor():
		if dir != 0:
			set_state(PlayerState.RUN)
		else:
			set_state(PlayerState.IDLE)
		
	if not is_on_floor():
		if velocity.y >= 0:
			is_jump_attack = false
			# this is to prevent throw state condition being paused
		if not is_jump_attack:
			if velocity.y < 0:
				set_state(PlayerState.JUMP)
			else:
				set_state(PlayerState.FALL)
		
	if Input.is_action_just_pressed("right-click"):
		SignalManager.on_right_click.emit(get_global_mouse_position(), has_orbitting_blade())
		set_state(PlayerState.THROW)
	
	if Input.is_action_just_pressed("left-click"):
		if is_on_floor():
			set_state(PlayerState.ATTACK)
		else:
			if can_jump_attack:
				set_state(PlayerState.JUMP_ATTACK)


func set_state(new_state: PlayerState) -> void:
	if is_attacking:
		return
		
	if cur_state == new_state:
		return

	cur_state = new_state
	print(PlayerState.keys()[cur_state])
	match cur_state:
		PlayerState.IDLE:
			idle()
		PlayerState.RUN:
			run()
		PlayerState.JUMP:
			jump()
		PlayerState.FALL:
			fall()
		PlayerState.ATTACK:
			attack()
		PlayerState.JUMP_ATTACK:
			jump_attack()
		PlayerState.THROW:
			throw()

# one-time assignment
func idle() -> void:
	anim.play("idle")

func run() -> void:
	anim.play("run")

func jump() -> void:
	anim.play("jump")
	
func fall() -> void:
	anim.play("fall")

func attack() -> void:
	is_attacking = true
	attack_phase = (attack_phase + 1) % attack_cycle
	anim.play("attack_0%s" % str(attack_phase + 1))

func jump_attack() -> void:
	is_jump_attack = true
	anim.play("jump_attack")
	velocity.y = jump_velocity * 0.8

func throw() -> void:
	pass

func hurt() -> void:
	pass

func die() -> void:
	pass

func has_orbitting_blade() -> bool:
	for blade in blades:
		if blade.cur_state == Blade.BladeState.ORBIT:
			return true
	return false

func _on_animation_finished(anim_name) -> void:
	if anim_name == "attack_01" or anim_name == "attack_02":
		is_attacking = false
	if anim_name == "jump_attack":
		can_jump_attack = false
