extends Node


@export var _hero: Hero


func _ready() -> void:
	_hero.dead.connect(_on_hero_dead)


func _exit_tree() -> void:
	_hero.dead.disconnect(_on_hero_dead)


func _on_hero_dead() -> void:
	var active_checkpoint = Checkpoint.get_active_checkpoint()
	_hero.global_position = active_checkpoint.global_position
	_hero.become_immovable()
