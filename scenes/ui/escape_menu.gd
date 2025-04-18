extends CanvasLayer

@export var is_enabled := false


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and is_enabled:
		if visible or get_tree().paused == true:
			unpause()
		else:
			pause()


func pause() -> void:
	get_tree().paused = true
	visible = true


func unpause() -> void:
	get_tree().paused = false
	visible = false

func _on_restart_button_pressed() -> void:
	await get_tree().reload_current_scene()
	unpause()
