extends Control

signal back()
signal challenge_completed(board_flat, seconds, minutes, moves)
onready var title = $Complete/Display/Title
onready var timer = $Timer
onready var instructions = $GameView/BoardView/Instructions
onready var board = $GameView/BoardView/Board
onready var clock_tab = $GameView/Top/Display/Status/Clock
onready var moves_tab = $GameView/Top/Display/Status/Moves
onready var clock_display = $GameView/Top/Display/Status/Clock/Value
onready var moves_display = $GameView/Top/Display/Status/Moves/Value
onready var anim = $AnimationPlayer
onready var quit_menu = $Quit
onready var win_clock_display = $Complete/Display/Status/Clock/Value
onready var win_moves_display = $Complete/Display/Status/Moves/Value
onready var win_picture = $Complete/Display/Picture
onready var win_replay = $Complete/Controls/Replay
onready var win_home = $Complete/Controls/Home
var challenge = false
var current_seed = 1
var seconds = 0
var minutes = 0
var moves = 0

func _ready() -> void:
	timer.stop()
	quit_menu.visible = false
	if connect("challenge_completed", Daily, "on_challenge_completed") != OK:
		push_error("fail to connect challenge completion signal")

func set_challenge(value: bool) -> void:
	anim.play("RESET")
	challenge = value
	board.consistent = challenge
	board.seed_value = Daily.get_daily_seed()
	if challenge:
		clock_tab.visible = true
		moves_tab.visible = true
	else:
		clock_tab.visible = !UserSettings.hide_times
		moves_tab.visible = !UserSettings.hide_moves
	board.update_background_texture(UserData.pictures[UserSettings.picture_index][1])
	title.text = UserData.pictures[UserSettings.picture_index][0]
	seconds = 0
	minutes = 0 
	moves = 0
	clock_display.text = "00:00"
	moves_display.text = "0"
	instructions.visible = true

func reset_game(size: int) -> void:
	board.update_size(size)

func _on_Board_game_started() -> void:
	timer.paused = false
	instructions.visible = false
	timer.start(1)
	seconds = 0
	minutes = 0
	moves = 0

func _on_Board_game_won() -> void:
	timer.stop()
	win_picture.texture = board.background_texture 
	win_clock_display.text = clock_display.text
	win_moves_display.text = moves_display.text
	win_replay.visible = !challenge
	print("win game detected")
	anim.play("Complete")
	if challenge:
		emit_signal("challenge_completed", board.board_flat, seconds, minutes, moves)
	else:
		print("game won with starting position: ", board.board_flat)

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
	if seconds > 0:
		timer.paused = true
		quit_menu.visible = true
	else:
		emit_signal("back")

func _on_Home_pressed() -> void:
	emit_signal("back")

func _on_Replay_pressed() -> void:
	_on_Restart_pressed()
	anim.play_backwards("Complete")

func _on_Restart_pressed() -> void:
	timer.stop()
	board.reset_board()
	seconds = 0
	minutes = 0 
	moves = 0
	clock_display.text = "00:00"
	moves_display.text = "0"
	instructions.visible = true

func _on_Cheat_pressed() -> void:
	board.auto_win()

func _on_Cancel_pressed() -> void:
	quit_menu.visible = false
	timer.paused = false

func _on_Quit_pressed() -> void:
	quit_menu.visible = false
	timer.stop()
	seconds = 0
	minutes = 0 
	moves = 0
	clock_display.text = "00:00"
	moves_display.text = "0"
	emit_signal("back")
