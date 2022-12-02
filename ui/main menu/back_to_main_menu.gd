extends Control

func _back():
	if get_tree().change_scene("res://ui/main menu/main menu.tscn") != OK:
		return
