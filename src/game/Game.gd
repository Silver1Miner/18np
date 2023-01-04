extends Control

signal back()
onready var timer = $Timer
onready var board = $GameView/BoardView/Board
onready var clock_display = $GameView/Top/Display/Status/Clock/Value
onready var moves_display = $GameView/Top/Display/Status/Moves/Value
var freeplay = true
var seconds = 0
var minutes = 0
var moves = 0

func _ready() -> void:
	timer.stop()

func reset_game(size: int) -> void:
	board.update_size(size)

func _on_Board_game_started() -> void:
	timer.start(1)
	seconds = 0
	minutes = 0
	moves = 0

func _on_Board_game_won() -> void:
	timer.stop()
	print("win game detected")

func _on_Board_moves_updated(move_count: int) -> void:
	moves = move_count
	moves_display.text = str(moves)

func _on_Timer_timeout() -> void:
	seconds += 1
	if seconds < 0:
		seconds = 1
	elif seconds >= 60:
		minutes += 1
		seconds = 0
	var minute_display = ""
	if minutes < 10:
		minute_display = "0" + str(minutes)
	else:
		minute_display = str(minutes)
	var second_display = ""
	if seconds < 10:
		second_display = "0" + str(int(seconds))
	else:
		second_display = str(int(seconds))
	clock_display.text = minute_display + ":" + second_display


func _on_Back_pressed() -> void:
	timer.stop()
	seconds = 0
	minutes = 0 
	moves = 0
	clock_display.text = "00:00"
	moves_display.text = "0"
	emit_signal("back")
