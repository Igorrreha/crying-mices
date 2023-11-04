extends Area2D


@export var _focus_point: CameraFocusPoint
@export var _one_shot: bool

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_entered.connect(_activate_focus_point.unbind(1))
	body_entered.connect(_activate_focus_point.unbind(1))


func _exit_tree() -> void:
	area_entered.disconnect(_activate_focus_point)
	body_entered.disconnect(_activate_focus_point)


func _activate_focus_point() -> void:
	_focus_point.activate()
	print("as")
	if _one_shot:
		_collision_shape.set_deferred("disabled", true)
