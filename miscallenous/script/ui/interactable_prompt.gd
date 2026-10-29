extends Area2D

const FADE_TIME: float = 0.2

@onready var pop_up_info: Node2D = $PopUpInfo
@onready var sound: AudioStreamPlayer2D = $Sound

var fade_tween: Tween

func _ready() -> void:
	pop_up_info.modulate.a = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(Constants.PLAYER_BODY_GROUP):
		fade_to(pop_up_info, 1.0)
	SoundManager.play_clip(sound, SoundManager.HOLOGRAM_SOUND, -1.0, 1.0)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(Constants.PLAYER_BODY_GROUP):
		fade_to(pop_up_info, 0.0)

func fade_to(obj: Node2D, alpha: float) -> void:
	if fade_tween:
		fade_tween.kill()   # stop a fade that is still running
	fade_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(obj, "modulate:a", alpha, FADE_TIME)
