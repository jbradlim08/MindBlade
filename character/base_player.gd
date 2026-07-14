extends CharacterBody2D

class_name Player

enum PlayerState {
	IDLE,
	RUN,
	ATTACK,
	THROW,
	JUMP,
	FALL,
	HURT,
	DIE
}

@export var speed: float = 180.0
@export var jump_velocity: float = -280.0
@export var fall_velocity: float = 300.0
@export var gravity_scale: float = 0.5
@export var max_jumps = 2
@export var offset: Vector2 = Vector2(-2.87, 0)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var blades = $Blades.get_children()

var cur_state: PlayerState = PlayerState.IDLE
var dir: float = 0.0
#var is_attacking: bool = false
var jump_count = 0
var jump_cut_multiplier: float = 0.4

func _ready() -> void:
	add_to_group(Constants.PLAYER_GROUP)

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
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_velocity
		jump_count += 1

	# Release early = shorter jump
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

func reset_jump() -> void:
	if is_on_floor():
		jump_count = 0

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
	if dir > 0:
		anim.flip_h = false
		anim.offset = offset
	elif dir < 0:
		anim.flip_h = true
		anim.offset = -offset

func update_state() -> void:
	if is_on_floor():
		if dir != 0:
			set_state(PlayerState.RUN)
		else:
			set_state(PlayerState.IDLE)
		
	if not is_on_floor():
		if velocity.y < 0:
			set_state(PlayerState.JUMP)
		else:
			set_state(PlayerState.FALL)
		
	if Input.is_action_just_pressed("right-click"):
		print('right here')
		set_state(PlayerState.THROW)


func set_state(new_state: PlayerState) -> void:
	if cur_state == new_state:
		return

	cur_state = new_state
	print(PlayerState.keys()[cur_state])
	match cur_state:
		PlayerState.IDLE:
			idle()
		PlayerState.RUN:
			run()
		PlayerState.ATTACK:
			attack()
		PlayerState.THROW:
			throw()
		PlayerState.JUMP:
			jump()
		PlayerState.FALL:
			fall()

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
	anim.play("attack")

func throw() -> void:
	pass
