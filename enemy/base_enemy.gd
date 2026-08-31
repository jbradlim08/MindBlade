extends CharacterBody2D

class_name BaseEnemy


@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var hitbox: Area2D = $Hitbox
@onready var health_bar: TextureProgressBar = $EnemyHealthBar

@export var gravity_scale = 0.5

var player_ref: Player
var hp: float
var points: int

func _ready() -> void:
	add_to_group(Constants.ENEMY_GROUP)
	player_ref = get_tree().get_first_node_in_group(
		 Constants.PLAYER_GROUP
	)
	# setup the initial hp for enemy
	health_bar.init_setup(hp)

func _physics_process(delta: float) -> void:
	pass


func take_damage(amount: int) -> void:
	hp -= amount
	print(hp)
	if hp <= 0.0:
		print('die enemy')
		die()


func die() -> void:
	pass
