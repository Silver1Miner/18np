extends Node

var version = "v 1.0.0 "
var hide_times = false
var hide_moves = false
var mute_music = false
var mute_sound = false
var jukebox_index = 0
var picture_index = 0

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	print("attempting to save settings")
	var settings = File.new()
	settings.open("user://settings.save", File.WRITE)
	var settings_dict = {
		"hide_times": hide_times,
		"hide_moves": hide_moves,
		"mute_music": mute_music,
		"mute_sound": mute_sound,
		"jukebox_index": jukebox_index,
		"picture_index": picture_index,
	}
	print(settings_dict)
	settings.store_line(to_json(settings_dict))
	settings.close()

func load_settings() -> void:
	print("attemting to load settings")
	var settings = File.new()
	if not settings.file_exists("user://settings.save"):
		print("no settings file found")
		return
	settings.open("user://settings.save", File.READ)
	var sd = parse_json(settings.get_line())
	if sd != null:
		if sd.has("hide_times"):
			hide_times = bool(sd.hide_times)
		if sd.has("hide_moves"):
			hide_moves = bool(sd.hide_moves)
		if sd.has("mute_music"):
			mute_music = bool(sd.mute_music)
		if sd.has("mute_sound"):
			mute_sound = bool(sd.mute_sound)
		if sd.has("jukebox_index"):
			jukebox_index = int(sd.jukebox_index)
		if sd.has("picture_index"):
			picture_index = int(sd.picture_index)
	settings.close()
