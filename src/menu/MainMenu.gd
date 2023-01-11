extends Control

signal to_freeplay(board_size)
signal to_daily_challenge()
onready var tween = $Tween
onready var panes = $Panes
onready var settings_button = $Overlay/Panel/SettingsButton
onready var settings_menu = $Overlay/Panel/Settings
onready var play_daily_button = $Panes/Daily/PlayDaily
onready var completed_message = $Panes/Daily/Completed
onready var background_preview = $Panes/Daily/Preview
onready var background_title = $Panes/Daily/PreviewTitle
onready var store = $Panes/Store
onready var streak_label = $Overlay/Panel/Status/Streak/Label
onready var gems_label = $Overlay/Panel/Status/Gems/Label

func _ready() -> void:
	check_daily()
	_on_Gallery_image_changed()
	panes.rect_position.x = 2 * -360

func check_daily() -> void:
	Daily.check_day()
	if Daily.today_challenge_completed:
		play_daily_button.disabled = true
		play_daily_button.text = "Completed!"
		completed_message.visible = true
	else:
		play_daily_button.disabled = false
		play_daily_button.text = "Play!"
		completed_message.visible = false
	if UserData.staged_gems > 0:
		print("gems gained")
		UserData.gems += UserData.staged_gems
		UserData.staged_gems = 0
	update_header_display()

func update_header_display() -> void:
	streak_label.text = str(UserData.streak_current)
	gems_label.text = str(UserData.gems)

func _on_SelectBar_selected(current_select) -> void:
	if store:
		store.update_buttons()
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

func _on_Gems_pressed() -> void:
	_on_SelectBar_selected(0)

func _on_Streak_pressed() -> void:
	_on_SelectBar_selected(3)

func _on_Gallery_image_changed() -> void:
	background_preview.texture = UserData.pictures[UserSettings.picture_index][1]
	background_title.text = UserData.pictures[UserSettings.picture_index][0]

func _on_Store_purchase_made() -> void:
	update_header_display()
