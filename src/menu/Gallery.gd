extends Control

onready var jukebox_select = $Options/Jukebox/JukeboxSelect
onready var gallery_select = $Options/Pictures
onready var preview = $Preview
onready var preview_pic = $Preview/PreviewPic
onready var set_button = $Preview/Set
var jukebox = []
var gallery = []
var current_index = 0

func _ready() -> void:
	preview.visible = false
	update_jukebox()
	update_gallery()

func update_jukebox() -> void:
	jukebox.clear()
	jukebox_select.clear()
	for track in UserData.owned_tracks:
		jukebox_select.add_item(UserData.tracks[track][0])
		jukebox.append(track)

func update_gallery() -> void:
	gallery.clear()
	gallery_select.clear()
	for pic in UserData.owned_pictures:
		gallery_select.add_item(UserData.pictures[pic][0])
		gallery.append(pic)

func _on_JukeboxSelect_item_selected(index: int) -> void:
	print("jukebox select: ", index)
	Audio.play_music(jukebox[index])

func _on_Pictures_item_selected(index: int) -> void:
	current_index = index
	preview_pic.texture = UserData.pictures[gallery[current_index]][1]
	preview.visible = true

func _on_Set_pressed() -> void:
	UserSettings.picture_index = gallery[current_index]
	set_button.disabled = true

func _on_Close_pressed() -> void:
	preview.visible = false
	set_button.disabled = false


