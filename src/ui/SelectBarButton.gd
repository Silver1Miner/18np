extends TextureButton

signal selected(id)
export var id := 1
export var length_min = 60
export var length_max = 120
onready var tween = $Tween
onready var label = $Label
onready var symbol = $Icon
onready var label_font = $Label.get("custom_fonts/font")
var font_min = 16
var font_max = 28

func _on_Select_toggled(button_pressed) -> void:
	if button_pressed:
		grab_focus()
		label.visible = pressed
		tween.interpolate_property(self, "rect_min_size:x",
		length_min, length_max, 0.3,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		label_font.size = font_min
		tween.interpolate_property(label_font, "size",
		font_min, font_max, 0.3,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(symbol, "rect_size",
		Vector2(60, 60), Vector2(80, 80), 0.3,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		tween.interpolate_property(symbol, "rect_position",
		Vector2(0, 0), Vector2(20, -40), 0.3,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		tween.start()
		emit_signal("selected", id)
		disabled = true
	else:
	#elif rect_min_size.x == length_max:
		label.visible = pressed
		tween.interpolate_property(self, "rect_min_size:x",
		length_max, length_min, 0.3,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		label_font.size = font_min
		tween.interpolate_property(symbol, "rect_size",
		Vector2(80, 80), Vector2(60, 60), 0.3,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		tween.interpolate_property(symbol, "rect_position",
		Vector2(20, -40), Vector2(0, 0), 0.3,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		tween.start()
		disabled = false
