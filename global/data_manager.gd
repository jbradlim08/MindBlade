extends Node

#region Scene
var freeze_timer: float = 0.2

func get_freeze_timer() -> float: return freeze_timer
#endregion

#region Player
var cur_player_hp: int = 150
var max_player_hp: int = 150

func get_player_hp() -> int: return cur_player_hp
func get_max_player_hp() -> int: return max_player_hp
func set_player_hp(new_hp: int) -> void: cur_player_hp = new_hp
func incr_player_hp(hp: int) -> void: cur_player_hp += hp
func decr_player_hp(hp: int) -> void: cur_player_hp -= hp

var player_dmg: int = 10
var player_crit_multiplier: int = 3
var player_crit_chance: float = 0.2

func get_player_dmg() -> int: return player_dmg
func get_player_crit_multiplier() -> int: return player_crit_multiplier
#endregion

#region Blade
var blade_dmg: int = 10

func get_blade_dmg() -> int: return blade_dmg
#endregion

#region Danger
var dmg_default: int = 10 # if collision fails
var spike_dmg: int = 10

func get_dmg_default() -> int: return dmg_default
func get_spike_dmg() -> int: return spike_dmg
#endregion

#region Enemy
var dummy_hp: int = 250
var headknife_hp: int = 100

func get_dummy_hp() -> int: return dummy_hp
func get_headknife_hp() -> int: return headknife_hp
#endregion
