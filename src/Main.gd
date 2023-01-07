extends Control

onready var game = $Game
onready var menu = $MainMenu
onready var hud = $MainMenu/Overlay

func _ready() -> void:
	game.visible = false

func _on_MainMenu_to_freeplay(board_size: int) -> void:
	game.visible = true
	menu.visible = false
	hud.visible = false
	game.set_challenge(false)
	game.reset_game(board_size)

func _on_MainMenu_to_daily_challenge() -> void:
	game.visible = true
	menu.visible = false
	hud.visible = false
	game.set_challenge(true)
	game.reset_game(4)

func _on_Game_back() -> void:
	game.visible = false
	menu.check_daily()
	menu.visible = true
	hud.visible = true

