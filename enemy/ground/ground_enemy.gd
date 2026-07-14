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

var cur_state: GroundEnemyState = GroundEnemyState.IDLE

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
	pass

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
	pass
	
func die() -> void:
	pass
	
