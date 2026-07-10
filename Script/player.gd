extends CharacterBody2D

class_name Player

enum PlayerState {
	IDLE,
	RUN,
	ATTACK,
	JUMP,
	FALL
}

const GROUP_NAME: String = 'player'
const SPEED: float = 350.0
const JUMP_VELOCITY: float = -450.0
const FALL_VELOCITY: float = 550.0
const MAX_JUMPS = 2
const OFFSET: Vector2 = Vector2(-2.87, 0)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var blades = $Blades.get_children()
@onready var blade: Blade = $Blades/Blade

var cur_state: PlayerState = PlayerState.IDLE
var direction: float = 0.0
var is_attacking: bool = false
var jump_count = 0

func _ready() -> void:
	add_to_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			is_attacking = true
		else:
			is_attacking = false

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
		velocity += get_gravity() * delta


func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

func reset_jump() -> void:
	if is_on_floor():
		jump_count = 0

func handle_fall() -> void:
	if Input.is_action_just_pressed("down") and not is_on_floor():
		velocity.y = FALL_VELOCITY

func handle_movement() -> void:
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func update_facing() -> void:
	if direction > 0:
		anim.flip_h = false
		anim.offset = OFFSET
	elif direction < 0:
		anim.flip_h = true
		anim.offset = -OFFSET

func update_state() -> void:
	if is_attacking:
		change_state(PlayerState.ATTACK)
		return

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
	for blade in blades:
		if blade.cur_state == Blade.BladeState.ORBIT:
			blade.init_throw(get_global_mouse_position())
			return
	
	print("No blade available")
	
