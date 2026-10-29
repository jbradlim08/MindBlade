extends StaticBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var hurt_point: Marker2D = $HurtPoint

func _physics_process(_delta: float) -> void:
	anim.play("idle")


func take_damage(_dmg: float, _pos: Vector2) -> void:
	set_physics_process(false)
	# to emit slash effect
	SignalManager.on_enemy_hurt.emit(hurt_point.global_position)
	SoundManager.play_clip(sound, SoundManager.DUMMY_HURT_SOUND, 5.0, randf_range(1.0, 2.0))
	anim.play("hurt")
	await anim.animation_finished
	set_physics_process(true)
