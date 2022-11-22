extends AudioStreamPlayer

const titleStream = preload("res://ui/main menu/frogtwist_title.wav")
const levelStream = preload("res://level/frogtwist_bgm1.wav")
enum { TITLE, LEVEL_A }
const ID_MAP = {
	TITLE : titleStream,
	LEVEL_A : levelStream
}

func _ready() -> void:
	playID(TITLE)

func playID(id : int) -> void:
	stream = ID_MAP[id]
	play()
