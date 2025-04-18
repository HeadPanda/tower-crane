extends Node2D

@export var level_scene: PackedScene = preload("res://scenes/main_scenes/level.tscn")


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(level_scene)
	EscapeMenu.is_enabled = true
