extends Control

signal date_selected(date_obj)
const BUTTONS_COUNT = 42
var calendar := Calendar.new()
var date := Date.new()
onready var buttons_container = $PanelContainer/vbox/hbox_days
onready var month_year_label = $PanelContainer/vbox/hbox_month_year/label_month_year

func _ready() -> void:
	var month_year_path = "PanelContainer/vbox/hbox_month_year/"
	if get_node(month_year_path + "button_prev_month").connect("pressed",self,"go_prev_month") != OK: push_error("fail to connect calendar signal")
	if get_node(month_year_path + "button_next_month").connect("pressed",self,"go_next_month") != OK: push_error("fail to connect calendar signal")
	if get_node(month_year_path + "button_prev_year").connect("pressed",self,"go_prev_year") != OK: push_error("fail to connect calendar signal")
	if get_node(month_year_path + "button_next_year").connect("pressed",self,"go_next_year") != OK: push_error("fail to connect calendar signal")
	setup_button_signals()
	refresh_data()
	check_today()

func setup_button_signals() -> void:
	for i in range(BUTTONS_COUNT):
		var btn_node = buttons_container.get_node("btn_" + str(i))
		btn_node.connect("pressed", self, "on_day_selected", [btn_node])

func check_today() -> void:
	var days_in_month : int = calendar.get_days_in_month(date.get_month(), date.get_year())
	var start_day_of_week : int = calendar.get_weekday(1, date.get_month(), date.get_year())
	for i in range(days_in_month):
		var btn_node : Button = buttons_container.get_node("btn_" + str(i + start_day_of_week))
		if(i + 1 == calendar.get_day() && date.get_year() == calendar.get_year() && date.get_month() == calendar.get_month() ):
			btn_node.emit_signal("pressed")

func on_day_selected(btn_node) -> void:
	var day := int(btn_node.get_text())
	date.set_day(day)
	update_calendar_buttons(date)
	emit_signal("date_selected", date)

func update_calendar_buttons(selected_date: Date):
	_clear_calendar_buttons()
	var days_in_month : int = calendar.get_days_in_month(selected_date.get_month(), selected_date.get_year())
	var start_day_of_week : int = calendar.get_weekday(1, selected_date.get_month(), selected_date.get_year())
	for i in range(days_in_month):
		var btn_node : Button = buttons_container.get_node("btn_" + str(i + start_day_of_week))
		btn_node.set_text(str(i + 1))
		btn_node.set_disabled(false)

func _clear_calendar_buttons():
	for i in range(BUTTONS_COUNT):
		var btn_node : Button = buttons_container.get_node("btn_" + str(i))
		btn_node.set_text("")
		btn_node.set_disabled(true)

func refresh_data():
	var title : String = str(calendar.get_month_name(date.get_month()) + " " + str(date.get_year()))
	month_year_label.set_text(title)
	update_calendar_buttons(date)

func go_prev_month():
	date.change_to_prev_month()
	refresh_data()

func go_next_month():
	date.change_to_next_month()
	refresh_data()

func go_prev_year():
	date.change_to_prev_year()
	refresh_data()

func go_next_year():
	date.change_to_next_year()
	refresh_data()
