extends TextureButton

var number = 0
onready var tween = $Tween

signal tile_pressed(number)
signal slide_completed(number)

func set_number(new_number: int) -> void:
	number = new_number
	$Label.text = str(number)

func set_sprite(new_frame, size, tile_size) -> void:
	update_size(size, tile_size)
	$Sprite.set_hframes(size)
	$Sprite.set_vframes(size)
	$Sprite.set_frame(new_frame)

func update_size(size, tile_size) -> void:
	var new_size = Vector2(tile_size, tile_size)
	set_size(new_size)
	$Label.set_size(new_size)
	$Panel.set_size(new_size)
	var to_scale = size * (new_size/$Sprite.texture.get_size())
	$Sprite.set_scale(to_scale)

func set_sprite_texture(texture) -> void:
	$Sprite.set_texture(texture)

func slide_to(new_position, duration) -> void:
	tween.interpolate_property(self, "rect_position", null, new_position, duration,
	Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

func set_number_visible(state: bool) -> void:
	$Label.visible = state

func _on_Tile_pressed() -> void:
	emit_signal("tile_pressed", number)

func _on_Tween_tween_completed(_object, _key) -> void:
	emit_signal("slide_completed", number)
