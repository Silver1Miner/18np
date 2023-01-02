extends HBoxContainer

signal selected(current_select)
var current_select = 2

func _ready():
	for n in 5:
		if get_children()[n].connect("selected", self, "_on_selected") != OK:
			push_error("fail to connect select")
	get_children()[2].pressed = true

func _on_selected(id: int):
	current_select = id
	update_display()
	emit_signal("selected", current_select)

func update_display() -> void:
	for n in len(get_children()):
		if n == current_select:
			pass
		else:
			get_children()[n].pressed = false
