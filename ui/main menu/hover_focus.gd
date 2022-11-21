extends Control

func _hover():
	grab_focus()

func _unhover():
	get_node("/root/main").grab_focus()
