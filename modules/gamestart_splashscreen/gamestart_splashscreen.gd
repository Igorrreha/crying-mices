extends Control


signal showing_completed


func complete_showing() -> void:
	showing_completed.emit()
