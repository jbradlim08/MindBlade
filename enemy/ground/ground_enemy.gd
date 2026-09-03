extends BaseEnemy

class_name GroundEnemy

enum GroundEnemyState{
	IDLE,
	PATROL,
	CHASE,
	JUMP,
	FALL,
	ATTACK,
	HURT,
	DIE
}

@onready var anim: AnimationPlayer = $AnimationPlayer

@export var gravity_scale: float = 0.5

var cur_state: GroundEnemyState = GroundEnemyState.IDLE
var dir: float

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	
	match cur_state:
		GroundEnemyState.IDLE:
			idle()
		GroundEnemyState.PATROL:
			patrol()
		GroundEnemyState.CHASE:
			chase()
		GroundEnemyState.ATTACK:
			attack()
		GroundEnemyState.JUMP:
			jump()
		GroundEnemyState.FALL:
			fall()
		GroundEnemyState.HURT:
			hurt()
		GroundEnemyState.DIE:
			die()
	
	apply_gravity(delta)
	move_and_slide()
		
func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

func update_state() -> void:
	if is_on_floor():
		if dir != 0:
			set_state(GroundEnemyState.CHASE)
		else:
			set_state(GroundEnemyState.IDLE)

func set_state(new_state: GroundEnemyState) -> void:
	if cur_state == new_state:
		return
		
	cur_state = new_state
	
	match cur_state:
		GroundEnemyState.IDLE:
			anim_state.travel("idle")
		GroundEnemyState.PATROL:
			anim_state.travel("patrol")
		GroundEnemyState.CHASE:
			anim_state.travel("chase")
		GroundEnemyState.ATTACK:
			anim_state.travel("attack")
		GroundEnemyState.JUMP:
			anim_state.travel("jump")
		GroundEnemyState.FALL:
			anim_state.travel("fall")
		GroundEnemyState.HURT:
			anim_state.travel("hurt")
		GroundEnemyState.DIE:
			anim_state.travel("die")

func idle() -> void:
	anim.play("idle")

func patrol() -> void:
	pass

func chase() -> void:
	pass

func attack() -> void:
	pass
	
func jump() -> void:
	pass
	
func fall() -> void:
	pass
	
func hurt() -> void:
	set_physics_process(false)
	anim.play("hurt")
	await anim.animation_finished
	set_physics_process(true)
	
func die() -> void:
	queue_free()
	

func _on_hurtbox_body_entered(_body: Node2D) -> void:
	set_state(GroundEnemyState.HURT)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	set_state(GroundEnemyState.HURT)
	if area.is_in_group("player_hit") or area.is_in_group("blade_hit"):
		take_damage(DataManager.get_player_dmg())
		health_bar.set_hp(hp)
