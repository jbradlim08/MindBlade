extends CharacterBody2D

class_name BasePlayer

enum PlayerState {
	IDLE,
	RUN,
	ATTACK,
	JUMP,
	FALL,
	HURT,
	DIE
}

const GROUP_NAME: String = 'player'

@export var speed: float = 180.0
@export var jump_velocity: float = -250.0
@export var fall_velocity: float = 300.0
@export var gravity_scale: float = 0.5
@export var max_jumps = 2
@export var offset: Vector2 = Vector2(-2.87, 0)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var blades = $Blades.get_children()

var cur_state: PlayerState = PlayerState.IDLE
var direction: float = 0.0
#var is_attacking: bool = false
var jump_count = 0

func _ready() -> void:
	add_to_group(GROUP_NAME)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			change_state(PlayerState.ATTACK)

func _physics_process(delta: float) -> void:
	get_input()
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
	

func get_input() -> void:
	direction = Input.get_axis("left", "right")


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta


func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_velocity
		jump_count += 1

func reset_jump() -> void:
	if is_on_floor():
		jump_count = 0

func handle_fall() -> void:
	if Input.is_action_just_pressed("down") and not is_on_floor():
		velocity.y = fall_velocity

func handle_movement() -> void:
	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func update_facing() -> void:
	if direction > 0:
		anim.flip_h = false
		anim.offset = offset
	elif direction < 0:
		anim.flip_h = true
		anim.offset = -offset

func update_state() -> void:
	#if is_attacking:
		#change_state(PlayerState.ATTACK)
		#return
	if not is_on_floor():
		if velocity.y < 0:
			change_state(PlayerState.JUMP)
		else:
			change_state(PlayerState.FALL)
		return

	if direction != 0:
		change_state(PlayerState.RUN)
	else:
		change_state(PlayerState.IDLE)


func change_state(new_state: PlayerState) -> void:
	if cur_state == new_state:
		return

	cur_state = new_state

	match cur_state:
		PlayerState.IDLE:
			idle()
		PlayerState.RUN:
			run()
		PlayerState.ATTACK:
			attack()
		PlayerState.JUMP:
			jump()
		PlayerState.FALL:
			fall()

func idle() -> void:
	anim.play("idle")

func run() -> void:
	anim.play("run")

func jump() -> void:
	anim.play("jump")
	
func fall() -> void:
	anim.play("fall")
	
func attack() -> void:
	pass
