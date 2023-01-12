extends Node

var last_day_check = 0
var today_challenge_completed = false

func _ready() -> void:
	print(get_daily_seed())

func check_day() -> void:
	if UserData.has_record(OS.get_datetime()["year"], OS.get_datetime()["month"], OS.get_datetime()["day"]):
		today_challenge_completed = true
	else:
		today_challenge_completed = (get_daily_seed() == last_day_check)

func get_daily_seed() -> int:
	var time = OS.get_datetime()
	var day = time["day"]
	var month = time["month"]
	var year = time["year"]
	var day_string = ""
	var month_string = ""
	if day < 10:
		day_string = "0" + str(day)
	else:
		day_string = str(day)
	if month < 10:
		month_string = "0" + str(month)
	else:
		month_string = str(month)
	var value = int(str(year)+month_string+day_string)
	return value

func on_challenge_completed(board_flat: Array, seconds: int, minutes: int, moves: int) -> void:
	print("today's challenge: ", board_flat)
	print("today's challenge completed in ",str(minutes), ":", str(seconds), " and ", str(moves, " moves"))
	last_day_check = get_daily_seed()
	today_challenge_completed = true
	UserData.score_gem_gain(seconds, minutes, moves)
	UserData.save_today(seconds, minutes, moves)
