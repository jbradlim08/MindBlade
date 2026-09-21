extends BaseEnemy

class_name HeadKnife

enum HKState{
	IDLE,
	PATROL,
	CHARGE,
	FALL,
	ATTACK,
	HURT,
	DIE
}

@onready var anim: AnimationPlayer = $AnimationPlayer

@export var gravity_scale: float = 0.5
@export var is_hurt: bool = false

var cur_state: HKState
var dir: float = 0.0

func _ready() -> void:
	set_state(HKState.IDLE)
	hp = DataManager.get_headknife_hp()
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	
	apply_gravity(delta)
	check_movement()
	check_fall()
	move_and_slide()

func apply_gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta
		
func check_movement() -> void:
	if not is_on_floor() or is_hurt:
		return
	if dir != 0:
		set_state(HKState.PATROL)
	else:
		set_state(HKState.IDLE)

func check_fall() -> void:
	if not is_on_floor():
		if velocity.y >= 0:
			set_state(HKState.FALL)
			# this is to prevent throw state condition being paused

func check_hurt() -> void:
	is_hurt = false

#region State
func set_state(new_state: HKState) -> void:
	if cur_state == new_state:
		return
		
	cur_state = new_state
	print("HK: ", HKState.keys()[cur_state])
	
	match cur_state:
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
	print('enemy idle')
	pass

func patrol() -> void:
	pass

func charge() -> void:
	pass

func attack() -> void:
	pass
	
func jump() -> void:
	pass
	
func fall() -> void:
	pass
	
func hurt() -> void:
	is_hurt = true
	print("enemy hurt")
	
func die() -> void:
	set_physics_process(false)
	set_state(HKState.DIE)
	super()

#endregion

#region HealthPoint
func take_damage(amount: int, player_pos: Vector2) -> void:
	set_state(HKState.HURT)
	super(amount, player_pos)

#endregion

#region Signal

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurt"):
		area.get_parent().take_damage(DataManager.get_dmg_default(), global_position)

#endregion
