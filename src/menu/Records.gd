extends Control

onready var calendarui = $CalendarUI

func _ready() -> void:
	pass

func _on_CalendarUI_date_selected(date_obj) -> void:
	print(date_obj.date())
	$Panel/Label.text = str(date_obj.get_year()) + "/" + str(date_obj.get_month()) + "/"+ str(date_obj.get_day())
	$Panel/Status/Clock/Value.text = "--:--"
	$Panel/Status/Moves/Value.text = "-"

func _on_ToToday_pressed() -> void:
	calendarui.date.change_to_today()
	calendarui.refresh_data()
	_on_CalendarUI_date_selected(calendarui.date)
