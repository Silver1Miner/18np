extends Control

onready var time_toggle = $Panel/TrainSettings/Time/HideTime
onready var move_toggle = $Panel/TrainSettings/Move/HideMove

func _ready() -> void:
	time_toggle.pressed = UserSettings.hide_times
	move_toggle.pressed = UserSettings.hide_moves

func _on_HideTime_toggled(button_pressed: bool) -> void:
	UserSettings.hide_times = button_pressed

func _on_HideMove_toggled(button_pressed: bool) -> void:
	UserSettings.hide_moves = button_pressed
