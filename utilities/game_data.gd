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
static func incr_player_hp(hp: int) -> void: 
	cur_player_hp = clampi(cur_player_hp + hp, 0, max_player_hp) # capped
static func decr_player_hp(hp: int) -> void: 
	cur_player_hp = clampi(cur_player_hp - hp, 0, max_player_hp) # capped

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

#region Item
const MATERIAL_MAX_AMOUNT: int = 200
const RUNE_MAX_AMOUNT: int = 100
const ITEM_LEAST_AMOUNT: int = 0
static var drop_chance: float = 1.0 # collectible drop chance
static var materials: Dictionary[MaterialData, int] = {} 
static var runes: Dictionary[RuneData, int] = {}

static func get_drop_chance() -> float: return drop_chance

static func add_material(material: MaterialData, amount: int = 1) -> void:
	# capped to 100
	if materials.get(material, 0) + amount > MATERIAL_MAX_AMOUNT:
		return
	materials[material] = materials.get(material, 0) + amount
	SignalManager.on_items_changed.emit()

static func subtract_material(material: MaterialData, amount: int) -> void:
	# capped to 0
	if materials.get(material, 0) - amount < ITEM_LEAST_AMOUNT:
		return
	materials[material] = materials.get(material, 0) - amount
	# clear from backpack
	if materials[material] <= 0:
		materials.erase(material)
	SignalManager.on_items_changed.emit()

static func add_rune(rune: RuneData, amount: int = 1) -> void:
	# capped to 100, but the condition is done in crafting_menu due to the material subtraction has to happen first
	runes[rune] = runes.get(rune, 0) + amount
	SignalManager.on_items_changed.emit()

static func subtract_rune(rune: RuneData, amount: int) -> void:
	# capped to 0
	if runes.get(rune, 0) - amount < ITEM_LEAST_AMOUNT:
		return
	runes[rune] = runes.get(rune, 0) - amount
	# clear from backpack
	if runes[rune] <= 0:
		runes.erase(rune)
	SignalManager.on_items_changed.emit()

static func max_craftable_rune(rune: RuneData) -> int:
	var min_req: int = 200
	for material in rune.cost:
		if materials.has(material):
			var craftable_amount: int = materials[material] / rune.cost[material]
			if min_req > craftable_amount:
				min_req = craftable_amount
		else: # if player doesn't have only 1 item, return
			return 0
	return min_req

static func max_sellable_rune(rune: RuneData) -> int:
	if not runes.has(rune):
		return 0
	return runes[rune]
	
#endregion

#region Danger
static var dmg_default: int = 10 # if collision fails
static var spike_dmg: int = 30

static func get_dmg_default() -> int: return dmg_default
static func get_spike_dmg() -> int: return spike_dmg
#endregion

#region Enemy
static var headknife_hp: int = 10
static var headknife_dmg: int = 10

static func get_headknife_hp() -> int: return headknife_hp
static func get_headknife_dmg() -> int: return headknife_dmg
#endregion

#region Level
static var checkpoint_pos: Vector2

static func get_checkpoint_pos() -> Vector2: return checkpoint_pos
static func set_checkpoint_pos(val: Vector2) -> void: checkpoint_pos = val

static var level_start_pos: Dictionary = {
	"base": Vector2(688, 233),
	"level": Vector2(368, 489),
	"tutorial": Vector2(241, 457), 
}

static func get_level_start_pos(level: String) -> Vector2:
	return level_start_pos[level]
#endregion
