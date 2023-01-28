extends Node

const shield_price = 200
const solve_price = 20
var picture_price = 160
var track_price = 160
const max_shields = 5
const max_solvers = 99
const max_tracks = 5
const max_pictures = 24
const pic_per_page = 12
const pages = ["Animals", "Landscapes", "Animals 2"]
# INVENTORY
var owned_tracks = 1
var owned_pictures = 4
var streak_current = 0
var streak_max = 0
var streak_shields = 0
var solvers = 5
var gems = 0
var last_log_time = 0
var last_check_time = 0
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
	# Animals
	["Rat", preload("res://assets/gallery/zodiac/rat.jpg")],
	["Ox", preload("res://assets/gallery/zodiac/ox.jpg")],
	["Tiger", preload("res://assets/gallery/zodiac/tiger.jpg")],
	["Rabbit", preload("res://assets/gallery/zodiac/rabbit.jpg")],
	["Dragon", preload("res://assets/gallery/zodiac/dragon.jpg")],
	["Snake", preload("res://assets/gallery/zodiac/snake.jpg")],
	["Horse", preload("res://assets/gallery/zodiac/horse.jpg")],
	["Ram", preload("res://assets/gallery/zodiac/ram.jpg")],
	["Monkey", preload("res://assets/gallery/zodiac/monkey.jpg")],
	["Rooster", preload("res://assets/gallery/zodiac/rooster.jpg")],
	["Dog", preload("res://assets/gallery/zodiac/dog.jpg")],
	["Pig", preload("res://assets/gallery/zodiac/pig.jpg")],
	# Landscapes
	["Antelope", preload("res://assets/gallery/landscape/antelope.jpg")],
	["Bridge", preload("res://assets/gallery/landscape/bridge.jpg")],
	["El Capitan", preload("res://assets/gallery/landscape/elcapitan.jpg")],
	["Moon", preload("res://assets/gallery/landscape/moon.jpg")],
	["Moraine", preload("res://assets/gallery/landscape/moraine.jpg")],
	["Oahu", preload("res://assets/gallery/landscape/oahu.jpg")],
	["Antelope2", preload("res://assets/gallery/landscape/antelope2.jpg")],
	["Peak", preload("res://assets/gallery/landscape/peaks.jpg")],
	["River", preload("res://assets/gallery/landscape/river.jpg")],
	["Tomatlan", preload("res://assets/gallery/landscape/tomatlan.jpg")],
	["Tree", preload("res://assets/gallery/landscape/tree.jpg")],
	["Vestrahorn", preload("res://assets/gallery/landscape/vestrahorn.jpg")],
	# Animals 2
	["Rat2", preload("res://assets/gallery/zodiac/rat.jpg")],
	["Ox2", preload("res://assets/gallery/zodiac/ox.jpg")],
	["Tiger2", preload("res://assets/gallery/zodiac/tiger.jpg")],
	["Rabbit2", preload("res://assets/gallery/zodiac/rabbit.jpg")],
	["Dragon2", preload("res://assets/gallery/zodiac/dragon.jpg")],
	["Snake2", preload("res://assets/gallery/zodiac/snake.jpg")],
	["Horse2", preload("res://assets/gallery/zodiac/horse.jpg")],
	["Ram2", preload("res://assets/gallery/zodiac/ram.jpg")],
	["Monkey2", preload("res://assets/gallery/zodiac/monkey.jpg")],
	["Rooster2", preload("res://assets/gallery/zodiac/rooster.jpg")],
	["Dog2", preload("res://assets/gallery/zodiac/dog.jpg")],
	["Pig2", preload("res://assets/gallery/zodiac/pig.jpg")],
]

func _ready() -> void:
	load_inventory()
	update_prices()

func add_picture() -> void:
	owned_pictures += 1
	update_prices()
	save_inventory()

func add_music() -> void:
	owned_tracks += 1
	update_prices()
	save_inventory()

func update_prices() -> void:
	UserData.picture_price = int(clamp(UserData.owned_pictures * 10, 0, 160))
	UserData.track_price = int(clamp(UserData.owned_tracks * 100, 0, 160))

func score_gem_gain(seconds: int, minutes: int, moves: int) -> void:
	var score_time = int(clamp( round((180.0 - (minutes * 60 + seconds)) /10), 1, 20))
	var score_move = int(clamp( round((100.0 - moves) /10), 1, 20))
	staged_gems = (score_time + score_move)

func check_expired() -> bool:
	print(OS.get_date())
	var log_time = OS.get_unix_time_from_datetime(OS.get_date())
	if log_time == last_check_time:
		return false
	var streak_broken = false
	print(log_time)
	if log_time - last_log_time > 86441:
		print("streak broken")
		streak_broken = true
		if streak_shields > 0:
			streak_shields -= 1
		else:
			streak_current = 0
	last_check_time = log_time
	save_inventory()
	return streak_broken

func change_records_loaded(new_year: int, new_month: int) -> void:
	if len(current_loaded) > 0:
		save_to_records(current_year_loaded, current_month_loaded)
	current_year_loaded = new_year
	current_month_loaded = new_month
	load_from_records(current_year_loaded, current_month_loaded)

func save_today(seconds: int, minutes: int, moves: int) -> void:
	var log_time = OS.get_unix_time_from_datetime(OS.get_date())
	streak_current += 1
	if streak_current > streak_max:
		streak_max = streak_current
	last_log_time = log_time
	save_inventory()
	change_records_loaded(OS.get_date()["year"], OS.get_date()["month"])
	var day = OS.get_date()["day"]
	if current_loaded.has(day):
		push_error("a record was already saved for this day; overwriting")
	current_loaded[day] = {
		"moves": moves,
		"minutes": minutes,
		"seconds": seconds
	}
	change_records_loaded(OS.get_date()["year"], OS.get_date()["month"])

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
		"last_check_time": last_check_time,
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
			owned_tracks = int(invd.owned_tracks)
		if invd.has("owned_pictures"):
			owned_pictures = int(invd.owned_pictures)
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
		if invd.has("last_check_time"):
			last_check_time = int(invd.last_check_time)
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
