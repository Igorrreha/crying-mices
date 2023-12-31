extends StaticBody2D


signal broked


@export var _hp: int = 1:
	set(v):
		if v <= 0 and _hp > 0:
			hide()
			_collision_shape.set_deferred("disabled", true)
			broked.emit()
		_hp = v
@export var _checkpoints_signals_channel: CheckpointsSignalsChannel
@export var _hero_signals_channel: HeroSignalsChannel

@onready var _area = $Area2D
@onready var _collision_shape = $CollisionShape2D
@onready var _start_health: int = _hp



func reload() -> void:
	show()
	_collision_shape.set_deferred("disabled", false)
	_hp = _start_health


func _ready() -> void:
	_area.area_entered.connect(_take_damage.unbind(1))
	_area.body_entered.connect(_take_damage.unbind(1))
	_checkpoints_signals_channel.checkpoint_activated.connect(reload)
	_hero_signals_channel.dead.connect(reload)


func _exit_tree() -> void:
	_area.area_entered.disconnect(_take_damage.unbind(1))
	_area.body_entered.disconnect(_take_damage.unbind(1))
	_checkpoints_signals_channel.checkpoint_activated.disconnect(reload)
	_hero_signals_channel.dead.disconnect(reload)


func _take_damage() -> void:
	_hp -= 1
