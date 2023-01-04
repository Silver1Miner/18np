extends VBoxContainer

signal size_selected(size)

func _on_Button_pressed() -> void:
	emit_signal("size_selected", 3)

func _on_Button2_pressed() -> void:
	emit_signal("size_selected", 4)

func _on_Button3_pressed() -> void:
	emit_signal("size_selected", 5)

func _on_Button4_pressed() -> void:
	emit_signal("size_selected", 6)

func _on_Button5_pressed() -> void:
	emit_signal("size_selected", 7)

func _on_Button6_pressed() -> void:
	emit_signal("size_selected", 8)

func _on_Button7_pressed() -> void:
	emit_signal("size_selected", 9)
