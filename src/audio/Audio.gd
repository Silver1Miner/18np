extends AudioStreamPlayer

func play_music(id: int) -> void:
	if id >= 0 and id < len(UserData.tracks):
		stream = UserData.tracks[id][1]
	else:
		stream = UserData.tracks[0][1]
	play()

var available = []
var queue = []
func _ready():
	AudioServer.set_bus_mute(1, UserSettings.mute_sound)
	AudioServer.set_bus_mute(2, UserSettings.mute_music)
	play_music(UserSettings.jukebox_index)
	for i in 4:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", self, "_on_sound_finished", [p])
		p.bus = "Sound"

func _physics_process(_delta: float) -> void:
	if not queue.empty() and not available.empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()

func _on_sound_finished(next_stream) -> void:
	available.append(next_stream)

func play_sound(sound_path: String) -> void:
	queue.append(sound_path)

func play_slide() -> void:
	randomize()
	var slide = int(rand_range(1,6))
	play_sound("res://assets/audio/sounds/slides/cardSlide" + str(slide) + ".ogg")
