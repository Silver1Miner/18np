extends Control

signal image_changed()
onready var jukebox_select = $Options/Jukebox/JukeboxSelect
onready var gallery_select = $Options/Pictures
onready var preview = $Preview
onready var preview_pic = $Preview/PreviewPic
onready var set_button = $Preview/Set
var jukebox = []
var gallery = []
var current_index = 0
var current_page = 0

func _ready() -> void:
	update_jukebox()
	update_gallery()
	update_jukebox_choice()

func update_jukebox() -> void:
	jukebox.clear()
	jukebox_select.clear()
	for track in UserData.owned_tracks:
		jukebox_select.add_item(UserData.tracks[track][0])
		jukebox.append(track)
	if UserSettings.jukebox_index < jukebox_select.get_item_count():
		jukebox_select.select(UserSettings.jukebox_index)

func update_jukebox_choice() -> void:
	_on_JukeboxSelect_item_selected(UserSettings.jukebox_index)

func update_gallery() -> void:
	preview.visible = false
	gallery.clear()
	gallery_select.clear()
	for pic in UserData.owned_pictures:
		gallery_select.add_item(UserData.pictures[pic][0])
		gallery.append(pic)
	for i in gallery_select.get_item_count():
		gallery_select.set_item_tooltip_enabled(i, false)

func _on_JukeboxSelect_item_selected(index: int) -> void:
	print("jukebox select: ", index)
	UserSettings.jukebox_index = index
	if UserSettings.jukebox_index < jukebox.size():
		Audio.play_music(jukebox[UserSettings.jukebox_index])
	UserSettings.save_settings()

func _on_Pictures_item_selected(index: int) -> void:
	Audio.play_sound("res://assets/audio/sounds/confirmation_001.ogg")
	current_index = index
	preview_pic.texture = UserData.pictures[gallery[current_index]][1]
	set_button.disabled = false
	preview.visible = true

func _on_Set_pressed() -> void:
	Audio.play_sound("res://assets/audio/sounds/confirmation_001.ogg")
	UserSettings.picture_index = gallery[current_index]
	UserSettings.save_settings()
	set_button.disabled = true
	preview.visible = false
	emit_signal("image_changed")

func _on_Close_pressed() -> void:
	Audio.play_sound("res://assets/audio/sounds/back_002.ogg")
	preview.visible = false
	set_button.disabled = false

