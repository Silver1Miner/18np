extends Control

signal to_freeplay(board_size)
signal to_daily_challenge()
onready var tween = $Tween
onready var panes = $Panes
onready var settings_button = $Overlay/Panel/SettingsButton
onready var settings_menu = $Overlay/Panel/Settings

func _ready() -> void:
	panes.rect_position.x = 2 * -360

func _on_SelectBar_selected(current_select) -> void:
	if settings_button:
		settings_button.pressed = false
	if tween:
		tween.interpolate_property(self, "rect_position:x",
		rect_position.x, (current_select - 2) * -360, 0.3,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		tween.start()

func _on_SizeSelect_size_selected(size) -> void:
	emit_signal("to_freeplay", size)

func _on_PlayDaily_pressed() -> void:
	emit_signal("to_daily_challenge")

func _on_SettingsButton_toggled(button_pressed: bool) -> void:
	UserSettings.save_settings()
	settings_menu.visible = button_pressed
