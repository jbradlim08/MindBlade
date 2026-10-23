extends Area2D

enum DIRECTION{
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sound: AudioStreamPlayer2D = $Sound

		

func _on_attack_domain_body_entered(body: Node2D) -> void:
	if body.is_in_group(Constants.PLAYER_BODY_GROUP):
		SoundManager.play_clip(sound, SoundManager.SPEAR_THRUST_SOUND, 0.0, 1.0)
		anim.play("thrust")
