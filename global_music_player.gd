extends AudioStreamPlayer

signal finished_fadeout
signal finished_fadein

var setVolumeDB : float = 0.0

const SILENCE : float = -80.0
const DEFAULT_FADE_DURATION : float = 1.0

const titleStream = preload("res://ui/main menu/frogtwist_title.wav")
const levelAStream = preload("res://level/frogtwist_bgm1.wav")
const resultsStream = preload("res://level/frogtwist_results.wav")
enum { NO_MUSIC = -1, TITLE, LEVEL_A, RESULTS }
const ID_MAP = {
	TITLE : titleStream,
	LEVEL_A : levelAStream,
	RESULTS : resultsStream
}

enum FadeState { NONE, OUT, IN }
var currentID : int
var fading : int = FadeState.NONE
var fadeSpeed : float

func _ready() -> void:
	bus = "BGM"
	playID(TITLE)

func _process(delta : float) -> void:
	if fading == FadeState.OUT:
		volume_db -= delta * fadeSpeed
		if volume_db <= SILENCE:
			hardStop()
			emit_signal("finished_fadeout")
	if fading == FadeState.IN:
		volume_db += delta * fadeSpeed
		if volume_db >= setVolumeDB:
			volume_db = setVolumeDB
			fading = FadeState.NONE
			emit_signal("finished_fadein")

func playID(id : int) -> void:
	fading = FadeState.NONE
	volume_db = setVolumeDB
	stream = ID_MAP[id]
	currentID = id
	play()

func hardStop() -> void:
	stop()
	currentID = NO_MUSIC
	fading = FadeState.NONE

func fadeout(duration : float = DEFAULT_FADE_DURATION) -> void:
	if fading == FadeState.OUT:
		return
	fading = FadeState.OUT
	fadeSpeed = -SILENCE / duration
	volume_db = setVolumeDB

func fadein(id : int, duration : float = DEFAULT_FADE_DURATION) -> void:
	if fading == FadeState.IN and id == currentID:
		return
	fading = FadeState.IN
	fadeSpeed = -SILENCE / duration
	volume_db = SILENCE
	stream = ID_MAP[id]
	currentID = id
	play()
