extends Node

# INVENTORY
var owned_tracks = [0]
var owned_pictures = [0, 1]
var streak_current = 0
var streak_max = 0
var streak_shields = 0
var gems = 0
var last_log_time = 0
# RECORDS
var current_year_loaded = 0
var current_month_loaded = 0
var current_loaded = {}

var tracks = [
	["A Cozy Day", preload("res://assets/audio/music/a-cozy-day-114852.mp3")]
]
var pictures = [
	["Kingfisher", preload("res://assets/gallery/0/kingfisher.jpg")],
	["Toucan", preload("res://assets/gallery/0/toucan.jpg")],
]

func change_records_loaded(new_year: int, new_month: int) -> void:
	save_to_records(current_year_loaded, current_month_loaded)
	current_year_loaded = new_year
	current_month_loaded = new_month
	load_from_records(current_year_loaded, current_month_loaded)

func save_daily_record(day: int, moves: int, minutes: int, seconds: int) -> void:
	var log_time = OS.get_unix_time()
	if last_log_time == 0:
		streak_current = 1
	elif log_time - last_log_time > 86400: # seconds in days
		if streak_shields > 0:
			streak_shields -= 1
		else:
			streak_current = 0
	else:
		streak_current += 1
	if streak_current > streak_max:
		streak_max = streak_current
	save_inventory()
	change_records_loaded(OS.get_datetime()["year"], OS.get_datetime()["month"])
	if current_loaded.has(day):
		push_error("a record was already saved for this day; overwriting")
	current_loaded[day] = {
		"moves": moves,
		"minutes": minutes,
		"seconds": seconds
	}
	save_to_records(OS.get_datetime()["year"], OS.get_datetime()["month"])
	last_log_time = log_time

func save_inventory() -> void:
	var save = File.new()
	save.open("user://records/inventory.save", File.WRITE)
	var inv_dict = {
		"owned_tracks": owned_tracks,
		"owned_pictures": owned_pictures,
		"streak_current": streak_current,
		"streak_max": streak_max,
		"streak_shields": streak_shields,
		"gems": gems,
		"last_log_time": last_log_time,
	}
	save.store_line(to_json(inv_dict))
	save.close()

func load_inventory() -> void:
	var save_dir = "user://records/inventory.save"
	var save = File.new()
	if not save.file_exists(save_dir):
		print("no inventory save found")
		return
	save.open(save_dir, File.READ)
	var invd = parse_json(save.get_line())
	if typeof(invd) == TYPE_DICTIONARY:
		if invd.has("owned_tracks"):
			owned_tracks = invd.owned_tracks.duplicate(true)
		if invd.has("owned_pictures"):
			owned_pictures = invd.owned_pictures.duplicate(true)
		if invd.has("streak_current"):
			streak_current = int(invd.streak_current)
		if invd.has("streak_max"):
			streak_max = int(invd.streak_max)
		if invd.has("streak_shields"):
			streak_shields = int(invd.streak_shields)
		if invd.has("gems"):
			gems = int(invd.gems)
		if invd.has("last_log_time"):
			last_log_time = int(last_log_time)
	save.close()

func save_to_records(year: int, month: int) -> void:
	print("attempting to save records from year ", year, " month ", month)
	var dir = "user://records/" + str(year) + "/" + str(month) + "/records.save"
	var records = File.new()
	records.open(dir, File.WRITE)
	var records_dict = current_loaded.duplicate(true)
	print(records_dict)
	records.store_line(to_json(records_dict))
	records.close()

func load_from_records(year: int, month: int) -> void:
	print("attemting to load records from year: ", year, " month ", month)
	var dir = "user://records/" + str(year) + "/" + str(month) + "/records.save"
	var records = File.new()
	if not records.file_exists(dir):
		print("no records file found for year ", year, " month ", month)
		return
	records.open(dir, File.READ)
	var sd = parse_json(records.get_line())
	current_loaded = sd.duplicate(true)
	records.close()
