class_name Checkpoint
extends Area2D


@export var is_active: bool
@export var _signals_channel: CheckpointsSignalsChannel

static var _active_checkpoint: Checkpoint:
	set(v):
		for instance in _instances:
			if instance != v and instance.is_active:
				instance.deactivate()
		
		if v == null:
			_instances[0].activate()
		else:
			_active_checkpoint = v

static var _instances: Array[Checkpoint]


static func get_active_checkpoint() -> Checkpoint:
	return _active_checkpoint


func activate() -> void:
	if is_active:
		return
	
	is_active = true
	_active_checkpoint = self
	_signals_channel.checkpoint_activated.emit()


func deactivate() -> void:
	is_active = false
	if _active_checkpoint == self:
		_active_checkpoint = null


func _ready():
	_instances.append(self)
	
	if is_active:
		activate()
	
	body_entered.connect(activate.unbind(1))


func _exit_tree():
	_instances.erase(self)
	body_entered.disconnect(activate.unbind(1))
