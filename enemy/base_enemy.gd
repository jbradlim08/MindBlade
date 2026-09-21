extends CharacterBody2D

class_name BaseEnemy

signal enemy_die

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var body_col: CollisionShape2D = $BodyCollision
@onready var hitbox_col: CollisionShape2D = $Hitbox/HitboxCollision
@onready var hurtbox_col: CollisionShape2D = $Hurtbox/HurtboxCollision
@onready var health_bar: TextureProgressBar = $HealthBar

var player_ref: Player
var player_pos: Vector2 = Vector2.ZERO
var hp: float
var points: int

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group(
		 Constants.PLAYER_BODY_GROUP
	)
	# setup the initial hp for enemy
	health_bar.hide()
	health_bar.init_setup(hp, hp)
	# check if this enemy is just exhibition in lobby

func _physics_process(_delta: float) -> void:
	pass

#region HealthPoint
func take_damage(amount: int, player_pos: Vector2) -> void:
	self.player_pos = player_pos
	health_bar.show()
	hp -= amount
	health_bar.set_hp(hp)
	print(hp)
	if hp <= 0.0:
		enemy_die.emit() 
	
#endregion
