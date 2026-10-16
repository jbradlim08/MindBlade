class_name GameData

static var absolute_dmg: int = 1000

static func get_absolute_dmg() -> int: return absolute_dmg

#region Scene
static var freeze_timer: float = 0.3

static func get_freeze_timer() -> float: return freeze_timer
#endregion

#region Player
static var cur_player_hp: int = 150
static var max_player_hp: int = 150

static func get_player_hp() -> int: return cur_player_hp
static func get_max_player_hp() -> int: return max_player_hp
static func set_player_hp(new_hp: int) -> void: cur_player_hp = new_hp
static func incr_player_hp(hp: int) -> void: cur_player_hp += hp
static func decr_player_hp(hp: int) -> void: cur_player_hp -= hp

static var player_dmg: int = 20
static var player_crit_multiplier: int = 3
static var player_crit_chance: float = 0.2

static func get_player_dmg() -> int: return player_dmg
static func get_player_crit_multiplier() -> int: return player_crit_multiplier
#endregion

#region Blade
static var blade_dmg: int = 20

static func get_blade_dmg() -> int: return blade_dmg
#endregion

#region Danger
static var dmg_default: int = 10 # if collision fails
static var spike_dmg: int = 10

static func get_dmg_default() -> int: return dmg_default
static func get_spike_dmg() -> int: return spike_dmg
#endregion

#region Enemy
static var headknife_hp: int = 100
static var headknife_dmg: int = 10

static func get_headknife_hp() -> int: return headknife_hp
static func get_headknife_dmg() -> int: return headknife_dmg
#endregion

#region Level
static var checkpoint_pos: Vector2

static func get_checkpoint_pos() -> Vector2: return checkpoint_pos
static func set_checkpoint_pos(val: Vector2) -> void: checkpoint_pos = val

static var level_start_pos: Dictionary = {
	0: Vector2(498.0, -16),
	1: Vector2(368, 488),
}

static func get_level_start_pos(level: int) -> Vector2:
	return level_start_pos[level]
