extends Control

signal to_freeplay(board_size)
signal to_daily_challenge()
onready var tween = $Tween
onready var panes = $Panes
onready var settings_button = $Overlay/Panel/SettingsButton
onready var settings_menu = $Overlay/Panel/Settings
onready var play_daily_button = $Panes/Daily/PlayDaily
onready var background_preview = $Panes/Daily/Preview
onready var background_title = $Panes/Daily/PreviewTitle
onready var store = $Panes/Store
onready var records = $Panes/Records
onready var gallery = $Panes/Gallery
onready var streak_label = $Overlay/Panel/Status/Streak/Label
onready var gems_label = $Overlay/Panel/Status/Gems/Label
onready var anim = $Overlay/Panel/AnimationPlayer
onready var select_bar = $Overlay/SelectBar

func _ready() -> void:
	if Billing.connect("purchase_consumed", self, "_on_purchase_consumed") != OK:
		push_error("fail to connect billing signal")
	check_daily()
	_on_Gallery_image_changed()
	panes.rect_position.x = 2 * -360
	UserData.check_expired()
	update_header_display()

var minimum_drag = 150
var swipe_start = Vector2.ZERO
func _input(event: InputEvent):
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.get_position()
		else:
			_calculate_swipe(event.get_position())

func _calculate_swipe(swipe_end: Vector2):
	if swipe_start == Vector2.ZERO: 
		return
	var swipe = swipe_end - swipe_start
	if abs(swipe.x) > minimum_drag:
		var choice = 2
		if swipe.x < 0:
			choice = select_bar.current_select + 1
		else:
			choice = select_bar.current_select - 1
		if choice >= 0 and choice < 5:
			select_bar.get_children()[choice].pressed = true

func check_daily() -> void:
	Daily.check_day()
	if Daily.today_challenge_completed:
		play_daily_button.disabled = true
		play_daily_button.text = "Completed!"
	else:
		play_daily_button.disabled = false
		play_daily_button.text = "Daily 4x4"
	if UserData.staged_gems > 0:
		anim.play("StreakUpdate")

func update_header_display() -> void:
	UserData.gems += UserData.staged_gems
	UserData.staged_gems = 0
	streak_label.text = str(UserData.streak_current)
	gems_label.text = str(UserData.gems)
	UserData.save_inventory()

func _on_SelectBar_selected(current_select) -> void:
	if current_select < 0 or current_select > 4:
		return
	if current_select == 0 and store:
		store.update_buttons()
	if current_select == 3 and records:
		records._on_ToToday_pressed()
	if settings_button:
		settings_button.pressed = false
	if gallery:
		gallery.update_jukebox()
		gallery.update_gallery()
	if tween:
		Audio.play_slide()
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
	settings_menu.about_panel.visible = false
	settings_menu.about_toggle.pressed = false
	Audio.play_sound("res://assets/audio/sounds/switch_004.ogg")

func _on_Gems_pressed() -> void:
	select_bar.get_children()[0].pressed = true
	#_on_SelectBar_selected(0)

func _on_Streak_pressed() -> void:
	select_bar.get_children()[3].pressed = true
	#_on_SelectBar_selected(3)

func _on_Gallery_image_changed() -> void:
	if UserSettings.picture_index <= UserData.max_pictures:
		background_preview.texture = UserData.pictures[UserSettings.picture_index][1]
		background_title.text = UserData.pictures[UserSettings.picture_index][0]
	else:
		background_preview.texture = UserData.pictures[3][1]
		background_title.text = UserData.pictures[3][0]
	select_bar.get_children()[2].pressed = true

func _on_Store_purchase_made() -> void:
	update_header_display()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "StreakUpdate":
		Audio.play_sound("res://assets/audio/sounds/confirmation_004.ogg")
		update_header_display()

func _on_ToGallery_pressed() -> void:
	select_bar.get_children()[4].pressed = true

func _on_purchase_consumed(gem_value: int) -> void:
	UserData.staged_gems += gem_value
	anim.play("StreakUpdate")

func _on_FreePlay_pressed() -> void:
	select_bar.get_children()[1].pressed = true
