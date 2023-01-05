extends Node

var last_day_check = 0
var today_challenge_completed = false

func _ready() -> void:
	print(get_daily_seed())

func check_day() -> void:
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

var csv = []
var headers = []
var csv_noheaders  = []
var some_header_idx = 0
func parse_csv(file_name: String):
	var file = File.new()
	file.open(file_name, file.READ)
	while !file.eof_reached():
		var csv_rows = file.get_csv_line(",") # deliminator
		csv.append(csv_rows)
	file.close()
	csv.pop_back() #remove last empty array get_csv_line() has created 
	headers = Array(csv[0])
	some_header_idx = headers.find("some_header_name")
	csv_noheaders = csv
	csv_noheaders.pop_front() #remove first array (headers) from the csv
