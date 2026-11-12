extends RuneData

class_name CheckpointRune


func activate() -> void:
	print(name)
	SignalManager.on_set_checkpoint_rune.emit(self)
