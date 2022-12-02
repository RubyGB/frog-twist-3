extends Control

func _ready() -> void:
	get_child(Globals.MUSIC_CHOICE.RANDOM).set_pressed_no_signal(false)
	get_child(Globals.musicChoice).set_pressed_no_signal(true)

func _checkbox_toggled(_on : bool, id : int) -> void:
	if Globals.musicChoice == id:
		get_child(id).set_pressed_no_signal(true)
		return
	
	get_child(Globals.musicChoice).set_pressed_no_signal(false)
	Globals.musicChoice = id
