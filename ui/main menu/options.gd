extends Control

func _ready():
	get_node("%bgm_slider").value = Globals.bgmVolume
	get_node("%sfx_slider").value = Globals.sfxVolume

func _bgm_change(newval : float) -> void:
	Globals.bgmVolume = newval

func _sfx_change(newval : float) -> void:
	Globals.sfxVolume = newval
