extends Node

# INVENTORY
var owned_tracks = [0]
var owned_pictures = [0, 1]
var streak_current = 0
var streak_max = 0
var streak_shields = 0
var solvers = 5
var gems = 0
var last_log_time = 0
# RECORDS
var current_year_loaded = 0
var current_month_loaded = 0
var current_loaded = {}
# STAGING
var staged_gems = 0

var tracks = [
	["A Cozy Day", preload("res://assets/audio/music/a-cozy-day-114852.mp3")],
	["Dreamy", preload("res://assets/audio/music/dreamy-114855.mp3")],
	["Feeling", preload("res://assets/audio/music/feeling-115471.mp3")],
	["Just Chill", preload("res://assets/audio/music/just-chill-114854.mp3")],
	["Night Coffee", preload("res://assets/audio/music/night-coffee-shop-114856.mp3")],
]
var pictures = [
	["Rabbit", preload("res://assets/gallery/zodiac/rabbit.jpg")],
	["Dragon", preload("res://assets/gallery/zodiac/dragon.jpg")],
	["Snake", preload("res://assets/gallery/zodiac/snake.jpg")],
	["Horse", preload("res://assets/gallery/zodiac/horse.jpg")],
	["Ram", preload("res://assets/gallery/zodiac/ram.jpg")],
	["Monkey", preload("res://assets/gallery/zodiac/monkey.jpg")],
	["Rooster", preload("res://assets/gallery/zodiac/rooster.jpg")],
	["Dog", preload("res://assets/gallery/zodiac/dog.jpg")],
	["Pig", preload("res://assets/gallery/zodiac/pig.jpg")],
	["Rat", preload("res://assets/gallery/zodiac/rat.jpg")],
	["Ox", preload("res://assets/gallery/zodiac/ox.jpg")],
	["Tiger", preload("res://assets/gallery/zodiac/tiger.jpg")],
]

func _ready() -> void:
	load_inventory()

func add_picture() -> void:
	owned_pictures.append(owned_pictures.size())
	save_inventory()

func add_music() -> void:
	owned_tracks.append(owned_tracks.size())
	save_inventory()

func score_gem_gain(seconds: int, minutes: int, moves: int) -> void:
# warning-ignore:integer_division
	var score_time = int(clamp((180 - (minutes * 60 + seconds))/10, 1, 18))
# warning-ignore:integer_division
	var score_move = int(clamp((100 - moves)/10, 1, 18))
	staged_gems = score_time + score_move

func check_expired() -> void:
	var log_time = OS.get_unix_time()
	if last_log_time == 0:
		streak_current = 0
		print("no log saved")
	elif log_time - last_log_time > 86400:
		print("streak broken")
		if streak_shields > 0:
			streak_shields -= 1
		else:
			streak_current = 0
	save_inventory()

func change_records_loaded(new_year: int, new_month: int) -> void:
	if len(current_loaded) > 0:
		save_to_records(current_year_loaded, current_month_loaded)
	current_year_loaded = new_year
	current_month_loaded = new_month
	load_from_records(current_year_loaded, current_month_loaded)

func save_today(seconds: int, minutes: int, moves: int) -> void:
	var log_time = OS.get_unix_time()
	print("seconds since last record log: ", log_time - last_log_time)
	streak_current += 1
	if streak_current > streak_max:
		streak_max = streak_current
	last_log_time = log_time
	save_inventory()
	change_records_loaded(OS.get_datetime()["year"], OS.get_datetime()["month"])
	var day = OS.get_datetime()["day"]
	if current_loaded.has(day):
		push_error("a record was already saved for this day; overwriting")
	current_loaded[day] = {
		"moves": moves,
		"minutes": minutes,
		"seconds": seconds
	}
	change_records_loaded(OS.get_datetime()["year"], OS.get_datetime()["month"])

func save_inventory() -> void:
	var save = File.new()
	var dir = Directory.new()
	dir.open("user://")
	if not dir.dir_exists("user://records/"):
		dir.make_dir("user://records/")
	save.open("user://records/inventory.save", File.WRITE)
	var inv_dict = {
		"owned_tracks": owned_tracks,
		"owned_pictures": owned_pictures,
		"streak_current": streak_current,
		"streak_max": streak_max,
		"streak_shields": streak_shields,
		"solvers": solvers,
		"gems": gems,
		"staged_gems": staged_gems,
		"last_log_time": last_log_time,
	}
	save.store_line(to_json(inv_dict))
	save.close()

func load_inventory() -> void:
	print("attempting to load iventory")
	var save_dir = "user://records/inventory.save"
	var save = File.new()
	if not save.file_exists(save_dir):
		print("no inventory save found")
		return
	save.open(save_dir, File.READ)
	var invd = parse_json(save.get_line())
	print(invd)
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
		if invd.has("solvers"):
			solvers = int(invd.solvers)
		if invd.has("staged_gems"):
			gems = int(invd.staged_gems)
		if invd.has("gems"):
			gems = int(invd.gems)
		if invd.has("last_log_time"):
			last_log_time = int(invd.last_log_time)
	save.close()

func save_to_records(year: int, month: int) -> void:
	#print("attempting to save records from year ", year, " month ", month)
	var dir = Directory.new()
	if not dir.dir_exists("user://records/"):
		dir.make_dir("user://records/")
	if not dir.dir_exists("user://records/" + str(year) + "/"):
		dir.make_dir("user://records/" + str(year) + "/")
	if not dir.dir_exists("user://records/" + str(year) + "/" + str(month) + "/"):
		dir.make_dir("user://records/" + str(year) + "/" + str(month) + "/")
	var d = "user://records/" + str(year) + "/" + str(month) + "/records.save"
	var records = File.new()
	records.open(d, File.WRITE)
	var records_dict = current_loaded.duplicate(true)
	records.store_line(to_json(records_dict))
	records.close()

func load_from_records(year: int, month: int) -> void:
	#print("attemting to load records from year: ", year, " month ", month)
	var d = "user://records/" + str(year) + "/" + str(month) + "/records.save"
	var records = File.new()
	if not records.file_exists(d):
		print("no records file found for year ", year, " month ", month)
		current_loaded = {}
		return
	records.open(d, File.READ)
	var sd = parse_json(records.get_line())
	if sd:
		current_loaded = sd.duplicate(true)
	else:
		current_loaded = {}
	records.close()

func has_record(year: int, month: int, day: int) -> bool:
	change_records_loaded(year, month)
	return str(day) in current_loaded
