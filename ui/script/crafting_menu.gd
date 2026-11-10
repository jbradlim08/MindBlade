extends Control

const RUNE_DIR := "res://item/rune/rune_resources/"
const RUNE_ENTRY = preload("uid://c3eummyjmckb7")
const COST_ENTRY = preload("uid://bteykmemn2xgk")

@onready var rune_list: VBoxContainer = $TextureRect/MarginContainer/HBoxContainer/RunePanel/RuneList
@onready var cost_list: VBoxContainer = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/Cost/CostList

@onready var rune_name: Label = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/RuneName

@onready var craft_slider: HSlider = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/CraftButton/CraftSlider
@onready var sell_slider: HSlider = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/SellButton/SellSlider
@onready var craftable_amount: Label = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/CraftButton/CraftableAmount
@onready var sellable_amount: Label = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/SellButton/SellableAmount
@onready var craft_button: TextureButton = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/CraftButton/CraftButton
@onready var sell_button: TextureButton = $TextureRect/MarginContainer/HBoxContainer/DetailPanel/SellButton/SellButton

var all_runes: Array[RuneData] = []
var selected_rune: RuneData
var group := ButtonGroup.new()

var craft_zero_item_message: String = "nothing to craft"
var sell_zero_item_message: String = "nothing to sell"

func _ready() -> void:
	# every time GameData items change, update the slider, else remain the same
	SignalManager.on_items_changed.connect(update_sliders)
	# everytime slider value changed, the text is also updated
	craft_slider.value_changed.connect(_on_craft_slider_changed)# everytime slider value changed, the text is also updated
	sell_slider.value_changed.connect(_on_sell_slider_changed)
	load_all_runes()
	build_rune_list()

func load_all_runes() -> void:
	# load from runes_resources folder
	for file in DirAccess.get_files_at(RUNE_DIR):
		file = file.trim_suffix(".remap")   # exported games rename files to .tres.remap
		if not file.ends_with(".tres"):
			continue
		var rune := load(RUNE_DIR + file) as RuneData # load the file as RuneData
		if rune:
			all_runes.append(rune)

func build_rune_list() -> void:
	for r in rune_list.get_children():
		r.queue_free() # refresh
	var first_entry = null
	for rune in all_runes:
		var entry = RUNE_ENTRY.instantiate()
		rune_list.add_child(entry)
		entry.button_group = group
		entry.texture_normal = rune.icon
		entry.pressed.connect(select_rune.bind(rune))
		if first_entry == null:
			first_entry = entry
			
	# first entry is for the first button to be pressed
	first_entry.button_pressed = true
	select_rune(all_runes[0])

func select_rune(rune: RuneData) -> void:
	selected_rune = rune
	load_selected_rune_info(selected_rune)

func load_selected_rune_info(rune: RuneData) -> void:
	# change the display name
	rune_name.text = selected_rune.name.replace(" ", "\n") # next word = new line
	
	for cost in cost_list.get_children():
		cost.queue_free() # refresh
	for mtrial in rune.cost:
		var entry = COST_ENTRY.instantiate()
		cost_list.add_child(entry)
		entry.setup(mtrial.icon, rune.cost[mtrial]) # rune.cost[material] is the amount from Dict
		
	update_sliders()
	
func update_sliders() -> void:
	# craft slider
	var most_craftable = GameData.max_craftable_rune(selected_rune)
	#if GameData.runes.has(selected_rune):
		#var r_remainder = GameData.RUNE_MAX_AMOUNT - GameData.runes[selected_rune]
		#if most_craftable > r_remainder:
			#most_craftable = r_remainder # so the rune will never exceed 100
	craft_slider.max_value = most_craftable
	craft_slider.editable = most_craftable > 0
	craft_slider.scrollable = most_craftable > 0
	craftable_amount.text = str(int(craft_slider.value)) # default
	
	# sell slider
	var most_sellable = GameData.max_sellable_rune(selected_rune)
	# try to find the maximum rune we can sell, so the materials won't exceed the maximum
	#if GameData.runes.has(selected_rune):
		#var m_remainder = 200
		#for mtrial in selected_rune.cost:
			#if not GameData.materials.has(mtrial):
				#break
			#var sum: int = 0
			#while (GameData.materials[mtrial] + selected_rune.cost[mtrial]) < GameData.MATERIAL_MAX_AMOUNT:
				#sum += 1
			#if m_remainder > sum:
				#m_remainder = sum
		#if most_sellable > m_remainder:
			#most_sellable = m_remainder
	
	sell_slider.max_value = most_sellable
	sell_slider.editable = most_sellable > 0
	sell_slider.scrollable = most_sellable > 0
	sellable_amount.text = str(int(sell_slider.value)) # default
	
func _on_craft_slider_changed(slider_value: float) -> void:
	craftable_amount.text = str(int(slider_value))
	
func _on_sell_slider_changed(slider_value: float) -> void:
	sellable_amount.text = str(int(slider_value))

func _on_craft_button_pressed() -> void:
	var selected_amount = craft_slider.value
	if selected_amount <= 0: # cannot be 0
		# signal: error message pop up
		SignalManager.on_error_message.emit(craft_zero_item_message)
		return
	# cannot exceed the max, 100
	if GameData.runes.has(selected_rune):
		if GameData.runes[selected_rune] >= GameData.RUNE_MAX_AMOUNT:
			return
		
	# subtract the rune's cost material
	for material in selected_rune.cost:
		GameData.subtract_material(material, selected_rune.cost[material] * selected_amount)
	# add the rune to bag
	GameData.add_rune(selected_rune, selected_amount)
	
	SignalManager.on_items_changed.emit()

func _on_sell_button_pressed() -> void:
	var selected_amount = sell_slider.value
	if selected_amount <= 0: # cannot be 0
		# signal: error message pop up
		SignalManager.on_error_message.emit(sell_zero_item_message)
		return
	
	# subtract the rune
	GameData.subtract_rune(selected_rune, selected_amount)
	# add the rune's cost material
	for material in selected_rune.cost:
		GameData.add_material(material, selected_rune.cost[material] * selected_amount)
	
	SignalManager.on_items_changed.emit()
