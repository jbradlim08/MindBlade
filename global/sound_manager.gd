extends Node

const SILENT = "silent"
const MENU_SELECTION_SOUND = "menu_selection"
const KNIFE_SWING_SOUND = "knife_swing"
const BLADE_SPIN_SOUND = "blade_spin"
const FOOTSTEPS_SOUND = "footsteps"
const DASH_SOUND = "dash"
const HEADKNIFE_HURT_SOUND = "headknife_hurt"
const DUMMY_HURT_SOUND = "dummy_hurt"
const TING_SOUND = "ting"
const AIRED_SOUND = "aired"
const SPEAR_THRUST_SOUND = "spear_thrust"
const LAND_SOUND = "land"
const HOLOGRAM_SOUND = "hologram"
const PICKUP_SOUND = "pickup"
const PLAYER_HURT_SOUND = "player_hurt"
const OPEN_CRAFTING_MENU_SOUND = "open_crafting_menu"
const CLOSE_CRAFTING_MENU_SOUND = "close_crafting_menu"
const RUNE_SELECTED_SOUND = "rune_selected"
const OPEN_BAG_SOUND = "open_bag"
const ERROR_MESSAGE_SOUND = "error_message"
const SPAWN_ITEM_SOUND = "spawn_item"
const CRAFT_SOUND = "craft"

var SOUNDS: Dictionary = {
	SILENT: "silent",
	MENU_SELECTION_SOUND: preload("res://asset/sound/menu_selection_sound.wav"),
	KNIFE_SWING_SOUND: preload("res://asset/sound/knife_swing_sound.wav"),
	BLADE_SPIN_SOUND: preload("res://asset/sound/blade_spin_sound.wav"),
	FOOTSTEPS_SOUND: preload("res://asset/sound/footsteps_sound.wav"),
	DASH_SOUND: preload("res://asset/sound/dash_sound.wav"),
	HEADKNIFE_HURT_SOUND: preload("res://asset/sound/headknife_hurt_sound.wav"),
	DUMMY_HURT_SOUND: preload("res://asset/sound/dummy_hurt_sound.wav"),
	TING_SOUND: preload("res://asset/sound/ting_sound.wav"),
	AIRED_SOUND: preload("res://asset/sound/aired_sound.wav"),
	SPEAR_THRUST_SOUND: preload("res://asset/sound/spear_thrust_sound.wav"),
	LAND_SOUND: preload("res://asset/sound/land_sound.wav"),
	HOLOGRAM_SOUND: preload("res://asset/sound/hologram.wav"),
	PICKUP_SOUND: preload("res://asset/sound/pickup_sound.wav"),
	PLAYER_HURT_SOUND: preload("res://asset/sound/player_hurt.wav"),
	OPEN_CRAFTING_MENU_SOUND: preload("res://asset/sound/open_crafting_menu.wav"),
	CLOSE_CRAFTING_MENU_SOUND: preload("res://asset/sound/close_crafting_menu.wav"),
	RUNE_SELECTED_SOUND: preload("res://asset/sound/rune_selected.wav"),
	OPEN_BAG_SOUND: preload("res://asset/sound/open_bag.wav"),
	ERROR_MESSAGE_SOUND: preload("res://asset/sound/error_message.wav"),
	SPAWN_ITEM_SOUND: preload("res://asset/sound/spawn_item.wav"),
	CRAFT_SOUND: preload("res://asset/sound/craft.wav"),
}

func play_clip(player, clip_key: String, volume: float, pitch_scale: float) -> void:
	if SOUNDS.has(clip_key) == false:
		return
	if clip_key == "silent":
		player.stop()
		return
	player.stream = SOUNDS[clip_key]
	player.volume_db = volume
	player.pitch_scale = pitch_scale
	player.play()
