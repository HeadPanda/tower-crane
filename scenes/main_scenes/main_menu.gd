extends Node2D

var start := false
#@export var level_scene: String = "res://scenes/main_scenes/level.tscn"
@export var level_scene: PackedScene = preload("res://scenes/main_scenes/level.tscn")


#func _ready() -> void:
	#ResourceLoader.load_threaded_request(level_scene)
#
#func _process(_delta: float) -> void:
	#var progress = []
	#ResourceLoader.load_threaded_get_status(level_scene, progress)
	#
	#if start and progress[0] == 1:
		#var scene = ResourceLoader.load_threaded_get(level_scene)
		#get_tree().change_scene_to_packed(scene)
		#EscapeMenu.is_enabled = true
	

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(level_scene)
	start = true
	EscapeMenu.is_enabled = true
