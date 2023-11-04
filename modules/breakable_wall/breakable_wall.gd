extends StaticBody2D


@export var _hp: int = 1

@onready var _area = $Area2D


func _ready() -> void:
	_area.area_entered.connect(_take_damage.unbind(1))
	_area.body_entered.connect(_take_damage.unbind(1))


func _take_damage() -> void:
	_hp -= 1
	if _hp <= 0:
		queue_free()
