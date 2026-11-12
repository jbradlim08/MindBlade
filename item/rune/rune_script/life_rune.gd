extends RuneData

class_name LifeRune

func activate() -> void:
	print(name)
	SignalManager.on_set_life_rune.emit()
