extends CharacterBody2D

class_name BaseEnemy


@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var hitbox: Area2D = $Hitbox
@onready var health_bar: TextureProgressBar = $EnemyHealthBar

@export var is_exhibition: bool = false

var player_ref: Player
var hp: float
var points: int

func _ready() -> void:
	add_to_group(Constants.ENEMY_GROUP)
	player_ref = get_tree().get_first_node_in_group(
		 Constants.PLAYER_GROUP
	)
	# setup the initial hp for enemy
	health_bar.hide()
	health_bar.init_setup(hp)
	# check if this enemy is just exhibition in lobby

func _physics_process(delta: float) -> void:
	pass


func take_damage(amount: int) -> void:
	health_bar.show()
	hp -= amount
	if hp <= 0.0:
		die() # refer to its child (ground, air, tower)


func die() -> void:
	pass
