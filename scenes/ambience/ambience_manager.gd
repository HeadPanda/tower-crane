extends Node2D

signal time_tick(time: float)
signal day
signal night

enum Time_States {
	DAY,
	NIGHT
}

@export_group("Day Night Cycle")
@export var day_night_gradient: Gradient
@export var day_length_minutes := 0.5
@export var day_start := 0.2
@export var day_end := 0.75

var current_time_state: Time_States
var time := 0.0 # 0-1, where 0.0 = midnight, 0.5 = noon, 1.0 = next midnight
var current_track: AudioStreamPlayer = null:
	set(value):
		if value is AudioStreamPlayer:
			if current_track is AudioStreamPlayer:
				current_track.volume_db = current_track_base_vol
			current_track = value
			current_track_base_vol = value.volume_db
			print("track: ", current_track, current_track_base_vol)
var current_track_base_vol: float = 0.0

@onready var day_modulator: CanvasModulate = $CanvasModulate
@onready var ambient_tracks_day: Array[Node] = $AmbientTracksDay.get_children()
@onready var ambient_tracks_night: Array[Node] = $AmbientTracksNight.get_children()


func _process(delta: float) -> void:
	var day_speed = delta / (day_length_minutes * 60.0)
	time = fmod(time + day_speed, 1.0)
	
	time_tick.emit(time)
	
	if time >= 0.2 and time <= 0.75:
		if current_time_state != Time_States.DAY:
			current_time_state = Time_States.DAY
			day.emit()
	elif current_time_state != Time_States.NIGHT:
		current_time_state = Time_States.NIGHT
		night.emit()
	
	update_daylight()


func update_daylight() -> void:
	var light_color = day_night_gradient.sample(time)
	day_modulator.color = light_color


func play_ambience() -> void:
	var is_day = current_time_state == Time_States.DAY
	var track_list: Array[Node] = ambient_tracks_day if is_day else ambient_tracks_night
	
	if track_list.size() > 0:
		var new_track = track_list.pick_random()
		current_track = new_track
		fade_in_audio(current_track, -80.0, current_track_base_vol, 5.0)


func fade_in_audio(audio_player: AudioStreamPlayer, start_vol: float = -5.0, end_vol: float = 0, time: float = 5.0) -> void:
	var tween = get_tree().create_tween()
	audio_player.volume_db = start_vol
	audio_player.play()
	tween.tween_property(audio_player, "volume_db", end_vol, time)


func fade_out_audio(audio_player: AudioStreamPlayer, end_vol: float = -50.0, time: float = 5.0, callback = null) -> void:
	if audio_player is AudioStreamPlayer and audio_player.playing:
		var tween = get_tree().create_tween()
		tween.tween_property(audio_player, "volume_db", end_vol, time)
		tween.tween_callback(audio_player.stop)
		if callback != null and callback is Callable:
			tween.tween_callback(callback)
	elif callback is Callable:
		callback.call()


func _on_day() -> void:
	fade_out_audio(current_track, -80.0, 5.0, play_ambience)


func _on_night() -> void:
	fade_out_audio(current_track, -80.0, 5.0, play_ambience)
