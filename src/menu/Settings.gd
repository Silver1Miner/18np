extends Control

onready var time_toggle = $Panel/TrainSettings/Time/HideTime
onready var move_toggle = $Panel/TrainSettings/Move/HideMove
onready var about_toggle = $Panel/AboutButton
onready var about_panel = $Panel/AboutPanel
onready var privacy_panel = $Panel/AboutPanel/PrivacyPanel
onready var privacy_button = $Panel/AboutPanel/PrivacyView
onready var copyright = $Panel/AboutPanel/Copyright
var ready = false

func _ready() -> void:
	time_toggle.pressed = UserSettings.hide_times
	move_toggle.pressed = UserSettings.hide_moves
	ready = true
	copyright.text = "v1.0.6 -- January 25, 2023\nCopyright © 2023 Jack Anderson"

func _on_HideTime_toggled(button_pressed: bool) -> void:
	if ready:
		Audio.play_sound("res://assets/audio/sounds/switch_004.ogg")
	UserSettings.hide_times = button_pressed

func _on_HideMove_toggled(button_pressed: bool) -> void:
	if ready:
		Audio.play_sound("res://assets/audio/sounds/switch_004.ogg")
	UserSettings.hide_moves = button_pressed

func _on_AboutButton_toggled(button_pressed: bool) -> void:
	privacy_panel.visible = false
	privacy_button.pressed = false
	about_panel.visible = button_pressed

func _on_PrivacyView_toggled(button_pressed: bool) -> void:
	privacy_panel.visible = button_pressed

func _on_PrivacyView_pressed() -> void:
	if OS.shell_open(UserSettings.privacy_policy_link) != OK:
		push_error("fail to open link")
