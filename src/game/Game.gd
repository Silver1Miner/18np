extends Control

signal back()
signal challenge_completed(board_flat, seconds, minutes, moves)
onready var title = $Complete/Display/Title
onready var timer = $Timer
onready var instructions = $GameView/BoardView/Instructions
onready var board = $GameView/BoardView/Board
onready var clock_tab = $GameView/Top/Display/Status/Panel#/Clock
onready var moves_tab = $GameView/Top/Display/Status/Panel2#/Moves
onready var clock_display = $GameView/Top/Display/Status/Panel/Clock/Value
onready var moves_display = $GameView/Top/Display/Status/Panel2/Moves/Value
onready var anim = $AnimationPlayer
onready var quit_menu = $Quit
onready var win_clock_display = $Complete/Display/Status/Clock/Value
onready var win_moves_display = $Complete/Display/Status/Moves/Value
onready var win_picture = $Complete/Display/Picture
onready var win_replay = $Complete/Controls/Replay
onready var win_home = $Complete/Controls/Home
onready var solver_panel = $GameView/Panel/SolverPanel
onready var solver_button = $GameView/Panel/SolverPanel/Cheat
onready var solver_label = $GameView/Panel/SolverPanel/Solvers
onready var gems_label = $Complete/Display/GemGain
onready var gems_value = $Complete/Display/GemsWon
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
		solver_panel.visible = false
		gems_label.text = "\nDaily Challenge Gem Reward:"
		gems_value.text = "0"
	else:
		clock_tab.visible = !UserSettings.hide_times
		moves_tab.visible = !UserSettings.hide_moves
		solver_panel.visible = true
		solver_label.text = "Solvers: " + str(UserData.solvers)
		gems_label.text = ""
		gems_value.text = ""
	board.update_background_texture(UserData.pictures[UserSettings.picture_index][1])
	title.text = UserData.pictures[UserSettings.picture_index][0]
	seconds = 0
	minutes = 0
	moves = 0
	clock_display.text = "00:00"
	moves_display.text = "0"
	solver_button.disabled = true
	instructions.visible = true

func reset_game(size: int) -> void:
	board.update_size(size)

func _on_Board_game_started() -> void:
	timer.paused = false
	instructions.visible = false
	if solver_panel.visible:
		solver_label.text = "Solvers: " + str(UserData.solvers)
		solver_button.disabled = UserData.solvers <= 0
	timer.start(1)
	seconds = 0
	minutes = 0
	moves = 0

func _on_Board_game_won() -> void:
	timer.stop()
	Audio.play_sound("res://assets/audio/sounds/confirmation_004.ogg")
	solver_button.disabled = true
	win_picture.texture = board.background_texture 
	win_clock_display.text = clock_display.text
	win_moves_display.text = moves_display.text
	win_replay.visible = !challenge
	print("win game detected")
	anim.play("Complete")
	if challenge:
		emit_signal("challenge_completed", board.board_flat, seconds, minutes, moves)
		gems_value.text = str(UserData.staged_gems)
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
	pass

func _on_Back_button_up() -> void:
	Audio.play_sound("res://assets/audio/sounds/back_002.ogg")
	if seconds > 0:
		timer.paused = true
		quit_menu.visible = true
	else:
		emit_signal("back")

func _on_Home_pressed() -> void:
	Audio.play_sound("res://assets/audio/sounds/back_002.ogg")
	emit_signal("back")

func _on_Replay_pressed() -> void:
	_on_Restart_pressed()
	anim.play_backwards("Complete")

func _on_Restart_pressed() -> void:
	timer.stop()
	Audio.play_sound("res://assets/audio/sounds/confirmation_001.ogg")
	board.reset_board()
	seconds = 0
	minutes = 0 
	moves = 0
	clock_display.text = "00:00"
	moves_display.text = "0"
	instructions.visible = true
	solver_button.disabled = true

func _on_Cheat_pressed() -> void:
	board.auto_win()
	if UserData.solvers > 0:
		UserData.solvers -= 1
		solver_label.text = "Solvers: " + str(UserData.solvers)

func _on_Cancel_pressed() -> void:
	Audio.play_sound("res://assets/audio/sounds/back_002.ogg")
	quit_menu.visible = false
	timer.paused = false

func _on_Quit_pressed() -> void:
	Audio.play_sound("res://assets/audio/sounds/back_002.ogg")
	quit_menu.visible = false
	timer.stop()
	seconds = 0
	minutes = 0 
	moves = 0
	clock_display.text = "00:00"
	moves_display.text = "0"
	if solver_panel.visible:
		solver_button.disabled = true
	emit_signal("back")


