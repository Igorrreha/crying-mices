extends HBoxContainer


@export var _mices_signals_channel: CollectableMicesSignalsChannel

var _collected_count: int

@onready var _label = $Label
@onready var _max_count = CollectableMice.spawned_count


func _ready() -> void:
	_mices_signals_channel.mice_collected.connect(_count)
	_update_text()


func _count() -> void:
	_collected_count += 1
	_update_text()


func _update_text() -> void:
	_label.text = "%s / %s" % [_collected_count, _max_count]
