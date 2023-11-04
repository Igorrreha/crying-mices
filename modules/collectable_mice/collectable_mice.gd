class_name CollectableMice
extends Area2D


static var spawned_count: int

@export var _signals_channel: CollectableMicesSignalsChannel


func _ready() -> void:
	body_entered.connect(_collect.unbind(1))
	spawned_count += 1


func _collect() -> void:
	_signals_channel.mice_collected.emit()
	queue_free()
