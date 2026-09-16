extends CharacterBody2D

class_name BaseEnemy

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var hitbox: Area2D = $Hitbox
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
		die() # refer to its child (ground, air, tower)
	
#endregion

func die() -> void:
	pass
