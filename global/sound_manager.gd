extends Node

const SILENT = "silent"
const MENU_SELECTION_SOUND = "menu_selection"
const KNIFE_SWING_SOUND = "knife_swing"
const KNIFE_JUMP_ATTACK_SOUND = "knife_jump_attack"
const FOOTSTEPS_SOUND = "footsteps"
const HEADKNIFE_HURT_SOUND = "headknife_hurt"
const TING_SOUND = "ting"

var SOUNDS: Dictionary = {
	SILENT: "silent",
	MENU_SELECTION_SOUND: preload("res://asset/sound/menu_selection_sound.wav"),
	KNIFE_SWING_SOUND: preload("res://asset/sound/knife_swing_sound.wav"),
	KNIFE_JUMP_ATTACK_SOUND: preload("res://asset/sound/knife_jump_attack_sound.wav"),
	FOOTSTEPS_SOUND: preload("res://asset/sound/footsteps_sound.wav"),
	HEADKNIFE_HURT_SOUND: preload("res://asset/sound/headknife_hurt_sound.wav"),
	TING_SOUND: preload("res://asset/sound/ting_sound.wav")
}

func play_clip(player: AudioStreamPlayer2D, clip_key: String, volume: float, pitch_scale: float) -> void:
	if SOUNDS.has(clip_key) == false:
		return
	if clip_key == "silent":
		player.stop()
		return
	player.stream = SOUNDS[clip_key]
	player.volume_db = volume
	player.pitch_scale = pitch_scale
	player.play()
