extends Control

onready var calendarui = $CalendarUI

func _ready() -> void:
	pass

func _on_CalendarUI_date_selected(date_obj) -> void:
	print(date_obj.date())
	UserData.change_records_loaded(date_obj.get_year(), date_obj.get_month())
	$Panel/Label.text = str(date_obj.get_year()) + "/" + str(date_obj.get_month()) + "/"+ str(date_obj.get_day())
	if str(date_obj.get_day()) in UserData.current_loaded:
		var result = UserData.current_loaded[str(date_obj.get_day())]
		var minute_string = str(result.minutes)
		var second_string = str(result.seconds)
		if result.minutes < 10:
			minute_string = "0" + str(result.minutes)
		if result.seconds < 10:
			second_string = "0" + second_string
		$Panel/Status/Clock/Value.text = minute_string + ":" + second_string
		$Panel/Status/Moves/Value.text = str(result.moves)
	else:
		$Panel/Status/Clock/Value.text = "--:--"
		$Panel/Status/Moves/Value.text = "-"

func _on_ToToday_pressed() -> void:
	calendarui.date.change_to_today()
	calendarui.refresh_data()
	_on_CalendarUI_date_selected(calendarui.date)
