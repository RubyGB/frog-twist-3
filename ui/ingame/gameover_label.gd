extends Label

func _final_daytime():
	text = "Game over!\n" + BugNet.scoreString(BugNet.score) + "\nTop " + BugNet.scoreString(Globals.topScore)
	visible = true
