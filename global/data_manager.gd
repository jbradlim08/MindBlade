extends Node

# Player
var cur_player_hp: int = 100
var max_player_hp: int = 100

func get_player_hp() -> int: return cur_player_hp
func set_player_hp(new_hp: int) -> void: cur_player_hp = new_hp
func incr_player_hp(hp: int) -> void: cur_player_hp += hp
func decr_player_hp(hp: int) -> void: cur_player_hp -= hp

var player_dmg: int = 10

func get_player_dmg() -> int : return player_dmg

# Danger
var dmg_default: int = 10 # if collision fails
var spike_dmg: int = 10

func get_dmg_default() -> int: return dmg_default
func get_spike_dmg() -> int: return spike_dmg

# Enemy
var dummy_hp: int = 250

func get_dummy_hp() -> int: return dummy_hp
