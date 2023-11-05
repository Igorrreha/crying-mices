class_name Checkpoint
extends Area2D


@export var _is_active: bool

static var _active_checkpoint: Checkpoint:
	set(v):
		for instance in _instances:
			if instance != v:
				instance.deactivate()
		
		if v == null:
			_instances[0].activate()
		else:
			_active_checkpoint = v

static var _instances: Array[Checkpoint]


static func get_active_checkpoint() -> Checkpoint:
	return _active_checkpoint


func activate() -> void:
	if _is_active:
		return
	
	_is_active = true
	_active_checkpoint = self


func deactivate() -> void:
	_is_active = false
	if _active_checkpoint == self:
		_active_checkpoint = null


func _ready():
	_instances.append(self)
	
	if _is_active:
		activate()
	
	body_entered.connect(activate.unbind(1))


func _exit_tree():
	_instances.erase(self)
	body_entered.disconnect(activate.unbind(1))
